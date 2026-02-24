---
description: Create final session briefs and highly detailed knowledge dumps for future context
---
# /wrapup Workflow

When requested to run the wrap-up workflow, or when concluding a major session, follow these steps strictly.

1. **Create Session Directory**: Generate a timestamped directory in `.agent/history/YYYYMMDD-HHMMSS_brief_topic/`.
2. **Create BRIEF.md**: A compact file containing:
   - 1-2 sentence high-level summary of the session.
   - 5-10 comma-separated bullet keywords for `/resume` searchability.
3. **Create session.md (THE KNOWLEDGE DUMP)**: This is the most critical file. **DO NOT BE BRIEF.** 
   - Write a massive, highly technical brain dump of everything accomplished.
   - Future agents will use this file to understand the architecture, exact state, quirks discovered, and deep technical decisions made.
   - **MUST INCLUDE:**
     - **Architecture & Technical Decisions**: Why did we choose a specific layout, library, or pattern?
     - **Gotchas & Quirks**: Complex SwiftUI compilation errors fixed, memory management details, strange API behavior (e.g., Apple frameworks).
     - **Important State**: Which variables, services, or singletons act as the source of truth?
     - **Incomplete Threads**: What was left unfinished and exactly where to pick it up.
     - **How to Test/Resume**: Specific bash commands to run the project.
4. **Wrap Up**: Commit these files to git.
5. **Sync**: Run the `/gmp` workflow to solidify the changes in git and push to remote.
