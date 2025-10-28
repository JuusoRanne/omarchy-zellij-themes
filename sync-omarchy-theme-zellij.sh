#!/usr/bin/env bash

# Sync Omarchy theme colors to Zellij
# This script reads the current Omarchy theme and generates a Zellij theme

set -e

OMARCHY_THEME_DIR="$HOME/.config/omarchy/current/theme"
ZELLIJ_THEMES_DIR="$HOME/.config/zellij/themes"
ALACRITTY_TOML="$OMARCHY_THEME_DIR/alacritty.toml"

# Get the current theme name
THEME_NAME=$(basename "$(readlink "$HOME/.config/omarchy/current/theme")")
OUTPUT_FILE="$ZELLIJ_THEMES_DIR/$THEME_NAME.kdl"

# Check if alacritty.toml exists
if [ ! -f "$ALACRITTY_TOML" ]; then
    echo "Error: Omarchy theme file not found at $ALACRITTY_TOML"
    exit 1
fi

# Create themes directory if it doesn't exist
mkdir -p "$ZELLIJ_THEMES_DIR"

# Check if theme already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo "✓ Theme '$THEME_NAME' already exists at: $OUTPUT_FILE"
    echo "  Using existing theme file..."

    # Update config.kdl to use the existing theme
    ZELLIJ_CONFIG="$HOME/.config/zellij/config.kdl"
    if [ -f "$ZELLIJ_CONFIG" ]; then
        sed -i "s/^theme \".*\"/theme \"$THEME_NAME\"/" "$ZELLIJ_CONFIG"
        echo "✓ Updated config.kdl to use theme: $THEME_NAME"
    fi

    exit 0
fi

# Function to convert hex to RGB
hex_to_rgb() {
    local hex="$1"
    # Remove #, 0x prefix and quotes if present
    hex="${hex#\#}"
    hex="${hex#0x}"
    hex="${hex//\'/}"
    hex="${hex//\"/}"

    # Convert to RGB
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    echo "$r $g $b"
}

# Extract colors from alacritty.toml
extract_color() {
    local color_name="$1"
    grep "^$color_name" "$ALACRITTY_TOML" | sed 's/.*= *//; s/"//g; s/'"'"'//g; s/#//'
}

# Read colors from alacritty.toml
BG=$(extract_color "background")
FG=$(extract_color "foreground")

# Normal colors
BLACK=$(extract_color "black" | head -1)
RED=$(extract_color "red" | head -1)
GREEN=$(extract_color "green" | head -1)
YELLOW=$(extract_color "yellow" | head -1)
BLUE=$(extract_color "blue" | head -1)
MAGENTA=$(extract_color "magenta" | head -1)
CYAN=$(extract_color "cyan" | head -1)
WHITE=$(extract_color "white" | head -1)

# Get cursor color or use cyan as fallback
CURSOR=$(extract_color "cursor" | tail -1)
# Check if cursor is a valid hex color (6 hex digits)
if [ -z "$CURSOR" ] || ! [[ "$CURSOR" =~ ^[0-9A-Fa-f]{6}$ ]]; then
    CURSOR="$CYAN"
fi

# Generate Zellij theme file
cat > "$OUTPUT_FILE" << EOF
themes {
    $THEME_NAME {
        fg $(hex_to_rgb "$FG")
        bg $(hex_to_rgb "$BG")
        black $(hex_to_rgb "$BLACK")
        red $(hex_to_rgb "$RED")
        green $(hex_to_rgb "$GREEN")
        yellow $(hex_to_rgb "$YELLOW")
        blue $(hex_to_rgb "$BLUE")
        magenta $(hex_to_rgb "$MAGENTA")
        cyan $(hex_to_rgb "$CYAN")
        white $(hex_to_rgb "$WHITE")
        orange $(hex_to_rgb "$CURSOR")
    }
}
EOF

echo "✓ Generated Zellij theme: $OUTPUT_FILE"
echo "✓ Theme name: $THEME_NAME"

# Update config.kdl to use the new theme
ZELLIJ_CONFIG="$HOME/.config/zellij/config.kdl"
if [ -f "$ZELLIJ_CONFIG" ]; then
    sed -i "s/^theme \".*\"/theme \"$THEME_NAME\"/" "$ZELLIJ_CONFIG"
    echo "✓ Updated config.kdl to use theme: $THEME_NAME"
else
    echo "⚠ Config file not found at $ZELLIJ_CONFIG"
    echo "To use this theme, add this to your Zellij config:"
    echo "theme \"$THEME_NAME\""
fi
