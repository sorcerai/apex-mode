#!/usr/bin/env python3
"""
APEX Knowledge Graph Manager
Manages project knowledge for context-efficient AI development.
Based on Navigator's knowledge graph architecture.
"""

import argparse
import json
import hashlib
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import Optional


APEX_DIR = Path.home() / ".claude" / "apex"
GRAPH_PATH = APEX_DIR / "state" / "knowledge-graph.json"


def init_graph(project_path: str = ".") -> dict:
    """Initialize knowledge graph from project files."""
    project = Path(project_path)
    
    graph = {
        "version": "1.0.0",
        "created_at": datetime.utcnow().isoformat() + "Z",
        "updated_at": datetime.utcnow().isoformat() + "Z",
        "project": str(project.absolute()),
        "concepts": {},
        "memories": [],
        "files": {},
        "relationships": []
    }
    
    # Scan for common project files
    important_files = [
        "README.md", "package.json", "Cargo.toml", "go.mod",
        "pyproject.toml", "requirements.txt", ".env.example"
    ]
    
    for filename in important_files:
        filepath = project / filename
        if filepath.exists():
            graph["files"][filename] = {
                "path": str(filepath),
                "type": "config" if filename.endswith((".json", ".toml", ".yaml")) else "doc",
                "indexed_at": datetime.utcnow().isoformat() + "Z"
            }
    
    # Scan for common directories
    important_dirs = ["src", "lib", "app", "components", "api", "tests"]
    for dirname in important_dirs:
        dirpath = project / dirname
        if dirpath.exists():
            file_count = len(list(dirpath.rglob("*")))
            graph["concepts"][dirname] = {
                "type": "directory",
                "path": str(dirpath),
                "file_count": file_count,
                "related_files": []
            }
    
    save_graph(graph)
    return graph


def load_graph() -> dict:
    """Load existing knowledge graph."""
    if not GRAPH_PATH.exists():
        return None
    with open(GRAPH_PATH) as f:
        return json.load(f)


def save_graph(graph: dict):
    """Save knowledge graph atomically."""
    GRAPH_PATH.parent.mkdir(parents=True, exist_ok=True)
    graph["updated_at"] = datetime.utcnow().isoformat() + "Z"
    tmp_path = GRAPH_PATH.with_suffix(".tmp")
    with open(tmp_path, "w") as f:
        json.dump(graph, f, indent=2)
    tmp_path.rename(GRAPH_PATH)


def query(concept: str, graph: dict = None) -> dict:
    """Query knowledge graph for a concept."""
    graph = graph or load_graph()
    if not graph:
        return {"error": "No knowledge graph found. Run init first."}
    
    concept_lower = concept.lower()
    results = {
        "query": concept,
        "concepts": [],
        "memories": [],
        "files": [],
        "relationships": []
    }
    
    # Search concepts
    for name, data in graph.get("concepts", {}).items():
        if concept_lower in name.lower():
            results["concepts"].append({"name": name, **data})
    
    # Search memories
    for memory in graph.get("memories", []):
        if concept_lower in memory.get("summary", "").lower():
            results["memories"].append(memory)
        elif concept_lower in " ".join(memory.get("concepts", [])).lower():
            results["memories"].append(memory)
    
    # Search files
    for filename, data in graph.get("files", {}).items():
        if concept_lower in filename.lower():
            results["files"].append({"name": filename, **data})
    
    # Search relationships
    for rel in graph.get("relationships", []):
        if concept_lower in rel.get("from", "").lower() or concept_lower in rel.get("to", "").lower():
            results["relationships"].append(rel)
    
    results["found"] = (
        len(results["concepts"]) > 0 or
        len(results["memories"]) > 0 or
        len(results["files"]) > 0
    )
    
    return results


