# News Feed — Flutter Take-Home Task

A news feed app with a paginated feed, debounced search, article details, offline-first bookmarks, optimistic reactions, and an offline mutation outbox — built against a local mock backend.

**Stack:** Flutter · BLoC · Drift (SQLite) · get_it · feature-first Clean Architecture · 41 tests

---

## Contents

- [Quick Start](#quick-start)
- [60-Second Demo](#60-second-demo)
- [The Mock Backend](#the-mock-backend)
- [If You Only Have Five Minutes](#if-you-only-have-five-minutes)
- [Architecture](#architecture)
- [Completed Scope](#completed-scope)
- [Offline & Synchronization](#offline--synchronization)
- [Testing](#testing)
- [Tradeoffs & Known Limitations](#tradeoffs--known-limitations)

---

## Quick Start

```bash
flutter pub get
flutter run
```

- Requires a recent stable Flutter (Dart SDK ≥ 3.10)
- Targets Android and iOS
- **No backend or configuration needed** — all data is served from JSON assets under `assets/mock/` through an in-process mock API client

---

## 60-Second Demo

The fastest way to see everything work:

1. Tap the **wifi-off toggle** in the feed app bar
2. **Like** an article → instant, even offline
3. **Bookmark** another
4. **Pull to refresh** → stale-cache banner appears, cached pages still scroll
5. Toggle back **online** → the outbox drains and every count reconciles
6. While online, **like 3 articles quickly** → the 3rd rolls back with an error snackbar

---

## The Mock Backend

The "server" is `MockApiClient` — an in-process class that behaves like a small news backend. Every behavior below is deliberate and reproducible on demand:

| Simulated behavior | How the engine does it | How to see it |
|---|---|---|
| **Network latency** | Every call waits a random 300–700 ms | Skeletons, spinners, and footer loaders are actually visible |
| **Going offline** | The **wifi icon in the feed app bar** makes every call throw `NetworkException` — even one already in flight | Toggle it on: offline banner appears, cached content keeps working. Real airplane mode (via `connectivity_plus`) behaves identically |
| **Reaction failure** | Every **3rd** reaction call returns a server error | Like 3 articles in a row — the 3rd flips back with an error snackbar (optimistic rollback) |
| **Someone else is using the app** | Each pull-to-refresh bumps exactly one story — likes +3 and version +1 — and it is always the story the refreshed page 1 pushes out of view | Note the **last story on the first page**, pull to refresh once, then scroll back down and like it: the server's count wins over your ±1 guess (version conflict). Deterministic, so it works every time |
| **Breaking news** | Each pull-to-refresh publishes one reserved story stamped "just now" | Pull to refresh: a new story appears at the top, existing scroll position is kept |
| **Publisher removes a story** | On the **2nd** pull-to-refresh, one story is deleted server-side | Bookmark something early, refresh twice: it vanishes from lists, and opening it shows a graceful "no longer available" state |
| **Reconnect sync** | Queued offline mutations replay in order through `POST /sync`; a queued reaction that the server already agrees with comes back as a conflict | Go offline, like + bookmark things, go back online — watch the outbox drain and counts reconcile. For the sync **conflict** path: like a story online, go offline, unlike then like it again (the queue coalesces to one `like` the server already has), then go back online |

---

## If You Only Have Five Minutes

The parts of the codebase that carry the most design weight, in reading order:

| # | File | Why it matters |
|---|---|---|
| 1 | `lib/core/articles/data/local/article_read_model.dart` | The one place server state and local intent meet: every DAO reads articles through this SQL join, which is how the feed, search, bookmarks and an open detail page stay consistent without knowing about each other |
| 2 | `lib/core/articles/data/local/app_database.dart` + `daos/` | The schema, and one DAO per table: each writes only its own table and reads the rest through joins |
| 3 | `lib/core/articles/data/repositories/reaction_repository_impl.dart` | Optimistic apply → confirm / conflict-reconcile / rollback, plus offline queueing with last-intent coalescing |
| 4 | `lib/core/sync/outbox_sync_service.dart` | What happens on reconnect: ordered replay, idempotency keys, server-wins conflicts |
| 5 | `test/core/articles/reaction_repository_test.dart` | Every failure path above (rollback, conflict, offline queueing, coalescing) exercised end to end against a real in-memory SQLite database |

---

## Architecture

Feature-first Clean Architecture with BLoC for state management. Each feature owns its screen, bloc and repository; everything that is about *an article* lives once in `core/articles`.

```
lib/
├── main.dart
├── app/                     # App widget, home shell, DI composition root (get_it)
├── core/
│   ├── articles/            # The shared article module
│   │   ├── domain/          # Article, ArticleDetail, Topic entities; Bookmark/Reaction/Topic repositories
│   │   ├── data/
│   │   │   ├── local/       # AppDatabase (Drift), ArticleReadModel, DbTransaction, daos/ (one per table)
│   │   │   ├── remote/      # ApiClient interface + MockApiClient (asset-backed "server")
│   │   │   ├── models/      # JSON mapping (wire format ↔ entities)
│   │   │   └── repositories/
│   │   └── presentation/    # EngagementBloc (like/bookmark), ArticleCard, PaginatedArticleList
│   ├── sync/                # SyncService + OutboxSyncService, ConnectivityCubit, OfflineBanner
│   ├── network/  error/  theme/  utils/  widgets/
└── features/
    ├── feed/                # domain/ FeedRepository · data/ impl · presentation/ bloc + page
    ├── search/
    ├── bookmarks/
    └── article_detail/
```

Dependencies point one way: features depend on `core`, `core` never imports a feature. The only feature-to-feature link is navigation (`ArticleDetailPage.open`), which the shared list receives as an `onOpen` callback.

### Key decisions

**The database is the single source of truth; the UI watches it.**
Repositories write network results into SQLite and expose Drift `watch()` queries; blocs subscribe to those streams. A like on the feed is one row change, and every screen showing that article re-emits on its own: nothing publishes change events, and a screen that subscribes late still gets the current value.

**One DAO per table, composed in SQL.**
`ArticlesDao`, `BookmarksDao`, `ArticleDetailsDao`, `FeedDao` and `OutboxDao` each write only their own table. Reading an article always joins the bookmark row and any queued reaction (`ArticleReadModel`), so no DAO depends on another: they share tables, not classes.

**Server state and local intent live in separate tables.**
`articles` holds only what the server said. "Bookmarked" is a row in `bookmarks`; an unconfirmed like is a row in `pending_mutations`, which doubles as the optimistic state. A network upsert therefore cannot erase a local action, and rollback just deletes (or restores) the queued row.

**Repositories get the DAOs they need, not the database** (`app/injector.dart`).
Writes that must span tables go through a small `DbTransaction`. Tests build repositories over a real in-memory database instead of a hand-written fake.

**Typed failures** (`NetworkException`, `ServerException`, `NotFoundException`).
Thrown by the data layer; blocs map them to distinct UI states instead of string-matching errors.

**Blocs talk to repositories directly** (no separate use-case classes).
At this scope, one-line use cases would only add indirection; the domain boundary is the repository interface. This is a deliberate SOLID-over-ceremony tradeoff.

---

## Completed Scope

| Story | Status | Notes |
|---|---|---|
| US1 Discover | Done | Paginated feed with headline, image, source, topic, time, likes/comments; topic filter chips |
| US2 Refresh | Done | Pull to refresh prepends new items, dedups by id, updates changed items, keeps scroll window |
| US3 Search | Done | 400 ms debounce in the bloc (rxdart `debounceTime` + `restartable()`), stale-request cancellation, topic + source filters preserved across queries |
| US4 Details | Done | Typed content blocks (paragraph/image/quote — unknown types dropped safely), author bio, tags, related stories |
| US5 Bookmark | Done | Local-first, persisted in SQLite, dedicated tab, fully offline across sessions |
| US6 Reactions | Done | Optimistic toggle, in-flight duplicate guard, confirm/reconcile/rollback (the mock server fails every 3rd reaction to make rollback demonstrable) |
| US7 Consistency | Done | `/feed/updates`-style reconciliation: refresh applies new/updated/deleted ids; opening a removed article shows a graceful "unavailable" state and drops it from open lists |
| US8 Offline | Done | Feed pages + details cached in SQLite; offline banner; bookmarks and reactions work offline and queue in the outbox |
| US9 Resilience | Done | Distinct skeleton/loading, empty, full-screen error, page-level error (footer retry), and stale-data states |

**Also included:**
- Light/dark theme following the system setting
- Semantic labels/tooltips on actions
- Cached, decode-size-capped images (`AppNetworkImage` over `cached_network_image`)
- `const`-heavy widgets and `Equatable` states to limit rebuilds

**Bonus items** (deep links, live "new stories" prompt, golden tests) were intentionally left out per scope guidance. The outbox — listed under both bonus and the core *Synchronization* requirement — **is** implemented.

---

## Offline & Synchronization

**Reads — network-first.**
On `NetworkException`, the repository serves the persisted snapshot (everything the user had loaded, not just page 1) flagged `isStale`, and the UI says so honestly. Search falls back to searching the local article cache offline.

**Writes — local-first / optimistic.**
Bookmarks commit locally first and sync best-effort. Reactions apply optimistically; if the device is offline (or drops mid-request) the optimistic state is kept and the mutation is queued.

**Outbox.**
Each queued mutation carries a UUID idempotency key. Repeated toggles of the same article are **coalesced** to the final intent (an offline like + unlike never replays as two mutations). On reconnect, `OutboxSyncService` replays the queue in order through `POST /sync`; applied mutations are removed and conflicting ones adopt the authoritative server state; because every screen watches the database, the UI reconciles on its own.

**Reaction conflicts online.**
Requests carry `expectedVersion`; on a version conflict the server state wins and replaces the optimistic guess.

---

## Testing

```bash
flutter test
```

**41 tests** covering the required business logic:

| Area | File | Covers |
|---|---|---|
| Feed pagination | `test/features/feed/feed_bloc_test.dart`, `feed_repository_test.dart` | First page, append + dedup, page-level failure that preserves the list + retry, refresh reconciliation, offline fallback |
| Search debounce | `test/features/search/search_bloc_test.dart` | One request for rapid keystrokes, a stale in-flight response can never overwrite newer results, filters preserved, results stay live |
| Bookmark persistence | `test/core/articles/bookmark_repository_test.dart` | Real SQLite file in a temp dir, survives a simulated restart (close + reopen), offline queueing and coalescing |
| Reaction rollback | `test/core/articles/reaction_repository_test.dart` | Optimistic apply, exact rollback on failure, conflict reconciliation, duplicate-submission guard, offline queueing, outbox sync |
| Widget test | `test/features/feed/feed_page_test.dart` | The primary state transition (skeleton → loaded list), plus error-with-retry and empty states |

---

## Tradeoffs & Known Limitations

**Drift (SQLite) over a key-value store.**
The app's core question, "this article, plus whether I bookmarked it, plus any like still waiting to sync", is a join. In a key-value store that join is hand-written Dart, which forces every read into one class that can see every box. In SQLite it is one query, which is what lets each table have its own DAO, gives transactions and foreign-key cascades (a story the publisher deletes disappears from every feed, bookmark and detail at once), and makes `watch()` streams possible. The cost is code generation (`build_runner`) and a schema to migrate.

**rxdart for search debounce.**
The debounce transformer started as a hand-rolled `Timer`/`StreamController` implementation (~30 lines of stream plumbing) and was replaced with rxdart's `debounceTime` — one line, battle-tested, and rxdart was already in the dependency tree transitively. The tradeoff is one more direct dependency for a single operator; taken because less code to review beats demonstrating stream internals. The composition with `restartable()` (the part that actually prevents stale results) is unchanged and still covered by tests.

**Reactive queries instead of an event bus or bloc-to-bloc coupling.**
Cross-screen consistency (US7) comes from every screen watching the same tables, not from blocs listening to each other, a shared "app state" bloc, or an event bus. An earlier version used a custom broadcast bus of article changes; it worked, but every writer had to remember to publish and late subscribers missed events. With the database as the source of truth, there is nothing to forget. The tradeoff is that search results, which are not persisted as a list, keep their ids in the bloc and re-subscribe to those rows whenever the result set changes.

**`AppNetworkImage` over raw `CachedNetworkImage`.**
One shared widget wraps every network image so the placeholder/error look lives in one place, and — more importantly — it caps decode size with `memCacheWidth` derived from the actual layout slot (× device pixel ratio, quantized to 50 px steps, capped at 1600 physical px). Full-resolution images never sit decoded in memory for card-sized slots. The tradeoff is a small indirection layer and re-decoding on real layout changes such as rotation, which is the correct behavior anyway.

**Optimistic updates guess, the server decides.**
A like flips the UI instantly with a locally computed count (±1), which can be briefly wrong if others reacted meanwhile — accepted because instant feedback matters more than a transiently off-by-a-few counter. The server response (or a version conflict) replaces the guess with the authoritative count. Conflict resolution is deliberately **server-wins** with no merge UI: for a like toggle there is nothing meaningful to merge, so simplicity beats a conflict dialog nobody would want.

**Outbox coalescing is last-intent-wins.**
An offline like + unlike collapses to the final state instead of replaying the full history. That discards intermediate mutations by design — correct for idempotent toggles, but the outbox as built would need per-op replay rules before carrying non-idempotent mutations (e.g. "post comment").

**Smaller notes:**

- **Sync replays in order, once per reconnect** — no retry/backoff schedule per mutation; a mutation that fails with a network error stays queued for the next reconnect. Cross-device sync is out of scope: the outbox assumes one device's queue against one server, which the idempotency keys would support extending later.
- **No use-case layer** — repository interfaces are the domain boundary (see [Architecture](#architecture)).
- **Offline pagination stops at the cached window** — by design; the UI explains rather than spinning forever.
- **Topics/sources are memoized in-memory only**, so the filter bar starts empty if the very first launch is offline.
- **Search pagination reuses the page-number cursor of the mock**; a real backend cursor would slot into the same interface.
- **The mock server lives in-process** — latency, failures, versions, and deletions are simulated, but HTTP specifics (headers, transport-level retries) are out of scope by task definition.
