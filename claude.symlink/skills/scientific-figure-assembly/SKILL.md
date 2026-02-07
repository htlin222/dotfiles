---
name: scientific-figure-assembly
description: Assemble multi-panel scientific figures with panel labels (A, B, C) at publication quality (300 DPI). Use when combining individual plots into journal-ready figures.
allowed-tools: Bash(uv run *), Bash(python *), Write
---

# Scientific Figure Assembly

Create publication-ready multi-panel figures from individual plot files by combining them with professional panel labels (A, B, C, D) at 300 DPI resolution.

## When to Use

- Combining multiple plots into a single multi-panel figure for publication
- Adding panel labels (A, B, C) to existing figures
- Ensuring figures meet journal requirements (300 DPI minimum)
- Creating consistent figure layouts for manuscripts
- Preparing figures for Nature, Science, Cell, JAMA, Lancet submissions

## Quick Start

Tell me:
1. **Input files**: Paths to individual PNG/JPG files
2. **Layout**: Vertical (stacked), horizontal (side-by-side), or grid (2x2, 2x3, etc.)
3. **Output name**: What to call the final figure
4. **Labels**: Which panel labels to use (default: A, B, C, D...)

I'll create a Python script using PIL/Pillow to assemble the figure with proper spacing and labels.

## Script Template

I'll create a script like this for your specific needs:

```python
#!/usr/bin/env python3
"""Assemble multi-panel scientific figure."""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

def add_panel_label(img, label, position='top-left',
                   font_size=80, offset=(40, 40),
                   bg_color='white', text_color='black',
                   border=True):
    """
    Add panel label (A, B, C) to image.

    Args:
        img: PIL Image object
        label: Label text (e.g., 'A', 'B', 'C')
        position: 'top-left', 'top-right', 'bottom-left', 'bottom-right'
        font_size: Font size in pixels (80 works well for 3000px wide images)
        offset: (x, y) offset from corner in pixels
        bg_color: Background color for label box
        text_color: Label text color
        border: Whether to draw border around label box
    """
    draw = ImageDraw.Draw(img)

    # Try system fonts (macOS, then Linux)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        try:
            font = ImageFont.truetype(
                "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size
            )
        except:
            font = ImageFont.load_default()
            print(f"Warning: Using default font for label {label}")

    # Calculate label position
    x, y = offset
    if 'right' in position:
        bbox = draw.textbbox((0, 0), label, font=font)
        text_width = bbox[2] - bbox[0]
        x = img.width - text_width - offset[0]
    if 'bottom' in position:
        bbox = draw.textbbox((0, 0), label, font=font)
        text_height = bbox[3] - bbox[1]
        y = img.height - text_height - offset[1]

    # Draw background box
    bbox = draw.textbbox((x, y), label, font=font)
    padding = 10
    draw.rectangle(
        [bbox[0] - padding, bbox[1] - padding,
         bbox[2] + padding, bbox[3] + padding],
        fill=bg_color,
        outline='black' if border else None,
        width=2 if border else 0
    )

    # Draw text
    draw.text((x, y), label, fill=text_color, font=font)

    return img


def assemble_vertical(input_files, output_file, labels=None,
                     spacing=40, dpi=300):
    """
    Stack images vertically with panel labels.

    Args:
        input_files: List of paths to input images
        output_file: Path for output image
        labels: List of labels (default: A, B, C, ...)
        spacing: Vertical spacing between panels in pixels
        dpi: Output resolution
    """
    if labels is None:
        labels = [chr(65 + i) for i in range(len(input_files))]  # A, B, C, ...

    # Load all images
    images = [Image.open(f) for f in input_files]

    # Add labels
    labeled = [add_panel_label(img, label)
               for img, label in zip(images, labels)]

    # Calculate dimensions
    max_width = max(img.width for img in labeled)
    total_height = sum(img.height for img in labeled) + spacing * (len(labeled) - 1)

    # Create combined image
    combined = Image.new('RGB', (max_width, total_height), 'white')

    # Paste images
    y_offset = 0
    for img in labeled:
        combined.paste(img, (0, y_offset))
        y_offset += img.height + spacing

    # Save with specified DPI
    combined.save(output_file, dpi=(dpi, dpi))
    print(f"✅ Created {output_file}")
    print(f"   Dimensions: {combined.width}×{combined.height} px at {dpi} DPI")

    return output_file


def assemble_horizontal(input_files, output_file, labels=None,
                       spacing=40, dpi=300):
    """Stack images horizontally with panel labels."""
    if labels is None:
        labels = [chr(65 + i) for i in range(len(input_files))]

    images = [Image.open(f) for f in input_files]
    labeled = [add_panel_label(img, label)
               for img, label in zip(images, labels)]

    max_height = max(img.height for img in labeled)
    total_width = sum(img.width for img in labeled) + spacing * (len(labeled) - 1)

    combined = Image.new('RGB', (total_width, max_height), 'white')

    x_offset = 0
    for img in labeled:
        combined.paste(img, (x_offset, 0))
        x_offset += img.width + spacing

    combined.save(output_file, dpi=(dpi, dpi))
    print(f"✅ Created {output_file}")
    print(f"   Dimensions: {combined.width}×{combined.height} px at {dpi} DPI")

    return output_file


def assemble_grid(input_files, output_file, rows, cols,
                 labels=None, spacing=40, dpi=300):
    """
    Arrange images in a grid with panel labels.

    Args:
        rows: Number of rows
        cols: Number of columns
        Other args same as assemble_vertical
    """
    if labels is None:
        labels = [chr(65 + i) for i in range(len(input_files))]

    images = [Image.open(f) for f in input_files]
    labeled = [add_panel_label(img, label)
               for img, label in zip(images, labels)]

    # Calculate cell dimensions (use max from each row/col)
    cell_width = max(img.width for img in labeled)
    cell_height = max(img.height for img in labeled)

    # Total dimensions
    total_width = cell_width * cols + spacing * (cols - 1)
    total_height = cell_height * rows + spacing * (rows - 1)

    combined = Image.new('RGB', (total_width, total_height), 'white')

    # Place images
    for idx, img in enumerate(labeled):
        if idx >= rows * cols:
            break
        row = idx // cols
        col = idx % cols
        x = col * (cell_width + spacing)
        y = row * (cell_height + spacing)
        combined.paste(img, (x, y))

    combined.save(output_file, dpi=(dpi, dpi))
    print(f"✅ Created {output_file}")
    print(f"   Dimensions: {combined.width}×{combined.height} px at {dpi} DPI")

    return output_file


if __name__ == '__main__':
    import sys

    # Example usage
    if len(sys.argv) < 3:
        print("Usage: python assemble_figures.py <output> <layout> <input1> <input2> ...")
        print("  layout: vertical, horizontal, or grid:RxC (e.g., grid:2x2)")
        sys.exit(1)

    output = sys.argv[1]
    layout = sys.argv[2]
    inputs = sys.argv[3:]

    if layout == 'vertical':
        assemble_vertical(inputs, output)
    elif layout == 'horizontal':
        assemble_horizontal(inputs, output)
    elif layout.startswith('grid:'):
        rows, cols = map(int, layout.split(':')[1].split('x'))
        assemble_grid(inputs, output, rows, cols)
    else:
        print(f"Unknown layout: {layout}")
        sys.exit(1)
```

