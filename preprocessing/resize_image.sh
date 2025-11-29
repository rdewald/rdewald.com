#!/bin/bash

# Script to resize and compress images to max 800px wide using ImageMagick
# Usage: ./resize_image.sh /path/to/image.jpg

if [ $# -eq 0 ]; then
    echo "Error: No image path provided"
    echo "Usage: $0 /path/to/image.jpg"
    exit 1
fi

IMAGE_PATH="$1"

if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: File not found: $IMAGE_PATH"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed"
    echo "Install with: sudo apt-get install imagemagick"
    exit 1
fi

# Resize image to max 800px width, maintaining aspect ratio
# -resize '800>' only resizes if image is wider than 800px
# -quality 85 provides good compression while maintaining quality
# The image is overwritten in place
convert "$IMAGE_PATH" -resize '800>' -quality 85 "$IMAGE_PATH"

if [ $? -eq 0 ]; then
    echo "Successfully resized and compressed: $IMAGE_PATH"
else
    echo "Error: Failed to process image"
    exit 1
fi
