#!/usr/bin/env python3
"""
APEX Conflict Detector
Detects file conflicts between parallel swarm workers.
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path


def run_git(args: list[str], cwd: str = None) -> tuple[bool, str]:
    """Run git command and return (success, output)."""
    try:
        result = subprocess.run(
            ["git"] + args,
            cwd=cwd,
            capture_output=True,
            text=True
        )
        return result.returncode == 0, result.stdout.strip()
    except Exception as e:
        return False, str(e)


def get_repo_root() -> str:
    """Get the root of the current git repository."""
    success, output = run_git(["rev-parse", "--show-toplevel"])
    if not success:
        print("Error: Not in a git repository", file=sys.stderr)
        sys.exit(1)
    return output


def get_changed_files(branch: str, base: str = "HEAD") -> set[str]:
    """Get files changed on a branch compared to base."""
    success, output = run_git(["diff", "--name-only", f"{base}...{branch}"])
    if not success:
        return set()
    return set(output.split("\n")) if output else set()


def detect_conflicts(workers: list[int], base_branch: str = "main") -> dict:
    """Detect file conflicts between workers."""
    repo_root = get_repo_root()
    
    # Get changed files for each worker
    worker_files = {}
    for worker_id in workers:
        branch = f"apex-swarm-{worker_id}"
        files = get_changed_files(branch, base_branch)
        worker_files[worker_id] = files
    
    # Find overlaps
    conflicts = []
    worker_ids = list(workers)
    
    for i, w1 in enumerate(worker_ids):
        for w2 in worker_ids[i+1:]:
            overlap = worker_files[w1] & worker_files[w2]
            if overlap:
                conflicts.append({
                    "workers": [w1, w2],
                    "files": sorted(list(overlap)),
                    "severity": "high" if len(overlap) > 3 else "medium"
                })
    
    # Summary
    all_files = set()
    for files in worker_files.values():
        all_files.update(files)
    
    return {
        "has_conflicts": len(conflicts) > 0,
        "conflict_count": len(conflicts),
        "conflicts": conflicts,
        "summary": {
            "total_workers": len(workers),
            "total_files_changed": len(all_files),
            "workers_with_changes": {
                w: len(f) for w, f in worker_files.items()
            }
        }
    }


def suggest_resolution(conflicts: list[dict]) -> list[str]:
    """Suggest resolution strategies for conflicts."""
    suggestions = []
    
    for conflict in conflicts:
        workers = conflict["workers"]
        files = conflict["files"]
        
        if len(files) == 1:
            suggestions.append(
                f"Workers {workers}: Single file conflict ({files[0]}) - "
                "consider manual merge or reassign to one worker"
            )
        elif all(f.endswith(('.md', '.txt', '.json')) for f in files):
            suggestions.append(
                f"Workers {workers}: Config/doc conflicts only - "
                "likely safe to auto-merge"
            )
        else:
            suggestions.append(
                f"Workers {workers}: Code conflicts ({len(files)} files) - "
                "pause workers, resolve manually, then continue"
            )
    
    return suggestions


def main():
    parser = argparse.ArgumentParser(description="APEX Conflict Detector")
    parser.add_argument("--workers", required=True, help="Comma-separated worker IDs")
    parser.add_argument("--base", default="main", help="Base branch for comparison")
    parser.add_argument("--suggest", action="store_true", help="Include resolution suggestions")
    
    args = parser.parse_args()
    
    worker_ids = [int(w.strip()) for w in args.workers.split(",")]
    result = detect_conflicts(worker_ids, args.base)
    
    if args.suggest and result["conflicts"]:
        result["suggestions"] = suggest_resolution(result["conflicts"])
    
    print(json.dumps(result, indent=2))
    sys.exit(0 if not result["has_conflicts"] else 1)


if __name__ == "__main__":
    main()