## Common Layouts

### Vertical (Most Common)
Stack plots on top of each other - good for showing progression or related outcomes.

**Example**: Three forest plots (pCR, EFS, OS) stacked vertically
- Panel A: pCR forest plot
- Panel B: EFS forest plot
- Panel C: OS forest plot

### Horizontal
Place plots side-by-side - good for comparisons.

**Example**: Two funnel plots showing publication bias
- Panel A: pCR funnel plot
- Panel B: EFS funnel plot

### Grid (2x2, 2x3, etc.)
Arrange in rows and columns - good for systematic comparisons.

**Example**: 2x2 grid of subgroup analyses
- Panel A: Age subgroup
- Panel B: Sex subgroup
- Panel C: Stage subgroup
- Panel D: Histology subgroup

## Workflow

### Step 1: Verify Input Files
```bash
# Check that all files exist and are PNG/JPG
ls -lh path/to/plots/*.png
```

### Step 2: Create Assembly Script
I'll generate a custom script based on your layout needs using the template above.

### Step 3: Run Assembly
```bash
# Using uv (recommended for dependency management)
uv run python assemble_figures.py Figure1_Efficacy.png vertical \
    forest_plot_pCR.png \
    forest_plot_EFS.png \
    forest_plot_OS.png

# Or with system Python (requires PIL/Pillow)
python assemble_figures.py Figure1.png grid:2x2 \
    plot1.png plot2.png plot3.png plot4.png
```

### Step 4: Verify Output
```bash
# Check dimensions and file size
ls -lh Figure1_Efficacy.png

# Verify DPI (should show 300x300)
file Figure1_Efficacy.png
```

