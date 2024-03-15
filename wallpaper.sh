#!/bin/bash

# Set the original path of the wallpapers
wallpapers_original_path="/home/zer0/Pictures/wallpaper"
# Set the base path for temporary wallpapers
base_path='/tmp/wallpapers'

# Create the directory if it doesn't exist
mkdir -p "$base_path"

# Create a list of images from the specified directory and its subdirectories
list_of_images='/tmp/list_of_images.txt'
find "$wallpapers_original_path" \( -name '*.jpg' -o -name '*.png' \) -exec realpath {} + > "$list_of_images"

# Randomly select one image from the list
selected_picture=$(shuf -n 1 "$list_of_images")

# Set the wallpaper using feh
feh --bg-scale "$selected_picture"

