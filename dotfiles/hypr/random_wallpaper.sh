#!/bin/sh
WALL_DIR="$HOME/Wallpapers"
MONITOR="DP-2"

# Wait for hyprpaper IPC to be ready (better way)
for i in {1..10}; do
  if hyprctl hyprpaper listloaded 2>/dev/null >/dev/null; then
    echo "✅ hyprpaper is ready"
    break
  fi
  echo "⏳ Waiting for hyprpaper... ($i/10)"
  sleep 0.5
done

# Pick a random wallpaper (follow symlinks with -L)
WALL=$(find -L "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)

# Abort if none found
if [[ -z "$WALL" ]]; then
  echo "❌ No wallpapers found in $WALL_DIR"
  exit 1
fi

echo "🖼️ Setting wallpaper: $(basename "$WALL")"

# Preload and apply
hyprctl hyprpaper preload "$WALL"
hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