def add_memory(
    memory_type: str,
    summary: str,
    concepts: list[str],
    confidence: float = 0.8,
    graph: dict = None
) -> dict:
    """Add a new memory to the knowledge graph."""
    graph = graph or load_graph()
    if not graph:
        graph = init_graph()
    
    memory = {
        "id": hashlib.md5(f"{memory_type}:{summary}".encode()).hexdigest()[:8],
        "type": memory_type,  # pattern, pitfall, decision, learning
        "summary": summary,
        "concepts": concepts,
        "confidence": confidence,
        "created_at": datetime.utcnow().isoformat() + "Z"
    }
    
    # Check for duplicate
    for existing in graph["memories"]:
        if existing["summary"] == summary:
            return {"success": False, "error": "Memory already exists", "existing": existing}
    
    graph["memories"].append(memory)
    
    # Update concept relationships
    for concept in concepts:
        if concept not in graph["concepts"]:
            graph["concepts"][concept] = {
                "type": "inferred",
                "memories": [],
                "related_files": []
            }
        if "memories" not in graph["concepts"][concept]:
            graph["concepts"][concept]["memories"] = []
        graph["concepts"][concept]["memories"].append(memory["id"])
    
    save_graph(graph)
    return {"success": True, "memory": memory}


def add_relationship(
    from_concept: str,
    to_concept: str,
    relation_type: str,
    graph: dict = None
) -> dict:
    """Add a relationship between concepts."""
    graph = graph or load_graph()
    if not graph:
        return {"error": "No knowledge graph found"}
    
    relationship = {
        "from": from_concept,
        "to": to_concept,
        "type": relation_type,
        "created_at": datetime.utcnow().isoformat() + "Z"
    }
    
    graph["relationships"].append(relationship)
    save_graph(graph)
    return {"success": True, "relationship": relationship}


def get_stats(graph: dict = None) -> dict:
    """Get knowledge graph statistics."""
    graph = graph or load_graph()
    if not graph:
        return {"error": "No knowledge graph found"}
    
    memory_types = {}
    for mem in graph.get("memories", []):
        t = mem.get("type", "unknown")
        memory_types[t] = memory_types.get(t, 0) + 1
    
    return {
        "version": graph.get("version", "unknown"),
        "project": graph.get("project", "unknown"),
        "created_at": graph.get("created_at"),
        "updated_at": graph.get("updated_at"),
        "counts": {
            "concepts": len(graph.get("concepts", {})),
            "memories": len(graph.get("memories", [])),
            "files": len(graph.get("files", {})),
            "relationships": len(graph.get("relationships", []))
        },
        "memory_types": memory_types
    }


def main():
    parser = argparse.ArgumentParser(description="APEX Knowledge Graph Manager")
    subparsers = parser.add_subparsers(dest="action", required=True)
    
    # Init
    init_parser = subparsers.add_parser("init", help="Initialize knowledge graph")
    init_parser.add_argument("--project", default=".", help="Project path")
    
    # Query
    query_parser = subparsers.add_parser("query", help="Query knowledge graph")
    query_parser.add_argument("concept", help="Concept to search for")
    
    # Add memory
    memory_parser = subparsers.add_parser("memory", help="Add memory")
    memory_parser.add_argument("--type", required=True, 
                               choices=["pattern", "pitfall", "decision", "learning"])
    memory_parser.add_argument("--summary", required=True, help="Memory summary")
    memory_parser.add_argument("--concepts", required=True, help="Comma-separated concepts")
    memory_parser.add_argument("--confidence", type=float, default=0.8)
    
    # Add relationship
    rel_parser = subparsers.add_parser("relate", help="Add relationship")
    rel_parser.add_argument("--from", dest="from_concept", required=True)
    rel_parser.add_argument("--to", required=True)
    rel_parser.add_argument("--type", required=True)
    
    # Stats
    subparsers.add_parser("stats", help="Show graph statistics")
    
    args = parser.parse_args()
    
    if args.action == "init":
        result = init_graph(args.project)
    elif args.action == "query":
        result = query(args.concept)
    elif args.action == "memory":
        concepts = [c.strip() for c in args.concepts.split(",")]
        result = add_memory(args.type, args.summary, concepts, args.confidence)
    elif args.action == "relate":
        result = add_relationship(args.from_concept, args.to, args.type)
    elif args.action == "stats":
        result = get_stats()
    
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
