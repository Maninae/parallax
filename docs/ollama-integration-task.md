# Phase 6: Local Intelligence (Ollama Integration)

## Objective
The goal is to implement **Phase 6** of the `parallax` macOS application: integrating local LLM capabilities via [mattt/ollama-swift](https://github.com/mattt/ollama-swift).

This subagent is tasked with building the foundation for querying a local Ollama instance running on the user's macOS device, ensuring a 100% local, privacy-first implementation with **zero network external API calls**.

## Context
Parallax is a SwiftUI application that reads the user's local `chat.db` (iMessage database) to provide an alternative frontend. 
We have a working data layer (using `steipete/imsg`) and a basic UI in `Sources/parallax/Views`.

## Required Tasks

### 1. Add `ollama-swift` Dependency
- Modify `/Users/ojwang/Developer/parallax/Package.swift` to add `https://github.com/mattt/ollama-swift` as a package dependency.
- Include the `Ollama` product in the `parallax` executable target.

### 2. Build the `LLMService`
- Create a new file `Sources/parallax/Services/LLMService.swift`.
- Implement an `@MainActor public class LLMService: ObservableObject`.
- Instantiate the Ollama client: `let client = Ollama.Client()`.
- Add functionality to check if the Ollama daemon is reachable (`client.reachable()`).
- Add a function to stream or fetch a response given a prompt. It must handle connection errors gracefully if the user does not have Ollama running locally.

### 3. Build a Basic Testing UI
- We need to prove this works within Parallax.
- Create a simple view `Sources/parallax/Views/KnowledgeBaseView.swift`.
- It should have a TextField for querying and a ScrollView to display the streamed response from `LLMService`.
- Add a button or indicator showing if the Ollama daemon is "Connected" or "Disconnected".

### 4. Integration
- In `ContentView.swift`, add a third Tab icon (e.g., `brain.head.profile`) that navigates to your new `KnowledgeBaseView`.

## Constraints & Rules
- **No Internet Calls:** You are strictly forbidden from writing code that calls out to OpenAI, Anthropic, or any remote API. Everything must target `localhost:11434` (Ollama's default port).
- **Graceful Failure:** If Ollama is not installed or running, the UI should gracefully explain this to the user, not crash the app.
- **Do NOT Touch Existing Views Unnecessarily:** Focus only on `Package.swift`, `ContentView.swift` (to add the tab), and creating your new Service/View files.

## Definition of Done
When you finish, the project must run `swift build` successfully without errors. Report back with the status of your integration when complete.
