#!/bin/bash
WALL_DIR="$HOME/Wallpapers"
MONITOR="DP-2"

# Wait for hyprpaper IPC to be ready (max ~5 seconds)
for i in {1..10}; do
  if hyprctl hyprpaper preload /dev/null 2>/dev/null; then
    break
  fi
  sleep 0.5
done

# Pick a random wallpaper (follow symlinks)
WALL=$(find -L "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)

# Abort if none found
if [[ -z "$WALL" ]]; then
  echo "❌ No wallpapers found in $WALL_DIR"
  exit 1
fi

# Preload and apply
hyprctl hyprpaper preload "$WALL"
hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
