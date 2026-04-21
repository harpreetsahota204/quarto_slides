#!/usr/bin/env python3
"""Prepare any Jupyter notebook for Quarto Reveal.js slides.

Usage:
  python3 quarto_slides/make_slides.py path/to/notebook.ipynb
  python3 quarto_slides/make_slides.py path/to/notebook.ipynb --title "My Talk"
  python3 quarto_slides/make_slides.py path/to/notebook.ipynb --slide-level 3

Output is written into the quarto_slides/ directory as <name>_slides.ipynb.
"""
from __future__ import annotations

import argparse
import json
import shutil
import uuid
from pathlib import Path

SLIDES_DIR = Path(__file__).resolve().parent


def _front_matter(title: str, slide_level: int) -> str:
    return f"""---
title: "{title}"
jupyter: python3
engines: [jupyter]
slide-level: {slide_level}
format:
  revealjs:
    theme: [default, voxel51.scss]
    highlight-style: voxel51-highlight.theme
    logo: voxel51-logo.png
    slide-number: true
    scrollable: true
    code-overflow: wrap
    smaller: true
    progress: true
    transition: fade
    transition-speed: fast
execute:
  echo: true
  warning: false
---
"""


def _strip_slideshow_metadata(nb: dict) -> None:
    for cell in nb.get("cells", []):
        meta = cell.get("metadata") or {}
        if "slideshow" in meta:
            cell["metadata"] = {k: v for k, v in meta.items() if k != "slideshow"}


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert a notebook to Quarto Reveal.js slides")
    parser.add_argument("notebook", help="Path to source .ipynb")
    parser.add_argument("--title", default=None, help="Slide deck title (default: notebook filename)")
    parser.add_argument("--slide-level", type=int, default=5,
                        help="Heading level that starts a new slide (default: 5 = every heading)")
    args = parser.parse_args()

    src = Path(args.notebook).resolve()
    if not src.exists():
        raise SystemExit(f"Not found: {src}")

    title = args.title or src.stem.replace("_", " ").title()
    dst = SLIDES_DIR / f"{src.stem}_slides.ipynb"

    nb = json.loads(src.read_text(encoding="utf-8"))
    _strip_slideshow_metadata(nb)

    front_cell = {
        "cell_type": "raw",
        "id": str(uuid.uuid4())[:8],
        "metadata": {},
        "source": _front_matter(title, args.slide_level).splitlines(keepends=True),
    }

    cells = nb.get("cells", [])
    if (
        cells
        and cells[0].get("cell_type") == "raw"
        and "".join(cells[0].get("source") or []).lstrip().startswith("---")
    ):
        cells[0] = front_cell
    else:
        cells.insert(0, front_cell)
    nb["cells"] = cells

    dst.write_text(json.dumps(nb, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")

    logo_src = SLIDES_DIR / "assets" / "voxel51-logo.png"
    logo_dst = SLIDES_DIR / "voxel51-logo.png"
    if logo_src.exists() and (not logo_dst.exists() or logo_src.stat().st_mtime > logo_dst.stat().st_mtime):
        shutil.copy2(logo_src, logo_dst)

    print(f"Wrote {dst}")


if __name__ == "__main__":
    main()
