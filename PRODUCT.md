# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Primary: Belinze Newtone — personal financial management on a daily basis. Opens the app to check MTD spend, review automatic M-Pesa imports, manage budgets and goals, and get an AI summary of financial health. Near-future expansion targets individual Kenyan smartphone users who receive M-Pesa SMS and want automatic tracking without manual entry.

## Product Purpose

LifeOS is a personal financial management app for Kenyans that automatically ingests every M-Pesa SMS from the device inbox, parses it with a multi-stage confidence pipeline, and presents a complete spending picture — all without the user ever typing a transaction manually. The app also manages budgets, goals, recurring bills, calendar events, and tasks in one place.

## Positioning

The only personal finance app that combines zero-touch Safaricom M-Pesa SMS parsing with fully offline, device-local storage. No server. No cloud sync. No data ever leaves the phone. Competing apps (Droo Finance, bank apps) require manual input or cloud accounts; LifeOS reads the inbox and classifies automatically.

## Operating Context

- Used on a physical Android 16 device (CPH2813), sideloaded via ADB
- M-Pesa SMS messages are the primary data source — received in real time and on first import
- Currency is KSh (Kenyan Shilling), displayed as "KSh X" with truncation (not rounding)
- Users may have Fuliza (M-Pesa overdraft) balances that need separate tracking
- App is used personally today; roadmap targets general individual users (public release)

## Capabilities and Constraints

- SMS ingestion: reads device inbox via MethodChannel, 4-tier deduplication, isolate pool parsing
- Parsers: M-Pesa Enhanced, Airtel Money, Generic Bank (Equity, KCB, Co-op)
- Offline-only: Drift SQLite on device, no network calls for core data
- AI Assistant: offline deterministic engine; richer responses when ASSISTANT_PROXY_URL is set
- Bottom floating pill navigation (5 tabs): Home, Finance, Calendar, Assistant, Profile
- Biometric lock via BiometricLockCoordinator
- Theme: Light / Dark / System (400ms animated transition across full color extension)
- Target: Android arm64; Chrome used only for quick UI iteration, not for logic verification

## Brand Commitments

- Product name: LifeOS
- Developer: BELTECH (Belinze Newtone)
- Aurora gradient is a signature visual on the Home hero (indigo + violet radial gradients)
- App greeting: "Good [time of day], [firstName] 👋🏽"
- No rounding on KSh — always truncate to integer

## Evidence on Hand

- Full Flutter codebase at C:\Users\BELINZE NEWTONE\Music\FLUTTER
- CLAUDE.md: authoritative architecture, screen inventory, parity rules
- PARITY_AUDIT.md: Kotlin reference deltas
- Droo Finance (droofinance.com): design inspiration reference — dark theme, indigo primary, grouped nav, MTD stats, daily insights, AI coach

## Product Principles

1. **Zero friction** — every KSh the user spends should appear automatically, without a tap.
2. **Privacy as a feature** — data stays on the device; trust is never traded for convenience.
3. **Precision over decoration** — financial numbers are displayed with monospace fonts, correct signs, and semantic color; never rounded, never obscured.
4. **Local first, AI assisted** — the offline engine answers first; the proxy enhances when available.
5. **Parity with intent** — design decisions reference the Kotlin original; deliberate deviations are documented.

## Accessibility & Inclusion

No specific accessibility standard mandated yet. KSh amounts must remain legible in both light and dark themes with sufficient contrast.
