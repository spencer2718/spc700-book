#!/usr/bin/env python3
"""Preprocess SPC-700 textbook for pandoc.

Reads `spc700_textbook.md` from this script's own directory and writes
`spc700_textbook_processed.md` next to it. No command-line arguments.
"""

import re
from pathlib import Path

BASE = Path(__file__).resolve().parent
INPUT_PATH = BASE / "spc700_textbook.md"
OUTPUT_PATH = BASE / "spc700_textbook_processed.md"

with INPUT_PATH.open("r", encoding="utf-8") as f:
    text = f.read()

# 1. Strip top-level title and italic subtitle (we'll put them in YAML)
text = re.sub(r'^# The SPC-700 for SNES Musicians\s*\n+', '', text, count=1)
text = re.sub(r'^\*Computer architecture[^*]+\*\s*\n+---\s*\n+', '', text, count=1)

# 2. Strip "Chapter N: " prefix from chapter headings
text = re.sub(r'^## Chapter \d+:\s*', '## ', text, flags=re.MULTILINE)

# 3. Strip "Part I — ", "Part II — ", etc. from part headings
text = re.sub(r'^# Part [IVX]+\s*—\s*', '# ', text, flags=re.MULTILINE)

# 4. Mark frontmatter chapters as unnumbered
text = text.replace(
    '## Preface',
    '## Preface {.unnumbered}',
    1
)
text = text.replace(
    '## How to Use This Book',
    '## How to Use This Book {.unnumbered}',
    1
)

# 5. Process appendices
appendix_start = text.find('# Appendix A:')
if appendix_start == -1:
    raise SystemExit("Could not find Appendix A")

main_text = text[:appendix_start]
appendix_text = text[appendix_start:]

# Bump existing ## within appendices to ###
appendix_text = re.sub(r'^## ', '### ', appendix_text, flags=re.MULTILINE)
# Convert # Appendix X: Title to ## Title (LaTeX \appendix will prefix "Appendix X")
appendix_text = re.sub(r'^# Appendix [A-Z]:\s*', '## ', appendix_text, flags=re.MULTILINE)
# Switch LaTeX into appendix mode and add a part-level divider
appendix_text = (
    '\n```{=latex}\n\\appendix\n```\n\n'
    '# Appendices\n\n' + appendix_text
)

text = main_text + appendix_text

# 6. Reformat the BRR filter table — column 3 wraps badly under longtable
old_table = """| Filter | Equation                                            | Use |
|--------|-----------------------------------------------------|-----|
| 0      | new = s                                             | No prediction. Always safe. |
| 1      | new = s + old × 15/16                               | Simple decay; good for bass. |
| 2      | new = s + old × 61/32 − older × 15/16               | Stronger prediction; good for sustained tones. |
| 3      | new = s + old × 115/64 − older × 13/16              | Very aggressive; good for highly correlated samples. |"""

new_table = """| Filter | Equation                                | Typical use            |
|:------:|:----------------------------------------|:-----------------------|
| 0      | new = s                                 | No prediction          |
| 1      | new = s + old × 15/16                   | Bass, slow envelopes   |
| 2      | new = s + old × 61/32 − older × 15/16   | Sustained tones        |
| 3      | new = s + old × 115/64 − older × 13/16  | Highly correlated      |"""

if old_table in text:
    text = text.replace(old_table, new_table)

with OUTPUT_PATH.open("w", encoding="utf-8") as f:
    f.write(text)

print(f"Preprocessed OK: {OUTPUT_PATH}")
