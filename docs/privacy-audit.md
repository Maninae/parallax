# Parallax Privacy Audit

**Date:** 2026-02-20
**Target:** Parallax macOS App Initialization Check

## Executive Summary
This document verifies that the Parallax project adheres strictly to its foundational core principle: **100% Local Operations and Zero Network Calls.**

Parallax is designed to be a private wrapper UI around the user's existing macOS Messages history. Ensuring that no sensitive chat data leaves the device is the highest priority.

## Verification Checklist

### 1. Data Source (`steipete/imsg`)
- [x] **Verified Local Paths:** The `IMsgCore` dependency is configured exclusively to read from `~/Library/Messages/chat.db`.
- [x] **No Cloud Syncing Elements:** The SQLite reads are raw and local. No sync engines or telemetry are present in the data fetching flow.
- [x] **Read-Only Enforced:** `MessageStore` instantiates its `Connection` in `readonly: true` mode. Parallax is fundamentally read-only against the database, preventing accidental corruption.

### 2. Contact Maps (`CNContactStore`)
- [x] **Verified Local API:** The app uses Apple's native `Contacts.framework`. Lookups happen against the local Address Book sync engine on macOS.
- [x] **No External Avatars:** Identifiers are not sent to Gravatar, Clearbit, or any external service to resolve avatars. It strictly uses `CNContactThumbnailImageDataKey`.

### 3. Local Intelligence (`ollama-swift`)
- [x] **Verified Local Connection:** The `LLMService` utilizes `.default` configuration for the Ollama client, which is hard-coded to `http://127.0.0.1:11434`. 
- [x] **No API Keys:** The `Package.swift` and source code contain exactly zero references to OpenAI, Anthropic, or any remote REST APIs. There are no `.env` files floating around with secret keys.
- [x] **Data Isolation:** Message contents queried in `KnowledgeBaseView` are streamed over local sockets to the Ollama daemon running on the same silicon.

### 4. Telemetry and Analytics
- [x] **Zero Tracking:** The app leverages standard `OSLog` (`Logger(subsystem: "com.parallax.app")`) which stays in the local Unified Logging system (`Console.app`). We have integrated zero crash reporters (e.g., Crashlytics, Sentry) and zero product analytics (e.g., Mixpanel, PostHog).

## Conclusion
✅ **PASSED.**

The initial build of Parallax meets the strictest definition of local-only software. Continued development must ensure that no new Swift Packages introduce hidden analytics or external network dependencies.
