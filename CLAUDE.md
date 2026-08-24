# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Identity

**lifeos** — BELTECH Personal Management App. A full Flutter port of the Kotlin Multiplatform (CMP) LifeOS app. The goal is a 1:1 pixel/behavioral parity with the Kotlin original; every screen, animation timing, dialog vs. fullscreen choice, and data format must match the Kotlin reference exactly. Deviations must be documented in `PARITY_AUDIT.md`.

Target device: Android (arm64). The APK is sideloaded via ADB onto a physical device (`3B6615002KJ00000`, CPH2813, Android 16/API 36).

---

## Commands

```powershell
# Analyze (must stay 0 errors)
flutter analyze lib

# Test (17 parser parity + 1 pipeline stress = 18 total)
flutter test
flutter test test/sms_parser_test.dart   # run a single file

# Build + install to connected phone
flutter build apk --release --target-platform android-arm64
flutter install --device-id 3B6615002KJ00000

# Regenerate Drift DAOs after schema changes
dart run build_runner build --delete-conflicting-outputs

# Hot-reload dev run (use Chrome only for quick UI iteration; logic must be verified on Android)
flutter run -d 3B6615002KJ00000
```

When schema tables change, always regenerate: `dart run build_runner build --delete-conflicting-outputs`. The generated file is `lib/core/database/database.g.dart` — never edit it manually.

---

## Architecture

### Layer Map

```
lib/
  main.dart                    — WidgetsFlutterBinding, SharedPrefs bootstrap,
                                 ProviderContainer, GoRouter wiring, themeController
  navigation/
    app_router.dart            — GoRouter, _SessionRefreshListenable, MainShell,
                                 guard logic, all route definitions
    routes.dart                — AppRoute constants (string slugs)
  ui/
    splash/splash_screen.dart  — PersonalOsSplashScreen (animation only)
    theme/                     — LifeOsColors ThemeExtension, kLifeOsTypography,
                                 buildLifeOsApp(), AppThemeMode enum
  core/
    database/
      tables.dart              — 30 Drift Table classes (schema source of truth)
      database.dart            — @DriftDatabase, pragmas, views, DAO methods
      database.g.dart          — generated; do not edit
    designsystem/              — shared UI primitives (see below)
    platform/sms_bridge.dart   — MethodChannel to Android (readInbox/drainQueue)
    security/
      biometric_lock.dart      — BiometricLockCoordinator widget
      session_store.dart       — SessionStore, SessionNotifier, sharedPrefsProvider,
                                 sessionStoreProvider, sessionProvider, sessionChanges
    utils/date_utils.dart      — formatCurrency, formatRelativeTime, AppDateUtils
  features/
    auth/                      — AuthScreen, OnboardingScreen (5 steps)
    dashboard/data/            — DashboardRepository, providers (lifeOsDatabaseProvider,
                                 userIdProvider, dashboardDataProvider)
    finance/                   — FinanceScreen, dialogs, widgets, FinanceRepository
    planner/                   — PlannerScreen (hub), BudgetScreen, IncomeScreen,
                                 RecurringScreen, BillsScreen, GoalsScreen, PlannerRepository
    calendar/                  — CalendarScreen (3 tabs), CalendarAddScreen, CalendarRepository
    home/                      — HomeScreen (aurora backdrop, greeting, metric row, menu cards)
    assistant/                 — AssistantScreen, offline deterministic engine
    profile/                   — ProfileScreen (hero + Tool Hub grid)
    settings/                  — SettingsScreen (reactive theme, biometric, notifications)
    sms/                       — Full SMS stack (see below)
    misc_screens.dart          — All secondary screens: Insights, Search, Review, Export,
                                 Tasks, ScreenLock, Notifications, SmsImportHealth,
                                 ReviewQueue, Quarantine, PaybillRegistry, Events,
                                 Categorize, FeeAnalytics, Learning, Changelog
```

### State Management

Riverpod 3 with `ProviderContainer` created in `main()` and passed to `UncontrolledProviderScope`. The container is also passed into `buildAppRouter()` so the router can `container.read()` providers synchronously in the redirect callback.

Key providers:
- `sharedPrefsProvider` — `FutureProvider<SharedPreferences>` (root of the async bootstrap chain)
- `sessionStoreProvider` — `FutureProvider<SessionStore>` (depends on sharedPrefsProvider)
- `sessionProvider` — `NotifierProvider<SessionNotifier, AppSessionState>` (reactive session snapshot)
- `lifeOsDatabaseProvider` — `FutureProvider<LifeOsDatabase>` (Drift DB singleton)
- `userIdProvider` — derived from sessionProvider
- `dashboardDataProvider` — derived from DB + userId

### Navigation & Routing (Critical)

The router's `redirect` holds all traffic at `/` (splash) until `sessionStoreProvider.value != null`. `_SessionRefreshListenable` must listen to **both** `sessionChanges` (login/logout signals) **and** `sessionStoreProvider` (async bootstrap completion) — otherwise the app gets stuck on the splash screen permanently.

Route categories:
1. **Splash** — `/` → `PersonalOsSplashScreen`
2. **Auth flow** — `/onboarding`, `/auth` — outside the ShellRoute
3. **Primary tabs** (inside `ShellRoute` + `MainShell`) — `/home`, `/finance`, `/calendar`, `/assistant`, `/profile`
4. **Secondary push routes** — everything else; pushed above the shell with slide+fade (220ms)

Tab swap = crossfade only (160ms in / 120ms out). Push = fade + width/6 horizontal slide (220ms).

### Design System (`lib/core/designsystem/`)

