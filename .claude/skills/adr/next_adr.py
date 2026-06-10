#!/usr/bin/env python3
"""Determine the next ADR filename in ADR-###-{name}.md format."""
import sys
import os
import re


def next_adr_name(adrs_dir, adr_slug):
    if not os.path.isdir(adrs_dir):
        print(f"ADR-0001-{adr_slug}.md")
        return

    existing = []
    for f in os.listdir(adrs_dir):
        m = re.match(r"^ADR-(\d+)-.*\.md$", f)
        if m:
            existing.append(int(m.group(1)))

    next_num = max(existing, default=0) + 1
    print(f"ADR-{next_num:04d}-{adr_slug}.md")


if __name__ == "__main__":
    adrs_dir = sys.argv[1] if len(sys.argv) > 1 else "docs/adrs"
    adr_slug = sys.argv[2] if len(sys.argv) > 2 else "untitled"
    next_adr_name(adrs_dir, adr_slug)
