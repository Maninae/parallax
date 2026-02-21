# Parallax Source

This directory contains the core application code for the **Parallax** macOS app.

## Entry Points
* `parallax.swift`: The main `@main` entry point for the SwiftUI App. It sets up the `WindowGroup`, a custom `AppDelegate`, and applies a `VisualEffectView` background for a glassmorphism effect.
* `ContentView.swift`: The root view of the application. It provides the outermost navigation bar (sidebar) with tabs for:
  - Chats (`ChatsView`)
  - People (`PeopleOrbitView`)
  - Knowledge Base (`KnowledgeBaseView`)

## Subdirectories
* **Views/**: Contains all the SwiftUI views that make up the user interface.
* **Services/**: Contains the business logic, data fetching, and backend integration layers (e.g., SQLite/CoreData wrappers, LLM services).
* **Models/**: Contains the data models used throughout the app.
* **App/**: Currently empty (historically used for app lifecycle delegates, now handled in `parallax.swift`).

## Developing
This app heavily leverages SwiftUI and macOS-specific APIs (`AppKit`, `NSVisualEffectView`) to create a premium, natively integrated experience.
