#!/bin/bash
WALL_DIR="$HOME/Wallpapers"
MONITOR="DP-2"

# Pick a random wallpaper
WALL=$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)

# Abort if none found
if [[ -z "$WALL" ]]; then
  echo "❌ No wallpapers found in $WALL_DIR"
  exit 1
fi

# Preload and apply
hyprctl hyprpaper preload "$WALL"
hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
