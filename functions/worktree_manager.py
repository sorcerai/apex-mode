#!/usr/bin/env python3
"""
APEX Worktree Manager
Manages git worktrees for parallel swarm execution.
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from datetime import datetime

APEX_STATE_DIR = Path.home() / ".claude" / "apex" / "state"
SWARM_QUEUE = APEX_STATE_DIR / "swarm-queue.json"


def run_git(args: list[str], cwd: str = None) -> tuple[bool, str]:
    """Run git command and return (success, output)."""
    try:
        result = subprocess.run(
            ["git"] + args,
            cwd=cwd,
            capture_output=True,
            text=True
        )
        return result.returncode == 0, result.stdout.strip() or result.stderr.strip()
    except Exception as e:
        return False, str(e)


def get_repo_root() -> str:
    """Get the root of the current git repository."""
    success, output = run_git(["rev-parse", "--show-toplevel"])
    if not success:
        print("Error: Not in a git repository", file=sys.stderr)
        sys.exit(1)
    return output


def create_worker(worker_id: int, branch: str = None, task: str = None) -> dict:
    """Create a new worktree for a swarm worker."""
    repo_root = get_repo_root()
    parent_dir = Path(repo_root).parent
    
    branch = branch or f"apex-swarm-{worker_id}"
    worktree_path = parent_dir / f"apex-worker-{worker_id}"
    
    # Create worktree with new branch
    success, output = run_git(
        ["worktree", "add", str(worktree_path), "-b", branch],
        cwd=repo_root
    )
    
    if not success:
        # Branch might exist, try without -b
        success, output = run_git(
            ["worktree", "add", str(worktree_path), branch],
            cwd=repo_root
        )
    
    if not success:
        return {"success": False, "error": output}
    
    worker_info = {
        "id": worker_id,
        "branch": branch,
        "path": str(worktree_path),
        "task": task,
        "status": "ready",
        "created_at": datetime.utcnow().isoformat() + "Z"
    }
    
    # Update swarm queue
    update_swarm_worker(worker_id, worker_info)
    
    return {"success": True, "worker": worker_info}


def destroy_worker(worker_id: int = None, all_workers: bool = False) -> dict:
    """Remove worker worktree(s)."""
    repo_root = get_repo_root()
    
    if all_workers:
        # Get all apex worktrees
        success, output = run_git(["worktree", "list", "--porcelain"], cwd=repo_root)
        if not success:
            return {"success": False, "error": output}
        
        removed = []
        for line in output.split("\n"):
            if line.startswith("worktree ") and "apex-worker-" in line:
                path = line.replace("worktree ", "")
                run_git(["worktree", "remove", path, "--force"], cwd=repo_root)
                removed.append(path)
        
        # Clear swarm queue workers
        clear_swarm_workers()
        
        return {"success": True, "removed": removed}
    
    elif worker_id is not None:
        parent_dir = Path(repo_root).parent
        worktree_path = parent_dir / f"apex-worker-{worker_id}"
        
        success, output = run_git(
            ["worktree", "remove", str(worktree_path), "--force"],
            cwd=repo_root
        )
        
        if success:
            remove_swarm_worker(worker_id)
        
        return {"success": success, "error": output if not success else None}
    
    return {"success": False, "error": "Specify --id or --all"}


def list_workers() -> dict:
    """List all active apex worktrees."""
    repo_root = get_repo_root()
    success, output = run_git(["worktree", "list", "--porcelain"], cwd=repo_root)
    
    if not success:
        return {"success": False, "error": output}
    
    workers = []
    current_worktree = {}
    
    for line in output.split("\n"):
        if line.startswith("worktree "):
            if current_worktree and "apex-worker-" in current_worktree.get("path", ""):
                workers.append(current_worktree)
            current_worktree = {"path": line.replace("worktree ", "")}
        elif line.startswith("HEAD "):
            current_worktree["head"] = line.replace("HEAD ", "")
        elif line.startswith("branch "):
            current_worktree["branch"] = line.replace("branch refs/heads/", "")
    
    if current_worktree and "apex-worker-" in current_worktree.get("path", ""):
        workers.append(current_worktree)
    
    # Enrich with swarm queue data
    queue_data = load_swarm_queue()
    for worker in workers:
        worker_id = worker["path"].split("apex-worker-")[-1]
        if worker_id in queue_data.get("workers", {}):
            worker.update(queue_data["workers"][worker_id])
    
    return {"success": True, "workers": workers}


def load_swarm_queue() -> dict:
    """Load the swarm queue file."""
    if SWARM_QUEUE.exists():
        with open(SWARM_QUEUE) as f:
            return json.load(f)
    return {"workers": {}, "queue": [], "completed": [], "conflicts": []}


def save_swarm_queue(data: dict):
    """Save the swarm queue file atomically."""
    APEX_STATE_DIR.mkdir(parents=True, exist_ok=True)
    tmp_path = SWARM_QUEUE.with_suffix(".tmp")
    with open(tmp_path, "w") as f:
        json.dump(data, f, indent=2)
    tmp_path.rename(SWARM_QUEUE)


def update_swarm_worker(worker_id: int, info: dict):
    """Update worker info in swarm queue."""
    data = load_swarm_queue()
    data["workers"][str(worker_id)] = info
    save_swarm_queue(data)


def remove_swarm_worker(worker_id: int):
    """Remove worker from swarm queue."""
    data = load_swarm_queue()
    data["workers"].pop(str(worker_id), None)
    save_swarm_queue(data)


def clear_swarm_workers():
    """Clear all workers from swarm queue."""
    data = load_swarm_queue()
    data["workers"] = {}
    save_swarm_queue(data)


def main():
    parser = argparse.ArgumentParser(description="APEX Worktree Manager")
    subparsers = parser.add_subparsers(dest="action", required=True)
    
    # Create
    create_parser = subparsers.add_parser("create", help="Create worker worktree")
    create_parser.add_argument("--id", type=int, required=True, help="Worker ID")
    create_parser.add_argument("--branch", help="Branch name (default: apex-swarm-{id})")
    create_parser.add_argument("--task", help="Task description")
    
    # Destroy
    destroy_parser = subparsers.add_parser("destroy", help="Remove worker worktree")
    destroy_parser.add_argument("--id", type=int, help="Worker ID")
    destroy_parser.add_argument("--all", action="store_true", help="Remove all workers")
    
    # List
    subparsers.add_parser("list", help="List active workers")
    
    args = parser.parse_args()
    
    if args.action == "create":
        result = create_worker(args.id, args.branch, args.task)
    elif args.action == "destroy":
        result = destroy_worker(args.id, args.all)
    elif args.action == "list":
        result = list_workers()
    
    print(json.dumps(result, indent=2))
    sys.exit(0 if result.get("success", False) else 1)


if __name__ == "__main__":
    main()
