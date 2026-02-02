#!/usr/bin/env python3
"""
APEX Task Decomposer
Breaks down complex tasks into parallelizable subtasks.
"""

import argparse
import json
import re
import sys
from dataclasses import dataclass, asdict
from typing import Optional


@dataclass
class Subtask:
    id: str
    description: str
    dependencies: list[str]
    estimated_size: str  # S, M, L
    parallel_safe: bool


def extract_components(task: str) -> list[str]:
    """Extract component mentions from task description."""
    # Common patterns: "X and Y and Z", "X, Y, and Z", "X with Y"
    components = []
    
    # Split on common conjunctions
    parts = re.split(r'\s+(?:and|with|plus|\+|,)\s+', task.lower())
    
    for part in parts:
        # Clean up the part
        part = part.strip()
        part = re.sub(r'^(add|create|build|implement|write)\s+', '', part)
        part = re.sub(r'\s+(feature|component|module|endpoint|page)s?$', '', part)
        if part and len(part) > 2:
            components.append(part)
    
    return components


def detect_dependencies(components: list[str]) -> dict[str, list[str]]:
    """Detect likely dependencies between components."""
    deps = {c: [] for c in components}
    
    # Common dependency patterns
    dependency_hints = {
        'test': ['*'],  # Tests usually depend on implementation
        'integration test': ['*'],
        'e2e test': ['*'],
        'docs': ['*'],  # Docs depend on implementation
        'documentation': ['*'],
    }
    
    auth_consumers = ['user', 'profile', 'settings', 'dashboard', 'admin']
    
    for component in components:
        # Tests depend on everything else
        if 'test' in component:
            deps[component] = [c for c in components if c != component and 'test' not in c]
        
        # Auth is usually a dependency for user-related features
        if any(consumer in component for consumer in auth_consumers):
            for other in components:
                if 'auth' in other and other != component:
                    deps[component].append(other)
    
    return deps


def estimate_size(description: str) -> str:
    """Estimate task size based on description."""
    description = description.lower()
    
    # Large indicators
    if any(word in description for word in ['full', 'complete', 'entire', 'all', 'comprehensive']):
        return 'L'
    
    # Small indicators
    if any(word in description for word in ['simple', 'basic', 'small', 'quick', 'minor', 'fix']):
        return 'S'
    
    # Default to medium
    return 'M'


def decompose_task(task: str, max_subtasks: int = 5) -> dict:
    """Decompose a task into subtasks with dependency analysis."""
    components = extract_components(task)
    
    # If no clear components, treat as single task
    if len(components) <= 1:
        return {
            "original_task": task,
            "subtasks": [{
                "id": "task-001",
                "description": task,
                "dependencies": [],
                "estimated_size": estimate_size(task),
                "parallel_safe": True
            }],
            "parallel_groups": [["task-001"]],
            "recommendation": "single_worker"
        }
    
    # Limit to max_subtasks
    components = components[:max_subtasks]
    
    # Build dependency graph
    deps = detect_dependencies(components)
    
    # Create subtasks
    subtasks = []
    for i, component in enumerate(components):
        task_id = f"task-{i+1:03d}"
        component_deps = deps.get(component, [])
        
        # Convert component names to task IDs
        dep_ids = []
        for dep in component_deps:
            if dep in components:
                dep_idx = components.index(dep)
                dep_ids.append(f"task-{dep_idx+1:03d}")
        
        subtasks.append({
            "id": task_id,
            "description": f"Implement {component}",
            "dependencies": dep_ids,
            "estimated_size": estimate_size(component),
            "parallel_safe": len(dep_ids) == 0
        })
    
    # Group tasks by dependency level for parallel execution
    parallel_groups = compute_parallel_groups(subtasks)
    
    # Recommendation
    if len(parallel_groups) == 1:
        recommendation = "full_parallel"
    elif len(parallel_groups) == len(subtasks):
        recommendation = "sequential"
    else:
        recommendation = "mixed"
    
    return {
        "original_task": task,
        "subtasks": subtasks,
        "parallel_groups": parallel_groups,
        "recommendation": recommendation,
        "suggested_workers": min(max(len(g) for g in parallel_groups), 3)
    }


def compute_parallel_groups(subtasks: list[dict]) -> list[list[str]]:
    """Compute groups of tasks that can run in parallel."""
    groups = []
    completed = set()
    remaining = {t["id"]: t for t in subtasks}
    
    while remaining:
        # Find tasks with all dependencies satisfied
        ready = []
        for task_id, task in remaining.items():
            if all(dep in completed for dep in task["dependencies"]):
                ready.append(task_id)
        
        if not ready:
            # Circular dependency or error - just take one
            ready = [next(iter(remaining.keys()))]
        
        groups.append(ready)
        
        for task_id in ready:
            completed.add(task_id)
            del remaining[task_id]
    
    return groups


def main():
    parser = argparse.ArgumentParser(description="APEX Task Decomposer")
    parser.add_argument("--task", required=True, help="Task description to decompose")
    parser.add_argument("--max-subtasks", type=int, default=5, help="Maximum subtasks")
    parser.add_argument("--format", choices=["json", "text"], default="json")
    
    args = parser.parse_args()
    
    result = decompose_task(args.task, args.max_subtasks)
    
    if args.format == "json":
        print(json.dumps(result, indent=2))
    else:
        print(f"Task: {result['original_task']}")
        print(f"Recommendation: {result['recommendation']}")
        print(f"Suggested workers: {result.get('suggested_workers', 1)}")
        print("\nSubtasks:")
        for task in result["subtasks"]:
            deps = f" (depends: {', '.join(task['dependencies'])})" if task['dependencies'] else ""
            print(f"  [{task['id']}] {task['description']} [{task['estimated_size']}]{deps}")
        print("\nParallel groups:")
        for i, group in enumerate(result["parallel_groups"]):
            print(f"  Group {i+1}: {', '.join(group)}")


if __name__ == "__main__":
    main()
