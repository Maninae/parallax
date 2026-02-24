# Developer Session Dump: Custom App Icon Integration

## What We Accomplished
We designed and officially integrated a custom application icon for Parallax. The user requested 3 logo candidates, selected a 3D frosted-glass "parallax" design, requested a textless variant, and ultimately provided the final image as `icon image.png` in the project root. We packaged this into the Swift Package Manager build system and injected it smoothly at runtime.

## Architecture & Technical Decisions
- **SPM Resource Bundling**: We moved the raw `icon image.png` into `Sources/parallax/Resources/AppIcon.png`. We then updated `Package.swift`'s executable target to explicitly include `resources: [.process("Resources")]`.
  - *Decision*: Since Parallax is currently being built strictly via `swift build` as a CLI Swift Package (rather than an Xcode `.xcodeproj` with an `Assets.xcassets` catalog), the clean way to bundle assets is using SPM's `.process()` directive.
- **Dynamic Runtime Icon Injection**: Inside `AppDelegate.applicationDidFinishLaunching`, we use `Bundle.module.path(forResource: "AppIcon", ofType: "png")` to fetch the bundled graphic, instantiate an `NSImage`, and assign it to `NSApp.applicationIconImage`.
  - *Decision*: Because we lack a formal `.app` bundle structure with an `Info.plist` pointing to an `.icns` file during development builds, we must programmatically swap out the generic terminal executable icon for our rich custom image immediately after app launch. 

## Gotchas & Quirks
- **Bundle.module vs Bundle.main**: In SPM executables with resources, the compiler automatically synthezises a `Bundle.module` accessor. It is crucial to use this over `Bundle.main` to fetch assets, as `Bundle.main` often resolves differently depending on where the binary is executed from.
- **Icon Sizing Warning**: The raw `.png` provided by the user was roughly 7 MB. In a production Xcode build, this would be compiled down into a multi-resolution `.icns` file, but currently, it is kept in memory as an `NSImage` dock icon.

## Important State
- **`Sources/parallax/Resources/`**: The strictly defined SPM asset directory.
- **`AppDelegate` in `parallax.swift`**: The source of truth for all macOS-specific window and application lifecycle overrides.

## Incomplete Threads
- No pending tasks on the icon front. The app now looks and acts like a first-class macOS citizen on launch!

## How to Test/Resume
To spin up the app and verify the new icon launches in the dock:
```bash
swift build
killall Parallax || true
.build/arm64-apple-macosx/debug/Parallax &
```
1. Look at your macOS Dock. You should see the sleek, textless frosted glass Parallax icon instead of a generic terminal/exec icon!
