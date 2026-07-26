# Flutter App Design for MyMenu

## Purpose

This document proposes how to structure MyMenu as a Flutter app inside the current repository, while keeping room for backend code and shared contracts.

It is designed around the product vision in [product-vision.md](/Users/yiouchen/dev/my_menu/docs/product-vision.md):

- image-first personal cooking memory
- offline-first core loop
- simple navigation
- local dish knowledge that gets richer over time
- AI and backend features as enrichment, not prerequisites

## Recommendation

If starting fresh, Flutter is a valid choice for MyMenu.

It fits well because:

- cross-platform visual consistency is a priority
- the app is mostly custom UI, image flows, forms, lists, and detail views
- offline-first matters
- the product does not rely on deep platform-native control conventions

I recommend:

- a monorepo layout
- a dedicated Flutter app folder instead of putting Flutter at repo root
- local-first architecture with Drift over SQLite
- Supabase as backend infrastructure, but not as the core client-side data model
- OpenAPI as the primary app-facing contract format
- generated Dart types for API DTOs and clients
- no protobuf as the primary contract layer for Supabase-backed features

## Proposed Repo Structure

Keep the repo multi-project from the start:

```txt
/
  apps/
    mobile_flutter/
  backend/
    api/
    supabase/
      migrations/
      functions/
      seed.sql
  contracts/
    openapi/
      openapi.yaml
  docs/
    product-vision.md
    flutter-app-design.md
```

### Folder Roles

`apps/mobile_flutter/`
- The Flutter app
- UI, navigation, features, local persistence wiring

`backend/api/`
- Optional custom backend service if product complexity grows beyond direct Supabase usage
- Likely TypeScript if you want a single backend language for services and functions

`backend/supabase/`
- migrations
- SQL functions
- Edge Functions
- storage policies
- auth and RLS setup

`contracts/openapi/openapi.yaml`
- Source of truth for app-facing HTTP contracts
- Used to generate strong Dart types and client code
- Can also generate backend types or stubs for TypeScript and other languages

## Why Not Put Flutter at the Root

I agree with your instinct not to make Flutter the top-level app if the repo will also host backend code.

Benefits:

- cleaner separation between app and backend concerns
- easier future addition of a web dashboard, admin tool, or scripts
- simpler CI per project
- less confusion around toolchains and generated files

Recommended path:

- create the app at `apps/mobile_flutter`
- reserve root-level `docs/`, `backend/`, and `contracts/` for shared assets and infrastructure

## Architecture Overview

The Flutter app should be local-first.

The most important rule:

- UI reads from local state
- local database is the source of truth
- network sync updates the local database
- background jobs retry failed mutations

That means the app remains usable when offline:

- browsing dishes
- editing notes
- planning meals
- capturing photos
- queueing AI actions

## App Layers

```txt
Flutter UI
  ->
Riverpod providers / notifiers
  ->
Repositories
  ->
Local DB + file store + remote APIs + sync queue
```

### UI Layer

Contains:

- screens
- reusable widgets
- view-specific controllers
- navigation

Should not:

- call Supabase directly
- build SQL queries
- decide sync policy

### Riverpod Layer

Riverpod is for:

- dependency injection
- screen state
- async loading state
- derived state

Use:

- `Provider` for dependencies and computed state
- `NotifierProvider` for synchronous feature state
- `AsyncNotifierProvider` for async feature state

### Repository Layer

Repositories are not a Riverpod concept. They are the domain data boundary.

Examples:

- `DishRepository`
- `PlanRepository`
- `CaptureRepository`
- `SyncRepository`
- `AiJobRepository`

Each repository can combine:

- Drift
- file storage
- Supabase REST/RPC
- Supabase Storage
- retry queue

### Local Persistence Layer

Use:

- `drift`
- `drift_flutter`

Backed by SQLite.

Store relational domain data locally:

- dishes
- dish notes
- ingredients
- recipe steps
- source photos
- planned meals
- sync jobs
- AI jobs

Store files locally:

- original source photos
- derived thumbnails
- generated covers

Use `path_provider` to choose safe app-local directories.

## Recommended Flutter Stack

### Core

- `flutter_riverpod`
- `go_router`
- `drift`
- `drift_flutter`
- `freezed`
- `json_serializable`
- `build_runner`

### Media and File Handling

- `image_picker`
- `camera` only if you want a custom in-app camera
- `photo_manager` if you need richer photo-library browsing
- `path_provider`

### Networking and Backend

- `supabase_flutter`
- optionally `dio` if you want a separate client for non-Supabase endpoints
- generated OpenAPI client for app-facing backend APIs if you introduce them

### Background / Sync

- `workmanager`
- `connectivity_plus` as a hint only, not as truth

### Optional

- `flutter_secure_storage`
- `cached_network_image`
- `dio` if your generated OpenAPI client uses it

