# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HillSideView (HSV) is a wireless split ergonomic keyboard PCB design based on the Hillside 46. It's a hardware project using KiCad for PCB design with automated fabrication and documentation generation via KiBot.

Key features:
- 3x6+5 or 3x5+5 column-staggered layout with choc spacing
- nice!nano MCU with nice!view e-paper display for wireless use
- Optional cirque trackpad support with FFC connector
- Reversible PCB design
- JLCPCB PCBA-ready with optional factory assembly
- 3D printed case with magnetic tenting stand
- ZMK and QMK firmware support

## Project Structure

```
hillsideview46/           # Main PCB design directory
├── hillsideview46.kicad_* # KiCad project files (schematic, PCB, settings)
├── bin/                  # Build automation scripts
│   ├── fab.kibot.yaml    # KiBot config for fabrication files
│   ├── doc.kibot.yaml    # KiBot config for documentation
│   └── pos_back.py       # Converts position file for bottom-side assembly
├── case/                 # 3D printed case STL files
│   ├── 5_column/         # Files for 3x5 variant
│   ├── 6_column/         # Files for 3x6 variant
│   ├── cirque/           # Trackpad holder
│   └── display_cover/    # Display covers
├── doc/                  # Documentation and images
└── jlcpcb/              # Manufacturing output (gerbers, BOM, position files)

doc/                      # Repository-wide documentation
lib/                      # 3D models for KiCad components
```

## Common Commands

### Generate Fabrication Files

The fabrication workflow generates gerbers, drill files, BOM, and position files for JLCPCB:

```bash
# Run via GitHub Actions (recommended)
# Triggered automatically on push to hillsideview46/*.kicad_* files
# Or manually via workflow_dispatch

# Local generation (requires KiBot Docker image)
cd hillsideview46
docker run --rm -v $(pwd):/board setsoft/kicad_auto:latest \
  kibot -c bin/fab.kibot.yaml -b hillsideview46.kicad_pcb -e hillsideview46.kicad_sch

# Generate bottom-side position file
./bin/pos_back.py < pcba/top_boards.csv > pcba/bottom_boards.csv
```

Output location: `hillsideview46/gerber/` and `hillsideview46/pcba/`

### Generate Documentation

The documentation workflow creates schematics, 3D renders, and interactive BOM:

```bash
# Run via GitHub Actions (recommended)
# Or manually via workflow_dispatch

# Local generation (requires KiBot Docker image)
cd hillsideview46
docker run --rm -v $(pwd):/board setsoft/kicad_auto:latest \
  kibot -c bin/doc.kibot.yaml -b hillsideview46.kicad_pcb -e hillsideview46.kicad_sch
```

Output location: `hillsideview46/doc_out/`

### KiCad Python CLI Tools

KiCad 7.0.11 is installed in the environment and provides both CLI tools and Python API for programmatic PCB manipulation.

**Installation** (already done in this environment):
```bash
apt-get update && apt-get install -y kicad
```

**Python API Usage**:
```python
import pcbnew

# Load the PCB
board = pcbnew.LoadBoard("hillsideview46/hillsideview46.kicad_pcb")

# Get board information
print(f"Board size: {board.ComputeBoundingBox().GetWidth()/1e6:.2f} x {board.ComputeBoundingBox().GetHeight()/1e6:.2f} mm")
print(f"Footprints: {len(list(board.GetFootprints()))}")
print(f"Copper layers: {board.GetCopperLayerCount()}")

# Iterate through footprints
for footprint in board.GetFootprints():
    print(f"{footprint.GetReference()}: {footprint.GetFPID().GetLibItemName()}")

# Save modifications
pcbnew.SaveBoard("output.kicad_pcb", board)
```

**CLI Tools**:
```bash
# Check version
kicad-cli version

# Export gerbers
kicad-cli pcb export gerbers --output gerber/ hillsideview46/hillsideview46.kicad_pcb

# Export drill files
kicad-cli pcb export drill --output gerber/ hillsideview46/hillsideview46.kicad_pcb

# Export position file
kicad-cli pcb export pos --output pcba/ hillsideview46/hillsideview46.kicad_pcb

# Export STEP file
kicad-cli pcb export step --output 3d/ hillsideview46/hillsideview46.kicad_pcb

# Export PDF
kicad-cli pcb export pdf --output docs/ hillsideview46/hillsideview46.kicad_pcb
```

