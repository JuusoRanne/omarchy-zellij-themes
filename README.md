# omarchy-zellij-themes

Automatically sync [Omarchy](https://github.com/matsouto/omarchy) theme colors to [Zellij](https://zellij.dev/) in real-time.

## What This Does

This project provides automatic theme synchronization between Omarchy and Zellij. When you switch themes using Omarchy, your Zellij theme automatically updates to match.

The setup consists of two components:

1. **sync-omarchy-theme-zellij.sh**: A script that reads the current Omarchy theme's Alacritty color definitions and converts them to Zellij's KDL theme format
2. **theme-set**: An Omarchy hook that automatically triggers the sync script whenever you change themes

The script extracts colors from Omarchy's `alacritty.toml` file (background, foreground, and ANSI colors) and generates a matching Zellij theme file with proper RGB values.

## Installation

### 1. Copy the sync script to your Zellij config directory

```bash
cp sync-omarchy-theme-zellij.sh ~/.config/zellij/
chmod +x ~/.config/zellij/sync-omarchy-theme-zellij.sh
```

### 2. Copy the hook to your Omarchy hooks directory

```bash
mkdir -p ~/.config/omarchy/hooks
cp theme-set ~/.config/omarchy/hooks/
chmod +x ~/.config/omarchy/hooks/theme-set
```

### 3. Verify the setup

When you change themes using Omarchy, the hook will automatically:
- Script will check if there is already generated theme and use that
- Generate a new Zellij theme file in `~/.config/zellij/themes/`
- Update your Zellij config to use the new theme

## Manual Usage

You can also run the sync script manually at any time:

```bash
~/.config/zellij/sync-omarchy-theme-zellij.sh
```


1. Omarchy stores the current theme's Alacritty colors in `~/.config/omarchy/current/theme/alacritty.toml`
2. When you switch themes, Omarchy calls the `theme-set` hook
3. The hook executes the sync script, which:
   - Reads color values from the Alacritty TOML file
   - Converts hex colors to RGB format
   - Generates a Zellij theme in KDL format
   - Updates your Zellij config to use the new theme

## Notes

- The script expects your Zellij config at `~/.config/zellij/config.kdl` (modify line 31 and 107 in the script if your config is elsewhere)
- If a theme file already exists, the script will reuse it instead of regenerating
- The script uses the cursor color for Zellij's orange color, falling back to cyan if no cursor color is defined
