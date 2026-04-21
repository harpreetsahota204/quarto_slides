# Quarto Slides

Turn any Jupyter notebook into a branded Reveal.js presentation with the Voxel51 theme.

## What's in here

| File | Purpose |
|---|---|
| `present.sh` | One-command build + serve script |
| `make_slides.py` | Converts a source notebook into a Quarto-ready slides notebook |
| `voxel51.scss` | Custom Reveal.js theme (colors, fonts, layout from the Voxel51 Style Guide) |
| `voxel51-highlight.theme` | Syntax highlighting theme for code blocks |
| `assets/voxel51-logo.png` | Logo displayed on every slide |

Generated files (`*_slides.ipynb`, `*_slides.html`, `*_slides_files/`) are gitignored.

## Install Quarto (one-time, system-wide)

Install Quarto globally so it's available from any project.

### Linux (arm64)

```bash
curl -L -o quarto.tar.gz \
  https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.36/quarto-1.9.36-linux-arm64.tar.gz
sudo mkdir -p /usr/local/quarto
sudo tar -xzf quarto.tar.gz --strip-components=1 -C /usr/local/quarto
sudo ln -sf /usr/local/quarto/bin/quarto /usr/local/bin/quarto
rm quarto.tar.gz
```

### Linux (x86_64)

```bash
curl -L -o quarto.tar.gz \
  https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.36/quarto-1.9.36-linux-amd64.tar.gz
sudo mkdir -p /usr/local/quarto
sudo tar -xzf quarto.tar.gz --strip-components=1 -C /usr/local/quarto
sudo ln -sf /usr/local/quarto/bin/quarto /usr/local/bin/quarto
rm quarto.tar.gz
```

### macOS

```bash
brew install quarto
```

Verify it works:

```bash
quarto --version
```

See [github.com/quarto-dev/quarto-cli/releases](https://github.com/quarto-dev/quarto-cli/releases) for other platforms and newer versions.

## Usage

From the **repo root**:

```bash
./quarto_slides/present.sh path/to/notebook.ipynb --title "My Talk"
```

Or from **inside `quarto_slides/`**:

```bash
bash present.sh ../bnd_workshop.ipynb --title "Finding the Birds Nest"
```

This single command:

1. Reads your source notebook and generates a `_slides.ipynb` with Quarto front-matter
2. Renders it to a Reveal.js HTML presentation (code cells are displayed but not executed)
3. Starts a local HTTP server so you can view the slides in a browser

### Options

| Flag | Description |
|---|---|
| `--title "..."` | Set the slide deck title |
| `--slide-level N` | Heading level that starts a new slide (default: 5 = every heading) |
| `PORT=9000` | Use a custom port (default: 8765) |

### Example

```bash
./quarto_slides/present.sh bnd_workshop.ipynb --title "Finding the Birds Nest"
```

Then open the URL printed in the terminal.

## Important

Save your notebook (Ctrl+S) before running `present.sh` -- the script reads whatever is on disk.
