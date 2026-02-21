# Parallax Local AI Integration Report

**Goal:** Establish a privacy-first, zero-network foundation for intelligent features (like a Knowledge Base) running natively on macOS.

## 1. The Inference Engine Options

We need a completely local engine to run LLMs for querying our Messages data.

### Option A: `mattt/ollama-swift` (Recommended for Rapid Prototyping)
- **How it works:** Uses the `ollama-swift` library to interface with a locally running Ollama instance on the user's Mac.
- **Pros:** 
  - Extremely fast to implement.
  - Offloads heavy compute management to Ollama.
  - Supports modern features like structured JSON outputs and vision models (for analyzing attached images in chats).
- **Cons:** Requires the user to have downloaded and installed the Ollama app separately.

### Option B: Apple's `mlx-swift` (Recommended for Native Production)
- **How it works:** Uses Apple's official `MLX` framework specifically optimized for Apple Silicon (M-series chips). 
- **Pros:** 
  - 100% self-contained within the Parallax app (zero external dependencies).
  - Maximum possible performance utilizing the unified memory and Neural Engine/GPU directly.
- **Cons:** More complex to implement model downloading and management within our UI.

## 2. The Knowledge Base (Local RAG)

To make the LLM aware of the user's history, we cannot simply pass the whole `chat.db` into the prompt (it's way too big). We must use Retrieval-Augmented Generation (RAG).

### Setup and Indexing
- **Vector Database:** We will embed a local, swift-native vector database like `SVDB` (Swift Vector Database) or use SQLite with a vector extension.
- **Embedding Generation:** We use `CoreML` (or MLX) to run a small embedding model (e.g., `all-MiniLM-L6-v2`) locally.
- **The Pipeline:**
  1. Parallax reads chats via the `imsg` package.
  2. Background task chunks the messages and generates embeddings locally.
  3. Vectors are stored securely in local app storage alongside the metadata (chat ID, timestamp).

### Querying
When the user asks, *"When did me and Alex talk about the hiking trip?"*
1. Embed the query locally.
2. Search the local Vector DB for the top `N` most relevant message chunks.
3. Pass those chunks as context into the local LLM (Ollama or MLX) with a strict system prompt to synthesize an answer.

## Conclusion & Next Steps

To balance speed and the "zero-networking" rule, we will:
1. **Phase 1 (Prototyping):** Build the local RAG pipeline and connect it to **Ollama** using `ollama-swift`. It proves the concept quickly.
2. **Phase 2 (Production):** Replace Ollama with **`mlx-swift`** to ship a truly self-contained, native macOS application that requires no external software.
