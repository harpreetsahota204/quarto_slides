#!/usr/bin/env bash
#
# Turn any Jupyter notebook into Quarto Reveal.js slides and serve them.
# All output (slides notebook, HTML, assets) stays inside quarto_slides/.
#
# Usage:
#   ./quarto_slides/present.sh path/to/notebook.ipynb                  # full render + serve
#   ./quarto_slides/present.sh path/to/notebook.ipynb --quick          # render without execution
#   ./quarto_slides/present.sh path/to/notebook.ipynb --title "My Talk"
#   ./quarto_slides/present.sh path/to/notebook.ipynb --slide-level 3
#   PORT=9000 ./quarto_slides/present.sh path/to/notebook.ipynb        # custom port
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
QUARTO="${REPO_ROOT}/.quarto-cli/bin/quarto"

[[ -x "$QUARTO" ]] || { echo "Error: Quarto not found at ${QUARTO}"; echo "Download from https://github.com/quarto-dev/quarto-cli/releases"; exit 1; }

# ── Parse args ──────────────────────────────────────────────────────
NOTEBOOK=""
QUICK=0
EXTRA_ARGS=()

for arg in "$@"; do
  case "$arg" in
    --quick)  QUICK=1 ;;
    *.ipynb)  NOTEBOOK="$arg" ;;
    *)        EXTRA_ARGS+=("$arg") ;;
  esac
done

if [[ -z "$NOTEBOOK" ]]; then
  echo "Usage: $0 <notebook.ipynb> [--quick] [--title \"...\"] [--slide-level N]"
  exit 1
fi

NOTEBOOK="$(cd "$(dirname "$NOTEBOOK")" && pwd)/$(basename "$NOTEBOOK")"
[[ -f "$NOTEBOOK" ]] || { echo "Error: $NOTEBOOK not found"; exit 1; }

STEM="$(basename "$NOTEBOOK" .ipynb)"
SLIDES_NB="${SCRIPT_DIR}/${STEM}_slides.ipynb"
SLIDES_HTML="${SCRIPT_DIR}/${STEM}_slides.html"

# ── Build slides notebook ───────────────────────────────────────────
echo "▸ Preparing slides from $(basename "$NOTEBOOK")..."
python3 "${SCRIPT_DIR}/make_slides.py" "$NOTEBOOK" "${EXTRA_ARGS[@]}"

# ── Render with Quarto ──────────────────────────────────────────────
echo "▸ Rendering with Quarto..."
if [[ "$QUICK" -eq 1 ]]; then
  "$QUARTO" render "$SLIDES_NB" --no-execute
else
  "$QUARTO" render "$SLIDES_NB"
fi

# ── Serve ───────────────────────────────────────────────────────────
PORT="${PORT:-8765}"
HOST="${HOST:-0.0.0.0}"
REL_HTML="$(basename "$SLIDES_HTML")"

# Kill any existing process on the port
if command -v fuser &>/dev/null; then
  fuser -k "${PORT}/tcp" 2>/dev/null && sleep 0.5
elif command -v lsof &>/dev/null; then
  lsof -ti :"$PORT" | xargs -r kill 2>/dev/null && sleep 0.5
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Slides:  http://127.0.0.1:${PORT}/${REL_HTML}"
echo "  (Ctrl+C to stop)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
exec python3 -m http.server "$PORT" --bind "$HOST" --directory "$SCRIPT_DIR"
