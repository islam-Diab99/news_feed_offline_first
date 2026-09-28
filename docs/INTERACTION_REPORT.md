# How every interaction works — interview prep report

Each section traces one user action through the layers: **Widget → Bloc → Repository → LocalStore (Hive) / ApiClient → back to the UI**. File references are clickable in the IDE. The report describes the working tree as of writing, which includes 2 uncommitted edits (see §9).

---

## 0. The 60-second mental model

```
 Widget  ──event──▶  Bloc  ──call──▶  Repository  ──▶  ApiClient (MockApiClient = fake server)
   ▲                  ▲                   │  └────▶  LocalStore (Hive boxes = disk cache + outbox)
   │ state            │ private event     │
   └──── Bloc ◀───────┴──── ArticleUpdateBus (broadcast stream) ◀── repository.publish(...)
```

Five ideas explain the whole app:

1. **Offline-first reads are network-first with a disk fallback.** Try the API; on `NetworkException`, serve the Hive snapshot flagged `isStale`.
2. **Writes are local-first / optimistic.** Change local state and the UI immediately, then talk to the server. If the device is offline, put the intent in the **outbox**.
3. **The outbox** is a Hive box of pending mutations, keyed by idempotency key. On reconnect, `OutboxSyncService` replays it in a single `POST /sync`.
4. **`ArticleUpdateBus`** is how every list, the bookmarks tab and the open detail page stay consistent without knowing about each other. Repositories publish the canonical `Article` after any change. Every bloc that holds articles subscribes and patches its own list.
5. **Server wins on conflict, but the user's local intent wins over stale server payloads.** Article `version` numbers detect conflicts. `withLocalState` re-applies bookmarks and queued likes on top of whatever the network returned.

**Important:** blocs never hold engagement logic. `EngagementBloc` holds *no article state*; it only calls repositories and emits snackbar notices. The heart icon changes because a repository published to the bus and `FeedBloc` re-emitted its list.

---

## 1. Startup and wiring

[main.dart](../lib/main.dart) → `configureDependencies()` in [injector.dart](../lib/core/di/injector.dart) → `runApp`.

| Registered as | What | Why it matters |
|---|---|---|
| singleton | `AppConnectivityService` (registered as both `ConnectivityController` and `ConnectivityService`) | One source of truth for "online?" |
| singleton | `ArticleUpdateBus` | One shared stream for all blocs |
| singleton | `HiveLocalStore` (awaited: opens 6 boxes) | Storage must be ready before the first frame |
| lazy singleton | `MockApiClient` (gets connectivity) | The fake server can fail *because* connectivity says offline |
| lazy singletons | Feed / Search / Article / Bookmark / Reaction repositories | Constructor-injected interfaces, so tests swap fakes |
| singleton | `OutboxSyncService` **`..start()`** | Starts listening to connectivity and the outbox immediately, at app launch |

[app.dart](../lib/app.dart) puts 5 blocs above `MaterialApp`, so pushed routes (article detail) can also read them:

- `ConnectivityCubit`: banner state
- `EngagementBloc`: like/bookmark commands
- `FeedBloc` (`..add(FeedStarted())`)
- `SearchBloc` (`..add(SearchStarted())`)
- `BookmarksBloc` (`..add(BookmarksRequested())`)

