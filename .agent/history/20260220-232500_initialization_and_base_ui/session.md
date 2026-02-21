# Session: Initialization and Base UI
Date: 2026-02-20

## What We Built
- **Project Structure:** Created the basic Swift Package architecture for `parallax` targeting macOS 14.
- **Data Layer (Phase 3):** Hooked up `steipete/imsg` into a reactive `MessagesService`. Wrote `ContactStore` to pair phone numbers and emails with Apple's native `CNContactStore` for native profile pictures.
- **Messaging UI (Phase 4):** Designed the three-pane sliding interface: `ChatsView` (recent threads), `MessageThreadView` (central canvas), and `ContactDetailSidebar` (trailing inspector pane).
- **People Orbit (Phase 5):** Constructed a highly customized `BubbleLayout` using Vogel's sunflower spiral algorithm to generate the organic honeycomb format, plus interactive panning and magnification gestures.
- **Local AI (Phase 6 & 7):** Refined the `LLMService` outputted by the parallel subagent to fix Swift 6 `@MainActor` isolation constraints. Attached the `KnowledgeBaseView`, applied `VisualEffectView` frosted glass overlays, and authored the 100% local `privacy-audit.md` report.

## Known Issues
- The app fundamentally relies on the user granting Full Disk Access. We built a fallback UI state (`FullDiskAccessWarningView`) to handle the SQLite denial. 
- Message dispatching in the UI timeline is purely a placeholder until we tie in AppleScript payloads.

## Next Steps
- Implement sending capabilities (writing back to Messages via AppleScript bridges).
- Expand the interaction states for expanding chats out from the `PeopleOrbitView` clusters.

## How to Resume
Execute `swift run` in the project root to load the visual environment and ensure the local SQLite DB binds correctly.
