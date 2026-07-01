# Vector RAG upgrade notes (future)

When you are ready to move from full-context to vector retrieval:

1. Create a Cloudflare Vectorize index (dimension 768 for `@cf/baai/bge-base-en-v1.5`).
2. Uncomment the `[[vectorize]]` block in `worker/wrangler.toml`.
3. Set `RETRIEVAL_MODE = "vector"` in `wrangler.toml`.
4. Embed each chunk in `data/knowledge.json` and upsert vectors with metadata `{ text, source }`.
5. Redeploy the worker.

The retriever switch is already wired in `worker/src/retriever.js`.

Optional constraints to add later in `worker/src/llm.js`:
- Blocked topics / regex filters in `validateUserMessage`
- Max context token budget before LLM call
- Source citation formatting in responses