`ArticleDetailBloc` is the exception: it is created per page in [article_detail_page.dart:22](../lib/presentation/pages/article_detail_page.dart#L22), so each opened article gets a fresh one.

`HomeShell` uses an `IndexedStack`, so all 3 tabs stay alive, and their blocs keep listening to the bus even when the tab isn't visible.

---

## 2. The building blocks (know these cold)

### 2.1 `Article` ([article.dart](../lib/domain/entities/article.dart))
Immutable `Equatable`. Interaction state lives on it: `likes`, `isLiked`, `isBookmarked`, and **`version`**. `version` is the server's optimistic-concurrency counter: it bumps on every server-side change to that article. Equality includes those fields, which is why Bloc emits a new state only when something actually changed.

### 2.2 `LocalStore` / `HiveLocalStore` — how local storage really works

Interface: [local_store.dart](../lib/data/datasources/local/local_store.dart). Implementation: [hive_local_store.dart](../lib/data/datasources/local/hive_local_store.dart).

It is **six Hive boxes, all `Box<String>`** (values are JSON strings, the same shape as the wire format, so there is no codegen and no type adapters):

| Box | Key → Value | Written by | Purpose |
|---|---|---|---|
| `articles` | `articleId` → article JSON | `upsertArticles` (every path!) | The **canonical local copy** of each article: latest likes, `isLiked`, `version` |
| `feed_snapshots` | `"topic\|source"` (e.g. `*\|*`) → `{ids[], nextCursor, savedAt}` | `saveFeedSnapshot` | Which articles were in the feed, in order. Stores **ids only**; bodies come from `articles` |
| `details` | `articleId` → `{detail, savedAt}` | `saveDetail` | Cached article body for offline reading |
| `bookmarks` | `articleId` → `{article, savedAt}` | `saveBookmark` | The **source of truth for bookmarks**. Separate box so bookmarks survive even if the article cache entry is deleted |
| `outbox` | `idempotencyKey` → mutation JSON | `enqueueMutation` | Pending offline writes |
| `meta` | `'lastFeedSync'` → ISO time | `setLastFeedSyncTime` | Cursor for `getFeedUpdates(since)` |

How Hive behaves (likely interview question): `Hive.openBox` loads the **whole box into memory**, so `box.get(...)` is **synchronous** and fast, while `put` is async and appended to a file on disk. That's why `feedSnapshot` can call `_articles.get(id)` inside a list comprehension. `Hive.initFlutter()` puts the files in the app documents directory, so data survives restarts.

Notable internals:

- **`upsertArticles` calls `withLocalState` first.** Every article written to disk is first merged with the bookmark set and the queued outbox likes. See §2.3.
- **`feedSnapshot`** reads the id list, then maps ids to article JSON through a `Set` (dedupe). Decoding runs inline for fewer than 200 articles and moves to a background isolate via `compute()` at 200 or more, so a big cache doesn't jank the UI ([hive_local_store.dart:14](../lib/data/datasources/local/hive_local_store.dart#L14)).
- **`bookmarkedArticles`** sorts by `savedAt` descending, and overlays the *fresher* copy from the `articles` box (forced `isBookmarked: true`), so bookmarks show current like counts.
- **`pendingMutations`** decodes the outbox box and **sorts by `queuedAt`**, which gives replay order.
- **`outboxChanges`** is `_outbox.watch()`. Hive's built-in change stream drives the "N changes pending" banner.
- **`removeArticle`** deletes from `articles` and `details`, **not from `bookmarks`**. See §9.

### 2.3 `withLocalState` / `applyLocalState` — the reconciliation rule

[local_store.dart:85](../lib/data/datasources/local/local_store.dart#L85). Any article that arrives from the network (or is about to be persisted) is overlaid with:

- `isBookmarked` = whether it's in the `bookmarks` box
- `isLiked`/`likes` flipped to the **latest queued outbox intent** for that article, if it differs. The count is adjusted ±1 to stay consistent.

Rationale: bookmarks and queued likes are *the user's local intent that the server hasn't seen yet*, so a plain feed refresh must not silently undo them. This is tested in `a queued like survives a feed load that says otherwise`.

### 2.4 `OutboxMutation` ([outbox_mutation.dart](../lib/data/models/outbox_mutation.dart))
`{ idempotencyKey (uuid v4), op: 'set_reaction' | 'set_bookmark', articleId, payload, queuedAt }`. The payload is the *desired end state* (`reaction: 'like'|'unlike'`, `bookmarked: true|false`), not a delta. That is what makes coalescing and replay safe.

### 2.5 `ArticleUpdateBus` ([article_update_bus.dart](../lib/domain/services/article_update_bus.dart))
A `StreamController.broadcast()`. Two update types, a sealed class: `ArticleChanged(article)` and `ArticleRemoved(id)`. Fire-and-forget with no replay. That's fine because every bloc loads its own data first and only needs deltas afterwards.

**How a bloc consumes it** (same pattern in Feed, Search, Bookmarks, Detail): subscribe in the constructor, and `add(_PrivateArticleUpdated(update))`. Routing bus events through the bloc's own event queue with a `sequential()` transformer means they are processed in order and never race with `emit` from other handlers.

### 2.6 Connectivity ([connectivity_service.dart](../lib/core/network/connectivity_service.dart))
`isOnline = _hasNetwork && !_simulatedOffline`.

- `_hasNetwork` comes from `connectivity_plus` (real airplane mode, wifi off).
- `_simulatedOffline` is the demo toggle in the app bar (`ConnectivityCubit.toggleSimulatedOffline`).
- `onStatusChange` emits only when `isOnline` may have changed.

**Where it's consulted:**
1. `MockApiClient._network()` throws `NetworkException` if offline, **both before and after the fake latency**. So a request already in flight fails if you go offline.
2. `Reaction`/`Bookmark` repositories check `isOnline` before trying, so they skip the request and queue straight away.
3. `OutboxSyncService` triggers on `onStatusChange == true`.
4. `ConnectivityCubit` shows the banner.

Limitation: `connectivity_plus` reports *network interface* state, not real internet reachability (captive portals, dead wifi). The robust fallback is that any request failing with a network error queues/falls back the same way.

### 2.7 `MockApiClient` ([mock_api_client.dart](../lib/data/datasources/remote/mock_api_client.dart)) — the fake server
In-memory records loaded from `assets/mock/*.json`. Every call is `await _network()` (300–700 ms random latency, plus the offline check). Deterministic behaviours, and what you'd say to explain them:

| Behaviour | Rule |
|---|---|
| Reaction failure | Every **3rd** `setReaction` call throws `ServerException` → demonstrates rollback |
| First-like conflict | The very first like on the top story pretends another reader liked it first (+3 likes, `version`+1) → demonstrates conflict path with one tap |
| Conflict detection | `expectedVersion < serverVersion` → `ReactionConflict` (returns server truth) |
| Refresh side effects | Each `getFeedUpdates`: publishes 1 reserved story, bumps 1 story (+3 likes, version+1), and on the 2nd call deletes one |
| Sync | Applies mutations in order; a reaction that already matches server state comes back as a *conflict*; missing/deleted articles are just marked applied |

---

## 3. Errors: how they flow

[app_exception.dart](../lib/core/error/app_exception.dart): sealed `AppException` → `NetworkException`, `ServerException`, `NotFoundException` (`CacheMissException` exists but is unused).

The data layer **throws typed exceptions; blocs map them to states**. No string matching.

- `NetworkException` → repositories fall back to cache (reads) or queue (writes).
- `ServerException` / `NotFoundException` → for reactions: rollback and snackbar. For lists: failure state or footer retry.

---

## 4. Interaction walk-throughs

### 4.1 ❤️ User taps LIKE (the one to master)

**Step 0, the UI.** [article_card.dart:128](../lib/presentation/widgets/article_card.dart#L128):
`context.read<EngagementBloc>().add(EngagementLikeToggled(article))`. The article passed in is the *current* one shown on screen, which includes the current `version`.

**Step 1, the bloc.** [engagement_bloc.dart:30](../lib/presentation/blocs/engagement/engagement_bloc.dart#L30). Registered with `transformer: concurrent()`, so likes on *different* articles run in parallel and don't queue behind a 700 ms request. The handler only does `await _reactions.toggleLike(article)`. It `catch`es `AppException` and emits `state.notify(message)`. That is the **only** thing this bloc emits.

**Step 2, the repository.** [reaction_repository_impl.dart:35](../lib/data/repositories/reaction_repository_impl.dart#L35), in order:

```
toggleLike(article)
 ├─ 1. In-flight guard: if _inFlight.contains(id) → return   (drops a double-tap on the same article)
 │     _inFlight.add(id)                                     (synchronous, before any await → race-free)
 ├─ 2. Build optimistic = article flipped, likes ±1
 ├─ 3. _commit(optimistic):
 │       store.upsertArticles([optimistic])   → Hive `articles` box (via withLocalState merge)
 │       bus.publish(ArticleChanged(optimistic))  → UI updates NOW (heart flips, count changes)
 ├─ 4. if !connectivity.isOnline → _enqueue(id, liked); return          ← OFFLINE PATH
 ├─ 5. response = await api.setReaction(id, liked, clientMutationId: uuid, expectedVersion: article.version)
 │       ├─ ReactionSuccess(likes, version)   → _commit(optimistic + server likes + new version)
 │       └─ ReactionConflict(isLiked, likes, version) → _commit(article.copyWith(server truth))   ← SERVER WINS
 ├─ catch NetworkException (dropped mid-request) → _enqueue(id, liked)   (keep optimistic, no error shown)
 ├─ catch other AppException (Server/NotFound)   → _commit(article) = ROLLBACK to pre-tap state, then rethrow
 └─ finally: _inFlight.remove(id)
```

**Step 3, how the UI actually changes.** `bus.publish` → `FeedBloc`, `SearchBloc`, `BookmarksBloc`, `ArticleDetailBloc` each receive `ArticleChanged`. Each does `indexWhere(id)`; if found it replaces that element and emits. If the article isn't in its list, it ignores the update. `BlocBuilder`s rebuild the affected `ArticleCard` (the `ValueKey(article.id)` keeps identity and scroll position). The icon uses `AnimatedSwitcher` for the scale animation.

**Step 4, errors reach the user.** On rollback the repository rethrows → `EngagementBloc` catches → `notify(e.message)` → `HomeShell`'s `BlocListener` (`listenWhen: noticeId changed`) shows a `SnackBar`. `noticeId` is an incrementing counter so the *same* message twice still triggers the listener (Equatable would otherwise treat it as unchanged).

**Outcomes at a glance**

| Situation | What the user sees | Store ends as | Outbox |
|---|---|---|---|
| Online, success | instant flip, then count corrected to server value | server likes + bumped `version` | – |
| Online, **version conflict** | instant flip, then count/heart jump to server truth | server state | – |
| Online, server error (every 3rd) | instant flip, then **reverts** + snackbar | original article | – |
| Offline | instant flip, stays | optimistic | 1 `set_reaction` mutation |
| Drops offline mid-request | instant flip, stays, no error | optimistic | 1 mutation |
| Double-tap while in flight | 2nd tap ignored | – | – |
| Article deleted server-side | flip, then revert + "no longer available" snackbar | original | – |

**Why the `expectedVersion`?** It's optimistic concurrency control. "I'm acting on version 3. If the server is past 3, someone else changed it, so tell me the truth instead of applying blindly." The mock's `getFeedUpdates` bumps a story so a stale client hits this branch.

**Interview tip:** be ready to say *why not lock the UI while waiting?* Because instant feedback matters more than a transiently off-by-a-few count, and the server response replaces the guess anyway.

### 4.2 🔖 User taps BOOKMARK

`EngagementBookmarkToggled` → `EngagementBloc._onBookmarkToggled` → [bookmark_repository_impl.dart:36](../lib/data/repositories/bookmark_repository_impl.dart#L36):

```
toggle(article)
 ├─ flip isBookmarked
 ├─ LOCAL FIRST:  saveBookmark(patched)  | removeBookmark(id)   → `bookmarks` box  (source of truth)
 │                upsertArticles([patched])                      → `articles` box
 │                bus.publish(ArticleChanged(patched))           → all lists update, Bookmarks tab adds/removes it
 ├─ if offline → _enqueue(set_bookmark) ; return
 └─ else try api.setBookmark(...)      on ANY AppException → _enqueue (NOT rolled back)
```

Differences from like, and *why*:

- **No rollback.** A bookmark is a purely personal, local-first action. The server is a best-effort mirror. On server failure it just queues.
- **No optimistic guess or version.** There's nothing to conflict on (only this user changes their bookmark).
- **Snackbar text** ("Saved to bookmarks" or "Removed from bookmarks") is emitted by the bloc after the repo call, based on the *pre-toggle* value of `event.article.isBookmarked`.
- **`BookmarksBloc`** handles the `ArticleChanged`: bookmarked and not in list → prepend; un-bookmarked and in list → remove; otherwise replace in place. It only queries the store once at startup, then follows the bus.

### 4.3 App launch → feed

`FeedStarted` (`restartable()`) → [feed_bloc.dart:48](../lib/presentation/blocs/feed/feed_bloc.dart#L48):
1. `status = loading` (UI shows the skeleton).
2. Load topics via `SearchRepository.topics()` (memoized in memory; returns `[]` on network failure).
3. `FeedRepositoryImpl.firstPage()` ([feed_repository_impl.dart:23](../lib/data/repositories/feed_repository_impl.dart#L23)):
   - **Online:** `api.getFeed(page 1)` → `store.withLocalState(items)` → `store.saveFeedSnapshot(key, items, nextCursor)` (upserts each article, writes the ids to `feed_snapshots`) → return.
   - **Offline (`NetworkException`):** `_cachedFeed(key)` → build from the snapshot with `isStale: true` and **`nextCursor: null`**. If no snapshot exists, rethrow → bloc emits failure: "You are offline and nothing is cached yet."
4. Emit `success` with `isStale`. The banner shows "Showing saved content — pull to refresh".

`restartable()` means a newer `FeedStarted` or topic change cancels the in-flight one, so a slow old response can't overwrite a newer topic's list.

### 4.4 Infinite scroll (pagination)

`PaginatedArticleList` ([paginated_article_list.dart:96](../lib/presentation/widgets/paginated_article_list.dart#L96)) watches scroll notifications. When within 400 px of the end, and not already loading, `hasMore`, and not failed, it calls `onLoadMore` → `FeedNextPageRequested` (`droppable()`: extra requests while one is running are ignored, so there are no duplicate pages).

Bloc: `isLoadingMore = true` → `feed.nextPage(cursor)`:
- API with cursor `feed_N` → `withLocalState` → **append to the stored snapshot** (deduped by id) and keep the new cursor, so **the offline cache contains every page the user loaded**, not just page 1.
- Bloc appends with a dedupe by id.
- On any `AppException` → `loadMoreFailed = true` → the footer shows a retry (the list itself is preserved).

Offline: the cached snapshot has no cursor → `hasMore = false` → scrolling stops at the cached window ("by design, no infinite spinner").

The same widget serves Feed, Search and Bookmarks (Bookmarks passes no `onLoadMore`, so no footer).

### 4.5 Pull to refresh

`RefreshIndicator(onRefresh: bloc.refresh)`. `bloc.refresh()` adds `FeedRefreshRequested` and returns a Future that completes when `isRefreshing` becomes false, so the spinner stays until the work finishes. `droppable()` means no overlapping refreshes.

`FeedRepositoryImpl.refresh()` ([feed_repository_impl.dart:82](../lib/data/repositories/feed_repository_impl.dart#L82)):
1. `since = lastFeedSyncTime ?? now - 1 day` → `api.getFeedUpdates(since)` (returns new/updated/deleted ids + serverTime). Persist `serverTime` as the new sync cursor.
2. For each **deleted** id → `store.removeArticle`.
3. Re-fetch page 1 (`head`) → `withLocalState` → upsert.
4. Rewrite the snapshot as `head + (older snapshot items not in head and not deleted)`. The older pages stay cached, and the snapshot's cursor is preserved.

Bloc merge: `[...head, ...existing not in head and not deleted]`. Existing scroll position is preserved because items keep their `ValueKey`. It counts `newCount` (head ids not previously in the list) and shows a "N new stories" snackbar via `FeedState.notice`. Offline → `isStale: true` + "You are offline — showing saved stories." Other errors → "Could not refresh."

Note the design point: `getFeedUpdates` supplies the **deleted ids and the sync cursor**, while the fresh state of new and updated articles comes from re-fetching the head. Updated articles that are *below* page 1 are not re-fetched (see the conflict demo, §6).

### 4.6 Topic filter (feed)

`FeedTopicSelected(topicId)` (`restartable()`): clears articles and cursor immediately, then reuses `_onStarted`. Each topic has its own snapshot key (`topic|*`), so its cache is separate. Selecting the same topic is a no-op.

### 4.7 Search

`TextField.onChanged` → `SearchQueryChanged` → transformer `debounceRestartable(400ms)` ([bloc_transformers.dart](../lib/core/utils/bloc_transformers.dart)): rxdart `debounceTime` **then** `restartable()`.

- Debounce = "wait until typing pauses for 400 ms", which means one request per burst.
- Restartable = "if a new query arrives while a request is in flight, cancel the old handler", so a **slow old response can never overwrite newer results** (a stale emit from a cancelled handler is dropped).

`_execute`: status `loading` → `SearchRepository.search`:
- **Online:** `api.search` → `withLocalState` → `upsertArticles` (so search hits enter the offline cache) → return.
- **Offline:** search locally through `store.allArticles()` (title/summary/tags contains), filtered by topic and source, sorted newest first, `isStale: true`, no pagination.

Filters (topic chips, source menu) are separate events (`restartable()`) that re-run the current query. Changing topic reloads the sources list and keeps the chosen source only if it still belongs to that topic. Empty query → idle state, no request. Search results also subscribe to the bus, so a like from the feed shows up in search results and vice versa.

### 4.8 Opening an article

`ArticleDetailPage` creates an `ArticleDetailBloc` → `ArticleDetailRequested` (`restartable()`) → `ArticleRepositoryImpl.detail(id)` ([article_repository_impl.dart:24](../lib/data/repositories/article_repository_impl.dart#L24)):

- **Online, `ArticleDetailData`:**
  1. Fetch the detail from the API.
  2. **Merge rule:** if the locally cached article has `version >= server version`, keep the *local* article fields (they contain your fresh optimistic likes); otherwise take the server's.
  3. Overlay the bookmark from the `bookmarks` box (the local source of truth).
  4. `saveDetail` (details box and articles box).
  5. **Publish `ArticleChanged`**, so the feed card gets the freshest copy.
  6. Resolve up to 3 related articles from the local cache, and fetch missing ones from the API.
- **Online, `ArticleUnavailable`** (publisher deleted it): `removeArticle` + publish `ArticleRemoved` → every open list drops it → the bloc shows the "no longer available" state.
- **Offline (`NetworkException`):** serve `store.detail(id)` marked `isStale`, related items from local only. If there is no cache → `ArticleDetailError(isOffline: true)` with a retry button.

Liking on the detail page uses the same `EngagementBloc`. Its article row is a `BlocSelector` on `detail.article`, and the bloc updates that article via the bus (`ArticleChanged` for its own id).

### 4.9 Offline toggle → the outbox → reconnect (connectivity + sync)

**Going offline** (wifi icon or real airplane mode):
`setSimulatedOffline(true)` → `_emit` → `ConnectivityCubit` emits `isOnline=false` → `OfflineBanner` shows "You are offline — showing saved content", or "Offline — N changes will sync when you reconnect" when the outbox is non-empty. The pending count comes from `OutboxSyncService.pendingCount`, which re-emits on every Hive `outbox.watch()` event.

**Queuing while offline** — `_enqueue` in both repos:
```
1. find existing pending mutations with the SAME op AND SAME articleId → removeMutations(those keys)
2. enqueueMutation(new one with a fresh uuid + queuedAt = now)
```
This is **coalescing, last intent wins**. Like → unlike → like offline leaves one mutation. Like and bookmark on the same article are different ops, so they don't merge. Because the payload is a target state (not "+1"), replay is safe.

**Reconnect** — `OutboxSyncService` ([outbox_sync_service.dart](../lib/data/services/outbox_sync_service.dart)):

```
start()  (called once in DI)
  ├─ connectivity.onStatusChange → if online → syncNow()
  ├─ store.outboxChanges         → re-emit pending count
  └─ if already online at launch → syncNow()      (drains anything left from the last session)

syncNow()
  ├─ guard: if _syncing || offline → return       (no concurrent syncs)
  ├─ mutations = pendingMutations()  (sorted by queuedAt); if empty → return
  ├─ emit SyncStarted(n)                          → banner "Syncing n changes…"
  ├─ response = api.sync(mutations)               → ONE batched POST /sync
  ├─ removeMutations(response.applied)            → drained (idempotency keys)
  ├─ for each server article in response.conflicts:
  │     adopt server state (keep local isBookmarked) → upsert + publish ArticleChanged   ← SERVER WINS
  ├─ for each "settled" article (applied and not a conflict):
  │     republish the local stored article        → UI shows the agreed state
  ├─ emit SyncSucceeded(applied.length)           → banner "n changes synced" (3 s timer in the cubit)
  ├─ catch AppException → emit SyncFailed         → mutations STAY queued for the next reconnect
  └─ finally: _syncing = false; re-emit pending count
```

**What "conflict" means here:** a queued reaction whose target state the server *already has* (e.g. the server already says liked). The server returns its authoritative article; the client adopts it, so the count doesn't double-increment.

**Idempotency keys.** Each mutation has a uuid that the server would use to de-dupe a retry (the request may have succeeded but the response was lost). Honest caveat: the *mock* server doesn't dedupe by key. It marks the mutation applied, and the client removes it by key. The design supports it; the mock doesn't enforce it.

**Banner priority** ([offline_banner.dart](../lib/presentation/widgets/offline_banner.dart)): offline → syncing → "n synced" → stale ("pull to refresh") → hidden.

### 4.10 Bookmarks tab
`BookmarksBloc` loads `store.bookmarkedArticles()` once (from Hive, so it works fully offline) and afterwards follows the bus (§4.2). No pagination.

---

## 5. Concurrency cheat-sheet (`bloc_concurrency` transformers used)

| Bloc / event | Transformer | Why |
|---|---|---|
| Feed: started, topic selected | `restartable` | Latest intent wins, cancel stale loads |
| Feed: next page, refresh | `droppable` | Ignore duplicates while one runs |
| Search: query | `debounceRestartable(400ms)` | Fewer requests + no stale overwrite |
| Search: filters/retry | `restartable` | Same reason |
| Search: next page | `droppable` | No duplicate pages |
| Detail: requested | `restartable` | Retry cancels a stuck load |
| All: bus updates | `sequential` | Apply patches in order |
| Engagement: like / bookmark | `concurrent` | Independent articles shouldn't wait on each other; the repository's `_inFlight` set protects the *same* article |

---

## 6. Demo scripts (what to click in an interview)

1. **Optimistic + offline + outbox:** wifi-off toggle → like one, bookmark another → banner shows "2 changes will sync" → wifi on → "Syncing…" → "2 changes synced".
2. **Rollback:** online, like 3 articles quickly. The 3rd flips back with an error snackbar.
3. **Version conflict, one tap:** the very first like on the top story hits the conflict hook. The count jumps by more than +1 to the server's value.
4. **Stale cache:** go offline, pull to refresh → "showing saved stories" and the list still scrolls.
5. **Sync-time conflict:** like online → go offline → unlike → like again → back online. The queue is one `like` the server already has, so it returns as a conflict and the server state is adopted.
6. **Deleted article:** refresh twice; opening the deleted story shows "no longer available".

---

## 7. Likely interview questions, with answers

**"What happens when the user likes an article?"** §4.1, in one breath: tap → `EngagementBloc` (concurrent) → `ReactionRepository.toggleLike` → in-flight guard → optimistic write to Hive + publish on the bus → every bloc patches its list, UI flips instantly → then API with `expectedVersion` → success (adopt server count/version), conflict (server wins), network error (queue in outbox), other error (roll back + rethrow → snackbar).

**"Why does the UI update if EngagementBloc holds no article state?"** The repository publishes canonical articles on the `ArticleUpdateBus`; the list blocs patch themselves. That decouples features and avoids bloc-to-bloc references.

**"How does the local store work internally?"** §2.2: six `Box<String>` boxes with JSON values; boxes load fully into memory so reads are synchronous; `articles` is the canonical copy; the feed snapshot stores only ids; bookmarks and outbox are separate boxes; every write goes through `withLocalState`.

**"What does offline mean here?"** Reads: network-first, fallback to snapshot with `isStale`. Writes: local-first, queued in the outbox. Bookmarks and reactions work offline; pagination stops at the cached window.

**"What's an outbox and why coalesce?"** A durable queue of intents (survives app restarts because it is in Hive). Coalescing keeps only the last intent per (op, article), which is correct because the payload is a desired end state (idempotent toggle).

**"What if the app is killed while offline?"** The outbox is on disk. `OutboxSyncService.start()` runs at launch and calls `syncNow()` if online, and also triggers on the next reconnect.

**"How do you avoid duplicate/double-applied mutations?"** Client: `_inFlight` guard, coalescing, applied keys removed. Protocol: a uuid idempotency key per mutation (the mock doesn't dedupe by key, but it is in the contract).

**"How do you handle conflicts?"** Two places. Online: `expectedVersion` → `ReactionConflict` → server wins. On sync: a mutation that matches server state returns the server article as a conflict → server wins. There is deliberately no merge UI for a like toggle.

**"Why not use cases?"** The repository interface is the domain boundary. A one-line use case would just add indirection.

**"Why Hive over sqflite?"** Storage schema = wire format, no codegen, pure-Dart unit tests. A relational store pays off with real data volume and queries.

**"How do you test this?"** [reaction_repository_test.dart](../test/data/reaction_repository_test.dart) covers optimistic, rollback, conflict, duplicate guard, offline queue, queued like surviving a feed load, and sync republish. The bookmark test uses a real Hive store in a temp dir and simulates a restart. Search and feed have bloc tests (debounce and stale-response cases included).

---

## 8. Known limits (say these before they ask)

- **No retry/backoff for sync.** A failed sync waits for the next reconnect. The `_syncing` guard also means a mutation queued *during* a sync waits for the next trigger.
- **Last-intent coalescing is only valid for idempotent toggles.** "Post comment" would need per-op rules.
- **Server-wins conflict policy**, no merge UI.
- **Connectivity = interface state**, not real reachability.
- **Topics/sources are memoized only in memory.** A first launch offline shows no filter chips.
- **Search offline** only searches what was cached; no offline pagination.
- **The mock does not dedupe by idempotency key** or enforce `clientMutationId` on `setReaction`.
- **Dead code:** `FeedRepositoryImpl.cacheTtl` / `isExpired` and `CacheMissException` are defined but unused. The snapshot has a `savedAt`, but nothing enforces expiry.

---

## 9. Real issues I found while tracing (verify before the interview)

### 9.1 Bug (reproduced): three offline toggles on the same article end in the wrong UI after sync

Cause: in `toggleLike`, `_commit(optimistic)` runs **before** `_enqueue`. `_commit` → `upsertArticles` → `withLocalState`, which re-applies the *previous* queued intent from the outbox on top of the new optimistic value. So the store briefly holds the old intent, and the queue is replaced afterwards.

I reproduced this with a throwaway test (already deleted). Article starts unliked, 10 likes, offline, toggling three times:

```
toggle 1: UI liked=true  likes=11 | STORE liked=true  likes=11 | queue=[like]
toggle 2: UI liked=false likes=10 | STORE liked=true  likes=11 | queue=[unlike]   ← store disagrees with UI
toggle 3: UI liked=true  likes=11 | STORE liked=false likes=10 | queue=[like]     ← still disagrees
after sync: UI liked=false likes=10   (server applied: like)                       ← WRONG: server has it liked
```

The sync path republishes `store.article(id)` for settled mutations, so it republishes the wrong stored copy. Two-toggle round trips (like→unlike, unlike→like) are masked because they resolve as a *conflict* and the server article is adopted, which is why the existing tests and the README demo don't catch it.

Likely fix if you want one (small): enqueue first and commit after (so the pending intent already matches), or have `_commit` bypass the overlay for the explicit user-intent write. Add a test for three consecutive offline toggles. I didn't change any code.

Being able to say "I found and reproduced an edge case in my own outbox design, and here's the fix" is a strong interview answer.

### 9.2 Uncommitted working-tree edits change behaviour

`git status` shows 2 modified files:
- [article_detail_bloc.dart](../lib/presentation/blocs/article_detail/article_detail_bloc.dart): the working tree only handles `ArticleChanged` for the open article. HEAD *also* handled `ArticleRemoved` (open detail switches to the "gone" state) and updates to the related list. If you commit this, the README's "opening/keeping a removed article gracefully" story still holds for open-time removal, but **live removal while the detail page is open no longer shows the unavailable state**.
- [article_repository_impl.dart](../lib/data/repositories/article_repository_impl.dart): only removes a comment above the bookmark overlay (leaves a whitespace-only line). It's worth restoring the comment, because it explains a non-obvious rule.

### 9.3 Deleted-then-bookmarked article can reappear after restart
`removeArticle` (used on deletion) clears `articles` and `details` but not the `bookmarks` box. The Bookmarks tab is built from that box, so a bookmarked story that the publisher removed can come back after an app restart, even though opening it says "unavailable". Also, `refresh` removes deleted ids from Hive but doesn't publish `ArticleRemoved`, so the Bookmarks tab only drops it when the article is opened.