| File | Contents |
|---|---|
| `tokens.dart` | `AppSpacing` (xs4…xxl32, screenHorizontal 8, bottomSafeWithFloatingNav 220), `AppDesignTokens` (nav bar 58dp, offset 4dp, elevations, motion durations) |
| `app_card.dart` | `AppCard` — 6dp radius, surfaceContainerLowest, configurable padding |
| `glass_card.dart` | `GlassCard` — blur backdrop, used on Home hero |
| `metric_card.dart` | `MetricCard`, `BudgetProgressIndicator` |
| `page_scaffold.dart` | `PageScaffold` (title/subtitle/back/action bar), `HeroSurface`, `CompactHeader`, `EmptyState`, `BottomSafeWithFloatingNav` content padding helper |
| `controls.dart` | `SearchField`, `SegmentedControl`, `LifeOsSwitch`, `CalendarEventChip` |
| `banners.dart` | `TopBanner` (success/error float), `ImportHealthPanel`, shimmer states |
| `task_row.dart` | `TaskRow` (priority stripe color, completion state) |
| `floating_pill_nav_bar.dart` | `LifeOsBottomBar` with `GradientBoxBorder` |

Currency format: `"KSh " + amount.toLong()` (truncation, not rounding), grouped integer. This is done by `AppDateUtils.formatCurrency`.

### Database (Drift)

30 tables in `lib/core/database/tables.dart`. All column names use Kotlin-matching snake_case via `.named('...')`. Key tables: `transactions`, `budgets`, `income_streams`, `recurring_rules`, `tasks`, `calendar_events`, `goals`, `fuliza_snapshots`, `paybill_registry`, `quarantine_messages`, `review_corrections`.

Pragmas set at open: WAL mode, `synchronous=NORMAL`, 64 MB cache, MEMORY temp store, 256 MB mmap, 5s busy timeout.

Two views: `daily_spending_summary`, `monthly_spending_summary` — used by Finance and Dashboard aggregations.

### SMS Parsing Stack (`lib/features/sms/`)

Pipeline (in order):
1. `SmsNormalizer` — Unicode normalisation, whitespace collapse
2. `InstitutionDetector` — keyword fast-path to institution enum
3. `SmsConfidenceScorer` — 6-factor weighted score (0.0–1.0)
4. `SimpleMpesaParser` + feature extractor + decision tree
5. `CrossParserVoter` — agreement across parsers
6. `MpesaParserEnhanced` — 6-stage regex pipeline for all Safaricom templates
7. `GenericBankParser` — equity/kcb/co-op fallback
8. `AirtelMoneyParser`
9. `ParserPipeline` — wires all the above; returns `ParsedTransaction?`

Ingestion: `IngestionPipeline` uses an isolate pool (`ParserIsolatePool`, 4 isolates), chunks 200 SMS per batch, writes each chunk in a single Drift transaction. Dedupe is 4-tier O(1): mpesa_code → source_hash → semantic_hash → ±5min heuristic.

### Theme

`LifeOsColors` is a `ThemeExtension<LifeOsColors>` with a full 400ms animated lerp across the entire color extension when the theme mode changes. The global `themeController` (`ValueNotifier<AppThemeMode>`) in `main.dart` drives this without requiring a restart. `AppThemeMode` has three values: `system`, `light`, `dark`.

### Android Platform

`android/app/src/main/` contains:
- `MainActivity.kt` — `MethodChannel("lifeos/sms")` handling `readInbox`, `drainQueue`, `checkPermissions`
- `SmsBroadcastReceiver.kt` — listens for incoming SMS, queues them
- `BootReceiver.kt` — restarts the queue listener on device boot
- Manifest: `READ_SMS`, `RECEIVE_SMS`, `RECEIVE_BOOT_COMPLETED` permissions

---

## Known Stubs (Intentional Deltas)

These are `EmptyState` placeholders awaiting full implementation — they are not bugs:

- `ReviewScreen` — weekly review UI (shell only)
- `ExportScreen` — export to JSON/PDF (stub; share_plus wired but file write not yet connected)
- `ScreenLockSettingsPage` — biometric config UI (toggle exists in Settings but sub-page is stub)
- `NotificationSettingsPage` — notification preferences sub-page
- `SmsImportHealthPage` — shows static zeros (ImportHealthPanel not wired to live counts)
- `ReviewQueuePage` — medium-confidence transaction approval queue (DB table exists, UI empty)
- `QuarantinePage` — low-confidence SMS list (DB table exists, UI empty)
- `PaybillRegistryPage` — biller list (DB populated on import, UI empty)
- `CategorizePage` — bulk categorization flow (empty)
- `FeeAnalyticsPage` — fee breakdown (empty)
- `LearningPage` — study tracker (empty)
- CART on-device classifier — returns null until ≥50 Review Queue corrections
- Assistant LLM proxy — offline engine only; activates when `ASSISTANT_PROXY_URL` env var is set
- WorkManager periodic workers — registered, schedules not tuned
- OTA update checker — DB plumbing exists, UI prompt not surfaced

---

## Parity Rules

When adding or modifying any screen:
1. Match Kotlin animation timings exactly (they are documented in `PARITY_AUDIT.md` and in-file comments).
2. Dialogs that are `AlertDialog` in Kotlin must stay `AlertDialog` in Flutter (never full-screen). Calendar-add is the only exception — it is a full-screen push.
3. Content behind the floating pill bar must reserve `AppSpacing.bottomSafeWithFloatingNav` (220dp) of bottom padding.
4. After any change run `flutter analyze lib` — zero errors required before committing.
