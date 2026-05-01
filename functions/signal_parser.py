#!/usr/bin/env python3
"""Parse Pilot Signal Protocol v2 JSON code blocks from agent output."""

import argparse
import json
import re
import sys
from typing import Any

SIGNAL_RE = re.compile(r"```pilot-signal\s*(\{.*?\})\s*```", re.DOTALL)


def parse_signals(text: str) -> list[dict[str, Any]]:
    signals = []
    for match in SIGNAL_RE.finditer(text):
        raw = match.group(1)
        try:
            signal = json.loads(raw)
            if signal.get("v") == 2 and isinstance(signal.get("type"), str):
                signals.append(signal)
        except json.JSONDecodeError:
            signals.append({"error": "invalid_json", "raw": raw})
    return signals


def main() -> int:
    parser = argparse.ArgumentParser(description="Parse pilot-signal code blocks")
    parser.add_argument("--file", help="File to parse. Defaults stdin.")
    args = parser.parse_args()
    text = open(args.file).read() if args.file else sys.stdin.read()
    signals = parse_signals(text)
    print(json.dumps({"signals": signals, "count": len(signals)}, indent=2))
    return 0 if signals else 1


if __name__ == "__main__":
    sys.exit(main())
