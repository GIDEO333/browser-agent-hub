---
description: How to use the deterministic memory router for optimal query handling
---

# Memory Router Skill

## Purpose
Routes memory queries to the optimal backend **without LLM overhead** (0 tokens, 10ms routing).

## Available Backends

| Backend | Use Case | Latency | Status |
|:--|:--|:--|:--|
| **Mem0** | Facts, commitments, preferences | 10ms | ✅ Installed |
| **Qdrant** | Temporal/similarity search | 50ms | ⬜ On-demand |
| **Neo4j** | Complex graph relations | 150ms | ⬜ On-demand |
| **Hybrid** | Fallback for ambiguous queries | 200ms | ✅ Always |

## How to Route

Run the router script:
```bash
~/tools-venv/bin/python ~/Projects/browser-agent-hub/scripts/memory_router.py "your query here"
```

## Decision Rules

1. Keywords like **janji, meeting, siapa, kapan** → **Mem0** (quick facts)
2. Patterns with **year numbers, "tahun lalu", "dulu"** → **Qdrant** (temporal)
3. Keywords like **terkait, hubungan, relasi** → **Neo4j** (graph)
4. Everything else → **Hybrid** fallback

## When to Use This Skill

- Before storing or retrieving any memory/context
- When the agent needs to decide WHERE to look for information
- For trading regime history, project logs, commitments

## Examples

```
"Janji ketemu siapa minggu depan?"     → mem0 (fact lookup)
"Website yang dibuat tahun 2025"       → qdrant (temporal search)
"BTC regime terkait strategy TrendFollow" → neo4j (graph relation)
"Apa yang terjadi kemarin?"            → qdrant (temporal)
```
