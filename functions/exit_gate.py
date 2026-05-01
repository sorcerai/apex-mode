#!/usr/bin/env python3
"""
APEX Exit Gate
Evaluates Navigator/Pilot-style dual-condition completion gates.

Exit requires:
1. Enough completion heuristics are true
2. Explicit EXIT_SIGNAL is true, unless disabled
"""

import argparse
import json
import sys
from typing import Any


def parse_indicators(raw: str) -> dict[str, bool]:
    data = json.loads(raw)
    if isinstance(data, list):
        return {str(item): True for item in data}
    if isinstance(data, dict):
        return {str(k): bool(v) for k, v in data.items()}
    raise ValueError("indicators must be object or array")


def evaluate(indicators: dict[str, bool], exit_signal: bool, required: int = 2, require_explicit: bool = True) -> dict[str, Any]:
    met = [name for name, value in indicators.items() if value]
    missing = [name for name, value in indicators.items() if not value]
    heuristics_met = len(met) >= required
    explicit_met = exit_signal or not require_explicit
    can_exit = heuristics_met and explicit_met

    if can_exit:
        decision = "exit"
        reason = "heuristics and explicit signal satisfied" if require_explicit else "heuristics satisfied"
    elif heuristics_met and not explicit_met:
        decision = "continue"
        reason = "heuristics met but explicit EXIT_SIGNAL missing"
    elif exit_signal and not heuristics_met:
        decision = "blocked"
        reason = "EXIT_SIGNAL present but insufficient completion indicators"
    else:
        decision = "continue"
        reason = "more work needed"

    return {
        "can_exit": can_exit,
        "decision": decision,
        "reason": reason,
        "heuristics_met": heuristics_met,
        "explicit_met": explicit_met,
        "required": required,
        "met_count": len(met),
        "total_count": len(indicators),
        "met": met,
        "missing": missing,
        "exit_signal": exit_signal,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="APEX dual-condition exit gate")
    parser.add_argument("--indicators", required=True, help="JSON object/list of completion indicators")
    parser.add_argument("--exit-signal", default="false", help="true/false explicit completion signal")
    parser.add_argument("--required", type=int, default=2, help="Required heuristic count")
    parser.add_argument("--no-explicit", action="store_true", help="Do not require explicit EXIT_SIGNAL")
    args = parser.parse_args()

    indicators = parse_indicators(args.indicators)
    exit_signal = str(args.exit_signal).lower() in {"1", "true", "yes", "y"}
    result = evaluate(indicators, exit_signal, args.required, not args.no_explicit)
    print(json.dumps(result, indent=2))
    return 0 if result["can_exit"] else 1


if __name__ == "__main__":
    sys.exit(main())
