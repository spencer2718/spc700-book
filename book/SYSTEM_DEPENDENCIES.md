# System dependencies for the textbook build

The book PDF is produced by `book/build.sh`, which runs
`book/preprocess.py` and then Pandoc + XeLaTeX. The Python side
needs nothing beyond the standard library; the LaTeX side is
where most of the install effort goes.

## Required tools

- **Python 3.8+** — runs the preprocessor.
- **Pandoc 3.0 or later** — the Markdown-to-LaTeX converter.
  Older 2.x versions probably work but are not tested.
- **XeLaTeX** — the LaTeX engine. We need XeLaTeX rather than
  pdfLaTeX or LuaLaTeX because `metadata.yaml` selects fonts by
  name (`mainfont: TeX Gyre Pagella`, etc.) via fontspec, which
  requires Xe- or Lua-LaTeX.

## LaTeX packages

The packages used by `preamble.tex` are all in the standard
TeX Live distribution. They are:

- `microtype`
- `xcolor`
- `titlesec`
- `fancyhdr`
- `enumitem`
- `array`, `booktabs`, `longtable` (table formatting)
- `tikz`
- `fontspec` (pulled in by XeLaTeX through Pandoc)
- `hyperref` (pulled in by Pandoc for `colorlinks: true`)

Pandoc itself emits use of `unicode-math`, `parskip`, `lmodern`
(as a fallback), and a handful of others. A "scheme-medium"
TeX Live install or `texlive-latex-recommended` +
`texlive-xetex` covers everything we need.

## Fonts

`metadata.yaml` requests:

- `TeX Gyre Pagella` (main text)
- `TeX Gyre Heros` (sans-serif)
- `DejaVu Sans Mono` (code)

TeX Gyre Pagella and Heros ship with TeX Live 2022+ in the
`tex-gyre` package. DejaVu Sans Mono is usually preinstalled on
Linux and macOS; on Windows it ships with most TeX
distributions. If a font lookup fails at build time, install the
font system-wide and rerun.

## Install commands

### Ubuntu / Debian

```sh
sudo apt-get install -y \
    pandoc \
    texlive-xetex \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    fonts-dejavu
```

### macOS (Homebrew)

```sh
brew install pandoc
brew install --cask mactex-no-gui   # full TeX Live, no GUI
# Or: basictex, then `tlmgr install` the missing packages.
```

### Windows

Install [Pandoc](https://pandoc.org/installing.html) and
[MiKTeX](https://miktex.org) (or TeX Live for Windows). MiKTeX
will install missing LaTeX packages on first use; TeX Live
installs them all up front.

## CI build

The GitHub Actions workflow uses the `pandoc/latex` Docker image,
which bundles Pandoc and a TeX Live distribution sufficient for
the preamble. CI is the canonical "the build works" check;
local builds are a convenience.
