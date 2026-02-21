# Session: Initialization and Base UI - Detailed Knowledge Dump
Date: 2026-02-20

## 1. What We Built: Architecture & Features
This session initialized **Parallax**, a macOS-native (v14+) wrapper for `chat.db` utilizing local intelligence. 

### Core Services (Singletons + `@MainActor`)
- `ContactStore`: Wrapper around `CNContactStore`. 
  - **Key behavior:** Pre-fetches contacts and aggressively maps them by normalized digit-only phone numbers and lowercased email addresses to allow `O(1)` `.contact(for: handle)` lookups against `chat.identifier`. Extracts `thumbnailImageData` for avatars.
- `MessagesService`: Wrapper around `steipete/imsg`'s `MessageStore`.
  - **Key behavior:** Operates in `readonly: true` to prevent DB corruption. Loads chats and `.messages(for:)` on a detached task (`Task.detached`), before dispatching the assignment to `@Published` properties back on the `MainActor`. This is crucial to not block the main SwiftUI thread given large SQLite databases.
- `LLMService`: Created by the parallel subagent utilizing `mattt/ollama-swift`.
  - **Key behavior:** Points strictly to `localhost:11434`. Exposes an `AsyncThrowingStream` for character-by-character UI rendering of responses. 

### UI Components (Phase 4 & 5)
- **Navigation (ContentView):** Three-pane setup. `ChatsView` (Sidebar), `MessageThreadView` (Main canvas), and the third navigation tab is `PeopleOrbitView`.
- **Chats Sidebar:** Extracts `chat.name` first (SQLite Group/Stored Name), falls back to `CNContact` name resolution, falls back to raw `identifier`.
- **MessageThreadView:** Maps incoming (gray) and outgoing (blue) bubbles. Has a collapsible trailing inspector `ContactDetailSidebar` implemented dynamically in an `HStack` with `.transition(.move(edge: .trailing))`.
- **People Orbit (Phase 5):** 
  - **The Math:** We implemented Vogel's sunflower spiral algorithm in a custom SwiftUI `Layout` protocol (`BubbleLayout`). It uses the Golden Angle (137.5 degrees) to pack avatars organically into a "Bubble-Sea", similar to watchOS.
  - **The Gestures:** Wrapped in a massive `ZStack (4000x4000)` inside a `GeometryReader`. Interactivity is powered by `DragGesture` adjusting `offset` and `MagnificationGesture` adjusting `scaleEffect`.
  - **Data:** `PeopleOrbitViewModel` aggregates all unique participants across the last 100 threads, capped at 150 unique avatars to guarantee smooth 60fps scrolling.

### Visuals
- Applied `VisualEffectView` conforming to `NSVisualEffectView`, overriding standard SwiftUI colors. E.g., `.headerView` for the chat header with `.withinWindow` blending to achieve Apple's native frosted glass.

---

## 2. Preserved Learnings & Quirks Discovered

### `steipete/imsg` & SQLite Oddities
- **Optionality Errors:** Initially, we assumed `chat.name` was an optional string, but `IMsgCore` forces it non-optional. Conversely, `message.text` evaluates slightly differently depending on attachment payloads. We use `message.text.isEmpty ? "Attachment" : message.text` as a safe fallback.
- **Hashable Conformance:** Models in `IMsgCore` (`Chat`, `Message`) **do not conform to `Hashable` natively**. This broke `ForEach` and `List` rendering. We fixed this by declaring `@retroactive` extensions (`extension Chat: Hashable`) keyed on `chat.id` and `message.rowID`. 
  > *Future Note: If updating `IMsgCore`, make sure they haven't added this natively, which would cause compiler conflicts.*

### Swift 6 / SwiftUI Concurrency
- **The ViewModel Trap:** Initializing ViewModels like `MessageThreadViewModel` triggered compiler errors like `main actor-isolated static property 'shared' can not be referenced from a nonisolated context`.
  - **The Fix:** You must explicitly mark the entire `class` declaration with `@MainActor`. 
- **StateManagement:** Be incredibly careful to use `@StateObject` **ONLY** where the object is initialized, and `@ObservedObject` when referencing the singleton `shared` instances further down the view hierarchy. Misusing `@StateObject` on a `.shared` property causes silent memory/rendering bugs.

### macOS specific
- **Full Disk Access:** Launching the app out-of-the-box throws an SQLite failure. `MessagesService.hasFullDiskAccessError` captures this to render `FullDiskAccessWarningView`. The user MUST go to System Preferences and grant FDA to their terminal/Xcode to access `~/Library/Messages/chat.db`. 

---

## 3. Current Incomplete Threads / Next Steps
1. **AppleScript Action Layer:** The app currently *reads* perfectly. Sending messages (via `ComposeMessageView`) is completely inert. We need to implement AppleScript bridging logic to trigger macOS's underlying `Messages.app` to dispatch the outbound `sms/imessage` payload.
2. **Orbit Interactivity:** Tapping a bubble in the `PeopleOrbitView` just prints to console right now. It needs an animation that zooms heavily into the bubble and transitions into a "Person Scope" displaying all 1:1 and group chats involving them.
3. **Knowledge Base RAG pipeline:** `KnowledgeBaseView` talks to Ollama, but it lacks actual vectors. Future step is introducing `SVDB` or SQLite-vec to ingest the `imsg` SQLite rows so the LLM can answer contextually.

---

## 4. How to Test / Resume
- Base execution: `swift run` in the project root.
- Ensure Ollama daemon is running locally (`ollama run llama3`) to test the `KnowledgeBaseView` tab without `.red` disconnected errors appearing.
