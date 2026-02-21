# Developer Session Dump: Debugging, Layouts, and Logging

## What We Accomplished
We established a powerful development foundation for future iteration on Parallax. We resolved a core UI layout issue, generated architecture documentation, built an internal debugging tool to capture the UI state on command without OS interference, and added widespread interaction logging.

## Architecture & Technical Decisions
- **Sidebar Width Fix**: Added `.navigationSplitViewColumnWidth(min: 280, ideal: 320)` to `ChatsView.swift` because SwiftUI's `List` inside a `NavigationSplitView` defaults to a narrow width on macOS, truncating contact names.
- **Debug Screenshot Tooling**: Implemented a global keyboard shortcut (`Cmd + Option + S`) that saves a PNG of the application window directly to `/tmp/parallax_debug_render.png`. 
  - *Decision*: We opted to use AppKit's `NSWindow.contentView` and `NSView.bitmapImageRepForCachingDisplay` to capture the view. This strictly captures the application's visual bounds. We avoided `CGWindowListCreateImage` because it often fails or requires intrusive system-wide Screen Recording permissions from the user.
- **Global Event Monitoring**: We used `NSEvent.addLocalMonitorForEvents(matching: .keyDown)` in `ContentView` to capture the screenshot shortcut.
  - *Decision*: We originally tried attaching `.keyboardShortcut()` to a hidden SwiftUI `Button`, but invisible/zero-frame buttons aren't "focusable" in macOS and silently swallow the keyboard shortcuts. The `NSEvent` monitor guarantees the keystroke is caught globally while the app is active.
- **App Activation Policy**: We edited `AppDelegate` (in `parallax.swift`) to call `NSApp.setActivationPolicy(.regular)` and `NSApp.activate(ignoringOtherApps: true)`.
  - *Decision*: Because we are running the binary from the terminal instead of an `.app` bundle, macOS defaulted to treating Parallax as an unseen background accessory. Setting the policy to `.regular` gives us a proper Menu Bar, Dock presence, and most importantly, allows the app to cleanly receive keyboard focus.
- **Verbose Interaction Logging**: Injected `print("👉 [ViewName] User action...")` statements into every tap gesture and button action across all major views (`ContentView`, `MessageThreadView`, `PeopleOrbitView`, `ChatsView`, `KnowledgeBaseView`, `ContactDetailSidebar`).

## Gotchas & Quirks
- **Package.swift Syntax Error**: When defining an executable product to capitalize the app name in the Menu Bar, the `products: []` array MUST strictly precede the `dependencies: []` array in the `Package` declaration, otherwise the Swift compiler fails with an obscure manifest error.
- **SwiftUI Hidden Button Limitations**: As noted above, `opacity(0)` combined with `frame(width: 0)` renders buttons effectively dead to macOS keyboard shortcuts. Use global explicit event monitors for hidden developer shortcuts.

## Important State
- **`ContentView.swift`**: Serves as the root router and the host for our global debug key-down listener.
- **`/tmp/parallax_debug_render.png`**: The hardcoded output path for our debug screenshots. 

## Incomplete Threads
- Message sending via `MessageThreadView` has the UI built and a print log, but the actual AppleScript/sendMessage backend execution is empty.
- People Orbit view contact tap gestures only emit a log right now; they do not navigate to a detailed node map or user profile yet.

## How to Test/Resume
To spin up the app and verify logging / screenshots:
```bash
swift build
killall Parallax || true
.build/arm64-apple-macosx/debug/Parallax &
```
1. Press `Cmd + Option + S` while the app has focus.
2. Run `open /tmp/parallax_debug_render.png` to view the debug capture.
3. Tap on sidebar items, chat bubbles, or the Knowledge base submit button to see print statements emit natively in the terminal.
