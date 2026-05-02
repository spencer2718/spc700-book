#!/usr/bin/env bash
# Build the SPC-700 textbook PDF from Markdown.
# Run from anywhere; the script cd's to its own directory before working.

set -euo pipefail

cd "$(dirname "$0")"

if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python >/dev/null 2>&1; then
    PYTHON=python
else
    echo "Error: python or python3 not found in PATH." >&2
    exit 1
fi

if ! command -v pandoc >/dev/null 2>&1; then
    echo "Error: pandoc not found in PATH. See SYSTEM_DEPENDENCIES.md." >&2
    exit 1
fi

if ! command -v xelatex >/dev/null 2>&1; then
    echo "Error: xelatex not found in PATH. See SYSTEM_DEPENDENCIES.md." >&2
    exit 1
fi

echo "[1/2] Preprocessing Markdown..."
"$PYTHON" preprocess.py

echo "[2/2] Running pandoc + xelatex..."
pandoc spc700_textbook_processed.md \
    --metadata-file=metadata.yaml \
    --include-in-header=preamble.tex \
    --pdf-engine=xelatex \
    --toc --toc-depth=2 \
    --top-level-division=part \
    -o spc700_textbook.pdf

# File size reporting that works on both BSD (macOS) and GNU (Linux) stat,
# and on MSYS/Git-Bash where ls -l is the safest fallback.
if size_bytes=$(stat -c%s spc700_textbook.pdf 2>/dev/null); then :;
elif size_bytes=$(stat -f%z spc700_textbook.pdf 2>/dev/null); then :;
else size_bytes=$(wc -c <spc700_textbook.pdf | tr -d ' '); fi

size_kb=$(( size_bytes / 1024 ))
echo "Built spc700_textbook.pdf (${size_kb} KiB)."
