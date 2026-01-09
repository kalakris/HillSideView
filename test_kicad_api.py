#!/usr/bin/env python3
"""
Test script to verify KiCad Python API is working with HillSideView project files
"""

import sys
import os

# Test PCB manipulation
try:
    import pcbnew
    print(f"✓ KiCad Python API version: {pcbnew.Version()}")

    # Load the HillSideView PCB
    pcb_path = "/home/user/HillSideView/hillsideview46/hillsideview46.kicad_pcb"
    if os.path.exists(pcb_path):
        print(f"✓ Found PCB file: {pcb_path}")

        board = pcbnew.LoadBoard(pcb_path)
        print(f"✓ Successfully loaded PCB")

        # Get basic board info
        print(f"\nBoard Information:")
        print(f"  - Board size: {board.ComputeBoundingBox().GetWidth()/1e6:.2f} x {board.ComputeBoundingBox().GetHeight()/1e6:.2f} mm")
        print(f"  - Number of modules/footprints: {len(list(board.GetFootprints()))}")
        print(f"  - Number of tracks: {len(list(board.GetTracks()))}")
        print(f"  - Number of copper layers: {board.GetCopperLayerCount()}")

        # List some footprints
        print(f"\nFirst 5 footprints:")
        for i, footprint in enumerate(list(board.GetFootprints())[:5]):
            print(f"  - {footprint.GetReference()}: {footprint.GetFPID().GetLibItemName()}")

        print("\n✓ All KiCad Python API tests passed!")
        sys.exit(0)
    else:
        print(f"✗ PCB file not found: {pcb_path}")
        sys.exit(1)

except ImportError as e:
    print(f"✗ Failed to import pcbnew: {e}")
    sys.exit(1)
except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
