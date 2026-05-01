#!/usr/bin/env python3
"""Generate APEX_STATUS blocks for loop/yolo/pilot handoffs."""

import argparse
import json


def checkbox(value: bool) -> str:
    return "x" if value else " "


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate APEX_STATUS block")
    parser.add_argument("--phase", default="INIT")
    parser.add_argument("--iteration", type=int, default=1)
    parser.add_argument("--max-iterations", type=int, default=5)
    parser.add_argument("--progress", type=int)
    parser.add_argument("--indicators", default="{}", help="JSON object of indicator booleans")
    parser.add_argument("--exit-signal", default="false")
    parser.add_argument("--state-hash", default="unknown")
    parser.add_argument("--stagnation", type=int, default=0)
    parser.add_argument("--stagnation-threshold", type=int, default=3)
    parser.add_argument("--next-action", default="Continue")
    args = parser.parse_args()

    indicators = json.loads(args.indicators)
    met = sum(1 for v in indicators.values() if v)
    total = len(indicators)
    progress = args.progress if args.progress is not None else min(100, round((args.iteration / max(args.max_iterations, 1)) * 100))
    exit_signal = str(args.exit_signal).lower() in {"1", "true", "yes", "y"}

    lines = [
        "APEX_STATUS",
        "=" * 50,
        f"Phase: {args.phase}",
        f"Iteration: {args.iteration}/{args.max_iterations}",
        f"Progress: {progress}%",
        "",
        "Completion Indicators:",
    ]
    if indicators:
        for name, value in indicators.items():
            lines.append(f"  [{checkbox(bool(value))}] {name.replace('_', ' ')}")
    else:
        lines.append("  [ ] No indicators provided")
    lines.extend([
        "",
        "Exit Conditions:",
        f"  Heuristics: {met}/{total} (need 2+)",
        f"  EXIT_SIGNAL: {str(exit_signal).lower()}",
        "",
        f"Stagnation: {args.stagnation}/{args.stagnation_threshold}",
        f"State Hash: {args.state_hash}",
        f"Next Action: {args.next_action}",
        "=" * 50,
    ])
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