**Common Python API Operations**:
- `pcbnew.LoadBoard(path)` - Load a PCB file
- `board.GetFootprints()` - Get all footprints
- `board.GetTracks()` - Get all tracks
- `board.GetDrawings()` - Get all drawings
- `footprint.GetReference()` - Get component reference (e.g., "D1")
- `footprint.GetValue()` - Get component value
- `footprint.GetPosition()` - Get position in nanometers
- `footprint.SetPosition(pos)` - Set position
- `pcbnew.SaveBoard(path, board)` - Save PCB file

## KiCad Design Files

- **hillsideview46.kicad_sch**: Schematic with MCU, switch matrix, display, and peripheral connections
- **hillsideview46.kicad_pcb**: PCB layout with reversible design
- **hillsideview46.kicad_pro**: KiCad project settings
- **fp-lib-table**: Footprint library table
- **sym-lib-table**: Symbol library table

The PCB is designed to be reversible - the same PCB can be used for left or right halves.

## Build Automation

### GitHub Actions Workflows

Located in `.github/workflows/`:

1. **fabricate.yaml**: Triggered on changes to KiCad files or build scripts
   - Runs ERC and DRC checks
   - Generates gerbers and drill files
   - Creates BOM and position files for PCBA
   - Produces both top and bottom position files for reversible assembly
   - Outputs: `hillsideview46-gerbers.zip` and PCBA files

2. **document.yaml**: Triggered on changes to doc config
   - Generates schematic SVG
   - Creates 3D renders
   - Produces interactive BOM (iBOM)
   - Generates switch layout diagrams
   - Outputs: `hillsideview46-Doc.zip`

### KiBot Configuration

**fab.kibot.yaml** (fabrication):
- Preflight: Runs ERC, DRC, zone fills check
- Gerber layers: All copper, paste, silk, mask, fab, courtyard, edges, User.Eco2
- Drill files: Separate PTH and NPTH with gerber maps
- BOM: Filters parts with LCSC codes for JLCPCB PCBA
- Position file: CSV format with rotation adjustments for JLCPCB

**doc.kibot.yaml** (documentation):
- PCB views: Trace layouts, switch outlines (mirrored for right hand)
- Schematic: SVG export
- 3D render: High-resolution PNG with custom copper color
- iBOM: Interactive assembly guide with top-bottom view
- BOM: HTML format with SMT/THT counts

## PCB Design Conventions

### Reversible Design

The PCB works for both left and right halves:
- Most SMT components are on the top for left, bottom for right
- The `pos_back.py` script rotates position coordinates by 180° for bottom assembly
- PCBA can be ordered with parts on one side only, or both sides for mixed builds

### Footprints and Tolerances

- Hotswap sockets: Mill-Max with 62 mil holes (accounting for ±2 mil drill tolerance)
- Switch spacing: 18mm x 17mm (choc spacing)
- Break-off outer pinky column design
- Tenting puck support holes
- FFC connector for cirque trackpad

### Components Requiring Hand Soldering

Not included in PCBA (must be hand-soldered):
- Switches
- MCU (nice!nano with mill-max sockets)
- Display (nice!view)
- TRRS jacks
- LEDs (SK6812-MINI-E)
- Battery power switch
- Optional: Mill-Max hotswap sockets for switches
- Optional: Rotary encoders

## 3D Printed Case

STL files in `hillsideview46/case/`:
- **5_column/**: Case for 3x5+5 layout (with and without outer pinky column)
- **6_column/**: Case for 3x6+5 layout (full size)
- **display_cover/**: Covers for both hands, with variants for mill-max sockets
- **cirque/**: Trackpad holder
- **Tenting stands**: Magnetic stands using 10x1mm magnets in case, 10x3mm in stand

The case design accommodates batteries up to 2000 mAh (306070 size) mounted under the PCB.

## Firmware

- **ZMK**: Primary wireless firmware
  - Full size config: https://github.com/mike1808/zmk-config
  - Five column config: https://github.com/wannabecoffeenerd/zmk-config
- **QMK**: Can be adapted from https://github.com/qmk/qmk_firmware/tree/master/keyboards/handwired/hillside

## Design Notes

- Drill tolerance typically ±2 mils, footprints account for this
- Board size: 100mm x 143mm
- Supports optional rotary encoders at upper or tucked thumb positions
- Four or five SK6812-MINI-E LEDs for underglow
- Power switch for nice!nano battery management
