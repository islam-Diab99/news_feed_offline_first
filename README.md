# News Feed — Flutter Take-Home Task

A news feed app with a paginated feed, debounced search, article details, offline-first bookmarks, optimistic reactions, and an offline mutation outbox — built against a local mock backend.

**Stack:** Flutter · BLoC · Hive · get_it · Clean Architecture · 24 tests

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
| 1 | `lib/domain/services/article_update_bus.dart` | The one custom concept in the app: how the feed, search, bookmarks, and an open detail page stay consistent without knowing about each other |
| 2 | `lib/data/repositories/reaction_repository_impl.dart` | Optimistic apply → confirm / conflict-reconcile / rollback, plus offline queueing with last-intent coalescing |
| 3 | `lib/data/services/outbox_sync_service.dart` | What happens on reconnect: ordered replay, idempotency keys, server-wins conflicts |
| 4 | `lib/presentation/widgets/paginated_article_list.dart` | One list implementation (pagination, footer states, scroll retention) shared by all three tabs |
| 5 | `test/data/reaction_repository_test.dart` | Every failure path above (rollback, conflict, offline queueing, coalescing) exercised end to end |

---

## Architecture

Clean-architecture layering with BLoC for state management:

```
lib/
├── core/            # DI (get_it), typed exceptions, connectivity, theme, bloc transformers
├── domain/          # Pure Dart: entities, repository interfaces, ArticleUpdateBus, SyncService
├── data/
│   ├── datasources/
│   │   ├── remote/  # ApiClient interface + MockApiClient (asset-backed "server")
│   │   └── local/   # LocalStore interface + HiveLocalStore (cache, bookmarks, outbox)
│   ├── models/      # JSON mapping (wire format ↔ entities)
│   ├── repositories/# Feed, Search, Article, Bookmark, Reaction implementations
│   └── services/    # OutboxSyncService (drains queued mutations on reconnect)
└── presentation/
    ├── blocs/       # Feed, Search, ArticleDetail, Bookmarks, Engagement, Connectivity
    ├── pages/       # Feed, Search, Bookmarks, Article details, Home shell
    └── widgets/     # PaginatedArticleList (shared by all 3 tabs), ArticleCard,
                     # AppNetworkImage, OfflineBanner, skeletons, error/empty views
```

### Key decisions

**`ArticleUpdateBus` — an own-design piece, not a package.**
A broadcast stream of canonical article changes. Repositories publish after any mutation (like, bookmark, server reconciliation, deletion); every bloc holding a list patches itself. This is what keeps the feed, search results, bookmarks, and an open detail page consistent without any of them knowing about each other.

**Repositories behind interfaces, wired in one composition root** (`core/di/injector.dart`).
The mock API or the Hive store can be swapped without touching a single consumer — and tests do exactly that.

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
| US5 Bookmark | Done | Local-first, persisted in Hive, dedicated tab, fully offline across sessions |
| US6 Reactions | Done | Optimistic toggle, in-flight duplicate guard, confirm/reconcile/rollback (the mock server fails every 3rd reaction to make rollback demonstrable) |
| US7 Consistency | Done | `/feed/updates`-style reconciliation: refresh applies new/updated/deleted ids; opening a removed article shows a graceful "unavailable" state and drops it from open lists |
| US8 Offline | Done | Feed pages + details cached in Hive; offline banner; bookmarks and reactions work offline and queue in the outbox |
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
Each queued mutation carries a UUID idempotency key. Repeated toggles of the same article are **coalesced** to the final intent (an offline like + unlike never replays as two mutations). On reconnect, `OutboxSyncService` replays the queue in order through `POST /sync`; applied mutations are removed, conflicting ones adopt the authoritative server state and broadcast it so the UI visibly reconciles.

**Reaction conflicts online.**
Requests carry `expectedVersion`; on a version conflict the server state wins and replaces the optimistic guess.

---

## Testing

```bash
flutter test
```

**24 tests** covering the required business logic:

| Area | File | Covers |
|---|---|---|
| Feed pagination | `test/blocs/feed_bloc_test.dart` | First page, append + dedup, page-level failure that preserves the list + retry, refresh prepend/update/delete reconciliation |
| Search debounce | `test/blocs/search_bloc_test.dart` | One request for rapid keystrokes, a stale in-flight response can never overwrite newer results, filters preserved |
| Bookmark persistence | `test/data/bookmark_repository_test.dart` | Real Hive store in a temp dir, survives a simulated restart (close + reopen), offline queueing and coalescing |
| Reaction rollback | `test/data/reaction_repository_test.dart` | Optimistic apply, exact rollback on failure, conflict reconciliation, duplicate-submission guard, offline queueing |
| Widget test | `test/widgets/feed_page_test.dart` | The primary state transition (skeleton → loaded list), plus error-with-retry and empty states |

---

## Tradeoffs & Known Limitations

**Hive (`hive_ce`) over sqflite/drift.**
JSON-string values in Hive boxes keep the storage schema identical to the wire format with zero codegen, and the store is unit-testable in pure Dart. A relational store would pay off with real data volumes and queries; not at mock scale.

**rxdart for search debounce.**
The debounce transformer started as a hand-rolled `Timer`/`StreamController` implementation (~30 lines of stream plumbing) and was replaced with rxdart's `debounceTime` — one line, battle-tested, and rxdart was already in the dependency tree transitively. The tradeoff is one more direct dependency for a single operator; taken because less code to review beats demonstrating stream internals. The composition with `restartable()` (the part that actually prevents stale results) is unchanged and still covered by tests.

**A custom `ArticleUpdateBus` instead of bloc-to-bloc coupling or a package.**
Cross-screen consistency (US7) is solved with a hand-designed broadcast stream of canonical article changes — not with blocs listening to each other, a shared "app state" bloc, or an event-bus package. Direct bloc references couple every feature to every other, and a global state object forces all screens to rebuild together. The bus's own tradeoff: it is fire-and-forget (no replay for late subscribers — acceptable since every bloc loads its own data first and only needs deltas after that), and it is one custom concept a reviewer has to learn, which this section explains.

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
