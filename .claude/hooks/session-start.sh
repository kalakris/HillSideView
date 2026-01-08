#!/bin/bash
set -euo pipefail

# Only run in remote cloud environments (Claude Code on the web)
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  echo "Skipping session start hook - not running in remote environment"
  exit 0
fi

echo "=== HillSideView Session Start Hook ==="
echo "Setting up KiCad environment for PCB development..."

# Check if KiCad is already installed
if command -v kicad-cli &> /dev/null; then
  echo "✓ KiCad is already installed ($(kicad-cli version))"

  # Verify Python API is accessible
  if python3 -c "import pcbnew" &> /dev/null; then
    echo "✓ KiCad Python API is accessible"
  else
    echo "⚠ KiCad Python API not accessible, attempting reinstall..."
    NEEDS_INSTALL=true
  fi
else
  echo "KiCad not found, installing..."
  NEEDS_INSTALL=true
fi

# Install KiCad if needed
if [ "${NEEDS_INSTALL:-false}" = "true" ]; then
  echo "Installing KiCad 7.x from Ubuntu repositories..."

  # Update package lists (suppress most output)
  apt-get update -qq 2>&1 | grep -v "^Get:" | grep -v "^Hit:" | grep -v "^Ign:" || true

  # Install KiCad (suppress verbose output)
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq kicad > /dev/null 2>&1

  # Verify installation
  if command -v kicad-cli &> /dev/null && python3 -c "import pcbnew" &> /dev/null; then
    echo "✓ KiCad $(kicad-cli version) installed successfully"
    echo "✓ KiCad Python API available"
  else
    echo "✗ KiCad installation failed"
    exit 1
  fi
fi

echo "=== Setup Complete ==="
echo "You can now use:"
echo "  - kicad-cli for command-line operations"
echo "  - Python API (import pcbnew) for PCB manipulation"
echo "  - ./test_kicad_api.py to verify the setup"
