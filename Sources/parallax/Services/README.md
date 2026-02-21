# Services

This directory contains the central business logic and data access layer for Parallax. 
These are typically implemented as `ObservableObject` singletons.

## Core Services
* **MessagesService.swift**: Handles connecting to and querying the macOS `chat.db` SQLite database to retrieve iMessage history. Handles Full Disk Access edge cases.
* **ContactStore.swift**: Interfaces with Apple's `Contacts.framework` to resolve phone numbers/emails to actual human names and grab their avatar images.
* **LLMService.swift**: The integration point for local Large Language Models (typically via Ollama) to process messages or power the Knowledge Base.