## Customization Options

### Font Size Adjustment
For different image sizes:
- 3000px wide images: `font_size=80` (default)
- 1500px wide images: `font_size=40`
- 6000px wide images: `font_size=160`

### Label Position
- `position='top-left'` (default)
- `position='top-right'`
- `position='bottom-left'`
- `position='bottom-right'`

### Spacing Between Panels
- Default: `spacing=40` pixels
- Tight spacing: `spacing=20`
- Loose spacing: `spacing=80`

### Label Style
- White background with black border (default, best visibility)
- Transparent background: `bg_color=None, border=False`
- Custom colors: `bg_color='#f0f0f0', text_color='#333333'`

## Journal Requirements

### Nature, Science, Cell
- **Resolution**: 300-600 DPI
- **Format**: TIFF or high-quality PDF preferred, PNG acceptable
- **Width**: 89mm (single column) or 183mm (double column) at final size
- **Font**: Arial, Helvetica, or similar sans-serif
- **Labels**: Bold, 8-10pt at final size

### Lancet, JAMA, NEJM
- **Resolution**: 300 DPI minimum
- **Format**: TIFF, EPS, or PNG
- **Width**: Fit within column width (typically 3-4 inches)
- **Labels**: Clear, high contrast
- **Grayscale**: Must be readable in B&W

## Quality Checklist

Before submitting:
- [ ] All figures at 300 DPI minimum
- [ ] Panel labels (A, B, C) visible and correctly ordered
- [ ] Labels don't obscure important data
- [ ] All panels aligned properly
- [ ] Spacing consistent between panels
- [ ] File size reasonable (<10 MB for PNG)
- [ ] Figures readable when printed at final journal size
- [ ] Color schemes work in grayscale (if required)

## Common Issues & Solutions

**Problem**: Labels too small
**Solution**: Increase `font_size` parameter (try doubling it)

**Problem**: Labels obscure data
**Solution**: Change `position` to different corner or adjust `offset`

**Problem**: DPI too low
**Solution**: Regenerate input plots at higher resolution first, then reassemble

**Problem**: Uneven spacing
**Solution**: Crop input images to remove excess white space before assembly

**Problem**: File too large
**Solution**: Use PNG compression or convert to JPEG (may lose quality)

## Example Use Cases

### Meta-Analysis Figures
```bash
# Figure 1: Efficacy outcomes (3 vertical panels)
uv run python assemble.py Figure1_Efficacy.png vertical \
    forest_plot_pCR.png \
    forest_plot_EFS.png \
    forest_plot_OS.png

# Figure 2: Safety + Bias (2 vertical panels)
uv run python assemble.py Figure2_Safety.png vertical \
    forest_plot_SAE.png \
    funnel_plot_pCR.png
```

### Experimental Results
```bash
# Figure 3: Western blots (2x3 grid)
uv run python assemble.py Figure3_WesternBlots.png grid:2x3 \
    wb_control_t0.png wb_treated_t0.png \
    wb_control_t24.png wb_treated_t24.png \
    wb_control_t48.png wb_treated_t48.png
```

### Microscopy
```bash
# Figure 4: IF images (2x2 grid)
uv run python assemble.py Figure4_Immunofluorescence.png grid:2x2 \
    if_dapi.png if_fitc.png \
    if_tritc.png if_merged.png
```

## Dependencies

```bash
# Install using uv (recommended)
uv add Pillow

# Or using pip
pip install Pillow
```

## Output Example

```
✅ Created Figure1_Efficacy.png
   Dimensions: 3000×6080 px at 300 DPI
```

The output file will have:
- Professional panel labels (A, B, C) in top-left corners
- Consistent spacing between panels
- 300 DPI resolution suitable for publication
- White background with black border around labels for maximum visibility

## Related Skills

- `/meta-manuscript-assembly` - Complete meta-analysis manuscript preparation
- `/plot-publication` - Create individual publication-ready plots
- `/figure-legends` - Generate comprehensive figure legends

## Pro Tips

1. **Generate high-quality inputs first**: Assemble won't improve low-quality source plots
2. **Use consistent input sizes**: Makes alignment easier
3. **Label systematically**: A-B-C top-to-bottom or left-to-right
4. **Check in print preview**: Ensure labels readable at final print size
5. **Keep originals**: Save both individual plots and assembled figures
6. **Automate repetition**: Create a shell script if assembling many similar figures
