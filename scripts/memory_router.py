#!/usr/bin/env python3
"""
Deterministic Memory Router — Zero LLM Cost
Routes queries to the optimal memory backend based on keyword/regex patterns.
Supports: Mem0 (facts), Qdrant (similarity), Neo4j (graph), Hybrid (fallback).

Usage:
    python memory_router.py "Janji ketemu siapa?"     → mem0
    python memory_router.py "Website tahun 2025"       → qdrant
    python memory_router.py "BTC terkait project X"    → neo4j
    python memory_router.py "Bagaimana cuaca?"          → hybrid
"""

import re
import json
import sys
from typing import Optional

# --- Router Configuration ---
ROUTER_RULES = {
    "mem0": {
        "keywords": ["janji", "meeting", "siapa", "dimana", "kapan", "appointment",
                      "remember", "ingat", "commit", "promise", "schedule"],
        "description": "Facts & commitments (10ms)"
    },
    "qdrant": {
        "patterns": [r"\d{4}", r"tahun\s+lalu", r"bulan\s+lalu", r"kemarin",
                     r"dulu", r"history", r"log", r"mirip", r"similar"],
        "keywords": ["lalu", "sebelumnya", "archive"],
        "description": "Temporal similarity search (50ms)"
    },
    "neo4j": {
        "keywords": ["terkait", "hubungan", "relasi", "related",
                      "connected", "graph", "team", "belongs"],
        "description": "Graph relations (150ms)"
    }
}


def route_query(query: str) -> dict:
    """Route a query to the optimal memory backend."""
    q = query.lower()

    # Rule 1: Mem0 — Quick facts (keywords only)
    mem0_rules = ROUTER_RULES["mem0"]
    if any(word in q for word in mem0_rules["keywords"]):
        return {"backend": "mem0", "confidence": 0.95,
                "reason": f"Keyword match: {mem0_rules['description']}"}

    # Rule 2: Qdrant — Temporal/similarity (regex + keywords)
    qdrant_rules = ROUTER_RULES["qdrant"]
    for pattern in qdrant_rules.get("patterns", []):
        if re.search(pattern, q):
            return {"backend": "qdrant", "confidence": 0.90,
                    "reason": f"Pattern match ({pattern}): {qdrant_rules['description']}"}
    if any(word in q for word in qdrant_rules.get("keywords", [])):
        return {"backend": "qdrant", "confidence": 0.85,
                "reason": f"Keyword match: {qdrant_rules['description']}"}

    # Rule 3: Neo4j — Graph relations
    neo4j_rules = ROUTER_RULES["neo4j"]
    if any(word in q for word in neo4j_rules["keywords"]):
        return {"backend": "neo4j", "confidence": 0.85,
                "reason": f"Keyword match: {neo4j_rules['description']}"}

    # Rule 4: Hybrid fallback
    return {"backend": "hybrid", "confidence": 0.70,
            "reason": "No specific pattern matched, using hybrid search (200ms)"}


def search_mem0(query: str) -> Optional[str]:
    """Search using Mem0 backend."""
    try:
        from mem0 import Memory
        m = Memory()
        results = m.search(query, limit=5)
        return json.dumps(results, indent=2, default=str)
    except ImportError:
        return json.dumps({"error": "mem0 not installed", "install": "pip install mem0ai"})
    except Exception as e:
        return json.dumps({"error": str(e)})


def execute_query(query: str) -> dict:
    """Route and optionally execute a query."""
    result = route_query(query)

    # Only execute if backend is available
    if result["backend"] == "mem0":
        try:
            from mem0 import Memory
            result["available"] = True
        except ImportError:
            result["available"] = False
    elif result["backend"] == "qdrant":
        try:
            from qdrant_client import QdrantClient
            result["available"] = True
        except ImportError:
            result["available"] = False
            result["install"] = "docker run -d -p 6333:6333 qdrant/qdrant && pip install qdrant-client"
    elif result["backend"] == "neo4j":
        try:
            from neo4j import GraphDatabase
            result["available"] = True
        except ImportError:
            result["available"] = False
            result["install"] = "docker run -d -p 7474:7474 -p 7687:7687 neo4j && pip install neo4j"
    else:
        result["available"] = True  # hybrid always available

    return result


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python memory_router.py \"<query>\"")
        print("\nExamples:")
        print('  python memory_router.py "Janji ketemu siapa?"')
        print('  python memory_router.py "Website tahun 2025"')
        print('  python memory_router.py "BTC terkait project X"')
        sys.exit(1)

    query = " ".join(sys.argv[1:])
    result = execute_query(query)
    print(json.dumps({"query": query, **result}, indent=2, ensure_ascii=False))