## Feature-Oriented App Structure

Inside `apps/mobile_flutter/lib`:

```txt
lib/
  app/
    app.dart
    router.dart
    bootstrap.dart
  core/
    database/
    files/
    network/
    logging/
    utils/
  domain/
    dishes/
    planning/
    capture/
    ai/
    sync/
  features/
    plan/
    menu/
    dish_detail/
    capture/
    improve_cover/
    review/
  shared/
    widgets/
    theme/
```

### Layering Rule

`features/` can depend on:

- `domain/`
- `core/`
- `shared/`

`domain/` can depend on:

- `core/`
- shared pure Dart packages

`core/` should not depend on feature code.

## Offline-First Data Flow

### Read Path

1. UI watches provider
2. provider watches repository
3. repository streams rows from Drift
4. UI updates immediately from local DB

### Write Path

1. UI triggers action
2. repository writes local change immediately
3. repository adds sync job if remote write is needed
4. background sync attempts upload
5. success marks job complete and updates canonical fields
6. failure keeps job queued for retry

### AI Path

AI operations should be modeled as jobs, not direct UI dependencies.

Examples:

- group captures into cooking occasions by original local photo date
- generate dish from idea
- improve cover image

Flow:

1. user action creates local pending job
2. UI shows pending state
3. sync/worker calls Edge Function or API
4. returned result writes into local DB
5. UI reacts from local state

This keeps the app responsive even with slow or missing network.

Capture batch grouping uses a durable `batch_grouping` job created in the same
local transaction as the captures. Imported media keeps the original bytes and
stores its EXIF original local date when available. Photos with the same local
date are one cooking occasion; missing-date photos are kept as separate
occasions. The client finalizes only after every photo upload succeeds, then
polls sync events until the created dishes are hydrated locally.

## Suggested Drift Schema

Core tables:

- `dishes`
- `dish_notes`
- `ingredients`
- `recipe_steps`
- `source_photos`
- `planned_meals`
- `capture_items`
- `review_items`
- `ai_jobs`
- `sync_jobs`

Suggested extra columns:

- `updated_at`
- `deleted_at` for soft deletes where sync matters
- `sync_status`
- `remote_id` if local and remote identity ever need to diverge
- `version` or `updated_at` for conflict handling

## Sync Strategy with Supabase

Use Supabase for:

- auth
- Postgres
- Storage
- Realtime where useful
- Edge Functions for AI orchestration or privileged logic

Do not use Supabase as a replacement for local app architecture.

The mobile app should still own:

- local schema
- sync queue
- optimistic writes
- file lifecycle
- offline behavior

### Recommended Backend Access Patterns

Use three patterns:

1. direct table access for simple user-owned CRUD
2. Postgres RPC for structured business operations
3. Edge Functions for AI or privileged workflows

Examples:

- direct table reads for dish lists
- RPC for "plan this dish on date X" if it needs validation or side effects
- Edge Function for image analysis or cover generation orchestration

## Shared API Contracts

Yes, shared representations are a good idea.

But I would separate:

- database schema contracts
- app-facing API contracts
- internal event/job contracts

They should not all be the same thing.

### Best Fit for MyMenu

For app-facing contracts, prefer:

- OpenAPI for the source contract
- JSON over HTTP
- generated Dart DTOs and API client
- generated backend types or server stubs where useful

Recommended location:

```txt
contracts/
  openapi/
    openapi.yaml
```

Example schema fragment:

```yaml
components:
  schemas:
    ImproveCoverRequest:
      type: object
      required: [dishId, sourcePhotoPaths]
      properties:
        dishId:
          type: string
        sourcePhotoPaths:
          type: array
          items:
            type: string
        prompt:
          type: string
          nullable: true
```

This works naturally with:

- a TypeScript backend
- generated Dart API models
- generated TypeScript types
- standard REST
- local persistence mapping
- testing

## Protobuf Evaluation

### Short Answer

I would not use protobuf as the primary contract format between Flutter and Supabase.

### Why

Supabase is naturally centered around:

- Postgres
- PostgREST
- JSON payloads
- Edge Functions
- generated TypeScript, Go, and Swift types from schema introspection

That stack is JSON-native, not protobuf-native.

### What Becomes Awkward with Protobuf

If you choose protobuf as the main contract layer, you will likely need to add custom translation at the boundaries:

- Flutter protobuf objects
- JSON conversion for Edge Functions
- Postgres row mapping
- extra codegen and tooling
- more debugging friction in logs and network inspection

That is workable, but not elegant.

Also, Supabase's generated types from the CLI currently support TypeScript, Go, and Swift. I did not find first-party Dart generation from the database schema, which means protobuf would not give you a clean official bridge there either.

### Where Protobuf Could Still Make Sense

Protobuf is reasonable if one of these becomes true:

