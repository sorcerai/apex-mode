#!/usr/bin/env python3
"""
APEX Stagnation Detector
Improved stuck detection using hash-based state comparison.
Detects cycles of any length, not just immediate repetition.
"""

import argparse
import hashlib
import json
import sys
from typing import Optional


def hash_state(state: dict) -> str:
    """Create a hash of the current execution state."""
    # Include relevant state components
    relevant = {
        "phase": state.get("phase"),
        "indicators": sorted(state.get("indicators", {}).items()),
        "recent_files": sorted(state.get("recent_files", []))[-5:],
        "recent_actions": state.get("recent_actions", [])[-3:]
    }
    state_str = json.dumps(relevant, sort_keys=True)
    return hashlib.md5(state_str.encode()).hexdigest()[:12]


def detect_stagnation(
    history: list[str],
    threshold: int = 3,
    max_cycle_length: int = 5
) -> dict:
    """
    Detect stagnation patterns in state history.
    
    Args:
        history: List of state hashes
        threshold: Number of repetitions before flagging
        max_cycle_length: Maximum cycle length to detect
    
    Returns:
        Detection result with stagnation info
    """
    if len(history) < threshold:
        return {"stagnant": False, "reason": "insufficient_history"}
    
    # Check 1: Immediate repetition (A→A→A)
    last_n = history[-threshold:]
    if len(set(last_n)) == 1:
        return {
            "stagnant": True,
            "pattern_type": "immediate_repetition",
            "pattern": last_n[0],
            "count": threshold,
            "suggestion": "Same state repeated. Try a different approach."
        }
    
    # Check 2: Short cycles (A→B→A→B)
    for cycle_len in range(2, min(max_cycle_length + 1, len(history) // 2 + 1)):
        if len(history) < cycle_len * 2:
            continue
        
        # Get the last cycle_len * 2 states
        window = history[-(cycle_len * 2):]
        first_half = window[:cycle_len]
        second_half = window[cycle_len:]
        
        if first_half == second_half:
            return {
                "stagnant": True,
                "pattern_type": f"cycle_{cycle_len}",
                "pattern": first_half,
                "count": 2,
                "suggestion": f"Detected repeating cycle of length {cycle_len}. Break the loop."
            }
    
    # Check 3: Oscillation (A→B→A→B→A)
    if len(history) >= 5:
        last_5 = history[-5:]
        unique = list(dict.fromkeys(last_5))  # Preserve order, remove dupes
        if len(unique) == 2:
            # Check if it's oscillating
            expected = [unique[i % 2] for i in range(5)]
            if last_5 == expected or last_5 == expected[::-1]:
                return {
                    "stagnant": True,
                    "pattern_type": "oscillation",
                    "pattern": unique,
                    "count": 5,
                    "suggestion": "Oscillating between two states. Need a third approach."
                }
    
    return {"stagnant": False, "reason": "no_pattern_detected"}


def update_history(
    current_state: dict,
    history_file: str = None
) -> tuple[list[str], str]:
    """
    Update state history with current state.
    
    Returns:
        (updated_history, current_hash)
    """
    current_hash = hash_state(current_state)
    
    history = []
    if history_file:
        try:
            with open(history_file) as f:
                history = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            pass
    
    history.append(current_hash)
    
    # Keep last 20 states
    history = history[-20:]
    
    if history_file:
        with open(history_file, "w") as f:
            json.dump(history, f)
    
    return history, current_hash


def main():
    parser = argparse.ArgumentParser(description="APEX Stagnation Detector")
    subparsers = parser.add_subparsers(dest="action", required=True)
    
    # Check
    check_parser = subparsers.add_parser("check", help="Check for stagnation")
    check_parser.add_argument("--history", required=True, 
                              help="JSON array of state hashes or file path")
    check_parser.add_argument("--threshold", type=int, default=3)
    check_parser.add_argument("--max-cycle", type=int, default=5)
    
    # Update
    update_parser = subparsers.add_parser("update", help="Update history with current state")
    update_parser.add_argument("--state", required=True, help="Current state as JSON")
    update_parser.add_argument("--history-file", help="Path to history file")
    
    # Hash
    hash_parser = subparsers.add_parser("hash", help="Hash a state")
    hash_parser.add_argument("--state", required=True, help="State as JSON")
    
    args = parser.parse_args()
    
    if args.action == "check":
        # Parse history
        try:
            history = json.loads(args.history)
        except json.JSONDecodeError:
            # Try as file path
            try:
                with open(args.history) as f:
                    history = json.load(f)
            except:
                print(json.dumps({"error": "Invalid history format"}))
                sys.exit(1)
        
        result = detect_stagnation(history, args.threshold, args.max_cycle)
        print(json.dumps(result, indent=2))
        sys.exit(1 if result.get("stagnant") else 0)
    
    elif args.action == "update":
        state = json.loads(args.state)
        history, current_hash = update_history(state, args.history_file)
        result = detect_stagnation(history)
        result["current_hash"] = current_hash
        result["history_length"] = len(history)
        print(json.dumps(result, indent=2))
        sys.exit(1 if result.get("stagnant") else 0)
    
    elif args.action == "hash":
        state = json.loads(args.state)
        print(hash_state(state))


if __name__ == "__main__":
    main()
