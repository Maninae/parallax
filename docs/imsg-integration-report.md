# Parallax `imsg` Integration Report

**Goal:** Analyze how `github.com/steipete/imsg` can serve as the data and backend engine for the Parallax app.

## Overview

`imsg` is a well-structured CLI tool written in Swift that interfaces with the macOS `chat.db` (iMessage database). It provides a high-level API to read chats, list messages, handle attachments, and send messages.

## 1. Data Extraction Capabilities

`imsg` natively supports reading and parsing the complex `chat.db` schema:
- **Chats (`imsg chats`)**: Retrieves active threads, extracting the `chat_identifier`, display names (if saved in DB), service type (iMessage vs SMS), and the last message timestamp.
- **Message History (`imsg history <chat_id>`)**: Fetches threads including message text, sender handles, and precise timestamps.
- **Reactions**: Extracts "Tapbacks" (loved, liked, laughed, etc.), which is critical for replicating the official UI.
- **Attachments**: Resolves paths to local files, extracting MIME types and sizes.
- **Streaming (`imsg watch`)**: Allows real-time streaming of incoming messages without needing aggressive polling. 

## 2. Database Location & Permissions

- **Target:** `~/Library/Messages/chat.db`
- **Permissions:** `imsg` requires the terminal or host app (Parallax) to be granted **Full Disk Access** in System Preferences. It does not automatically prompt for this.

## 3. Identifiers and Group Chat Mapping

To support Parallax's "People Orbit" view:
- **Row IDs:** `imsg` uses the stable SQLite `ROWID` internally.
- **Group Hashes:** Group chats are identified by a unique `chat_identifier` (e.g., `iMessage;-;group_id`). 
- **Mapping Strategy:** We can use these persistent identifiers as keys to map groups to our custom contact data structures.

## 4. Sending Messages

Unlike many read-only scrapers, `imsg` *can* send messages.
- **Implementation:** It uses the `ScriptingBridge` framework to execute AppleScript commands targeting the official `Messages.app`.
- **Capability:** Supports sending explicit text strings and resolving attachment paths to send media.

## 5. Integration Strategy for Parallax

`imsg` is structured as a Swift project, separated into an `IMsgCore` library and the CLI executable.
 
**Optimal Path:** 
Instead of executing CLI commands via `Process()`, Parallax should import the `IMsgCore` module directly via Swift Package Manager. This allows type-safe, native Swift access to its parsing logic.

### The Missing Link: Contacts Resolution

`imsg` only reads what is inside `chat.db`. It knows phone numbers and emails, but **not user names or profile pictures**. 

Parallax must implement a local **Contact Map**:
1. Use the `Contacts` (`CNContactStore`) framework to fetch local Address Book entries.
2. Build an in-memory dictionary mapping normalized phone numbers/emails (from `imsg`) to `CNContact` objects.
3. Use this dictionary to populate names and avatars in the Parallax UI.

## Conclusion
`imsg` is a perfect foundation. It abstract away the brittle SQL queries and schema versioning of `chat.db`, allowing us to focus purely on the custom "Bubble-Sea" UI and group chat mapping.
