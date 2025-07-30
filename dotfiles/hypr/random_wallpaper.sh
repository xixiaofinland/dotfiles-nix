#!/bin/bash
WALL_DIR="$HOME/Wallpapers"
MONITOR="DP-2"

# Pick a random wallpaper
WALL=$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)

# Preload and apply
hyprctl hyprpaper preload "$WALL"
hyprctl hyprpaper wallpaper "$MONITOR,$WALL"
