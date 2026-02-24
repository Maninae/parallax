---
description: Commit all current changes with an AI-generated message and push to the remote repository.
---
# /gmp Workflow (Git Commit, Message, Push)

When the user requests to run the `/gmp` workflow, follow these steps sequentially to stage, commit, and push their code:

1. **Analyze Changes**: Run `git status` and `git diff` to understand what files have been modified, added, or deleted. 
2. **Generate Message**: Internally formulate a concise, conventional commit message based on the changes (e.g., `feat: added custom app icon`, `fix: sidebar layout truncation`, `chore: updated documentation`).
3. **Stage and Commit**: 
// turbo
Run the command: `git add . && git commit -m "<your generated message>"`
4. **Push**:
// turbo
Run the command: `git push`
5. **Wrap Up**: Notify the user that the changes have been successfully committed and pushed, showing them the commit message you used.