- you add a separate gRPC backend outside Supabase
- you have heavy internal event pipelines
- you need highly structured binary contracts between non-Supabase services
- you want one schema language for multiple non-JSON consumers

For MyMenu, that feels premature.

### Recommendation on Contracts

Use:

- SQL schema as the source of truth for backend persistence
- OpenAPI as the source of truth for app-facing HTTP contracts
- generated Dart API DTOs and clients from OpenAPI

Do not make `.proto` the primary contract source unless the backend moves toward gRPC or a separate service mesh.

## Supabase + Flutter: Recommended Boundary

The cleanest split is:

- Supabase tables and storage hold durable cloud state
- Flutter Drift schema holds local app state
- repositories map between the two
- OpenAPI defines any app-facing custom API surface you add beyond direct Supabase access

Important implication:

The Drift schema does not need to mirror Supabase 1:1.

It can include app-only tables like:

- `pending_uploads`
- `sync_jobs`
- `draft_notes`
- `cover_generation_jobs`

This is one of the main reasons local DB design should be owned by the app, not by a direct backend client.

## Example Repository Shape

```dart
class DishRepository {
  DishRepository(
    this.db,
    this.supabase,
    this.syncQueue,
  );

  final AppDatabase db;
  final SupabaseClient supabase;
  final SyncQueue syncQueue;

  Stream<List<Dish>> watchDishes() {
    return db.watchAllDishes();
  }

  Future<void> addDish(CreateDishInput input) async {
    final localDish = await db.insertDish(input);

    await syncQueue.enqueue(
      SyncJob.createDish(localDish.id),
    );
  }

  Future<void> refreshFromServer() async {
    final rows = await supabase.from('dishes').select();
    await db.upsertRemoteDishes(rows);
  }
}
```

## OpenAPI Code Generation

OpenAPI is a good fit if the backend is TypeScript and the client is Flutter.

Recommended approach:

- author `contracts/openapi/openapi.yaml`
- generate Dart client/models for Flutter
- generate TypeScript types or server scaffolding for backend code

For Dart, the most established path is OpenAPI Generator with the `dart-dio` target.

Notes:

- generated Dart network DTOs should usually stay separate from local Drift entities
- repositories map between generated API types and local app models
- this separation is especially helpful for offline-first fields like `syncStatus`, `pendingUpload`, or `localPhotoPath`

## Example Riverpod Wiring

```dart
final dishRepositoryProvider = Provider<DishRepository>((ref) {
  return DishRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(supabaseClientProvider),
    ref.watch(syncQueueProvider),
  );
});

final dishesProvider = StreamProvider<List<Dish>>((ref) {
  return ref.watch(dishRepositoryProvider).watchDishes();
});
```

## Migration / Delivery Plan

If you choose this direction, I would build in this order:

1. Create monorepo folders: `apps/`, `backend/`, `contracts/`
2. Scaffold Flutter app in `apps/mobile_flutter`
3. Add `contracts/openapi/openapi.yaml`
4. Add Riverpod, go_router, Drift, and OpenAPI generation workflow
5. Implement local schema only
6. Build MVP UI fully against local DB
7. Add local file storage for source photos and covers
8. Add sync jobs table and sync service
9. Add Supabase auth, storage, and basic CRUD sync
10. Add TypeScript Edge Functions for AI workflows
11. Add background retry and conflict handling

## Final Recommendation

For MyMenu, the strongest approach is:

- Flutter app in `apps/mobile_flutter`
- local-first architecture
- Drift over SQLite for the core app model
- Supabase for backend infrastructure, not as the app's primary state model
- OpenAPI in `contracts/openapi/openapi.yaml` for app-facing contracts
- generated Dart types and API client from OpenAPI
- no protobuf as the main client/backend contract format

If you want a single sentence summary:

Build Flutter as a local-first client with its own relational model, and let Supabase be the cloud system it syncs with, not the shape the app is forced to think in.

## Sources

- [Flutter offline-first guide](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)
- [Flutter SQL architecture guide](https://docs.flutter.dev/app-architecture/design-patterns/sql)
- [Flutter SQLite cookbook](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Drift documentation](https://drift.simonbinder.eu/)
- [drift_flutter package](https://pub.dev/packages/drift_flutter)
- [protobuf package for Dart](https://pub.dev/packages/protobuf)
- [protoc_plugin for Dart](https://pub.dev/packages/protoc_plugin)
- [ProtoJSON format](https://protobuf.dev/programming-guides/json/)
- [Supabase Flutter quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Supabase Dart/Flutter reference](https://supabase.com/docs/reference/dart/introduction)
- [Supabase generated types](https://supabase.com/docs/guides/api/rest/generating-types)
- [Supabase CLI reference](https://supabase.com/docs/reference/cli/introduction)
- [Supabase Data API](https://supabase.com/docs/guides/api)
