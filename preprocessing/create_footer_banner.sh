#!/bin/bash

# Script to create a footer banner from a .qmd file
# Banner includes: thumbnail from first image (left) + title and description (right)
# Usage: ./create_footer_banner.sh /path/to/file.qmd

if [ $# -eq 0 ]; then
    echo "Error: No .qmd file provided"
    echo "Usage: $0 /path/to/file.qmd"
    exit 1
fi

QMD_FILE="$1"

if [ ! -f "$QMD_FILE" ]; then
    echo "Error: File not found: $QMD_FILE"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed"
    echo "Install with: sudo apt-get install imagemagick"
    exit 1
fi

# Extract title from YAML
TITLE=$(grep '^title:' "$QMD_FILE" | sed 's/^title: *"\(.*\)"/\1/' | sed "s/^title: *'\(.*\)'/\1/" | sed 's/^title: *//')

# Extract description from YAML
DESCRIPTION=$(grep '^description:' "$QMD_FILE" | sed 's/^description: *"\(.*\)"/\1/' | sed "s/^description: *'\(.*\)'/\1/" | sed 's/^description: *//')

# Extract date from YAML
DATE=$(grep '^date:' "$QMD_FILE" | sed 's/^date: *"\(.*\)"/\1/' | sed "s/^date: *'\(.*\)'/\1/" | sed 's/^date: *//')

# Find first image in the .qmd file (looking for img src or markdown image)
# Handle <img> tags with attributes in any order
IMAGE_PATH=$(grep -oP '<img[^>]*src="[^"]*"' "$QMD_FILE" | head -1 | grep -oP '(?<=src=")[^"]*')
if [ -z "$IMAGE_PATH" ]; then
    IMAGE_PATH=$(grep -oP "!\\[.*?\\]\\(\\K[^)]*" "$QMD_FILE" | head -1)
fi

if [ -z "$TITLE" ]; then
    echo "Error: Could not find title in YAML front matter"
    exit 1
fi

if [ -z "$IMAGE_PATH" ]; then
    echo "Error: Could not find any images in .qmd file"
    exit 1
fi

# Handle URL vs local path
if [[ "$IMAGE_PATH" =~ ^https?:// ]]; then
    # Download image temporarily
    TEMP_IMG=$(mktemp --suffix=.jpg)
    wget -q -O "$TEMP_IMG" "$IMAGE_PATH"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download image from $IMAGE_PATH"
        rm -f "$TEMP_IMG"
        exit 1
    fi
    THUMBNAIL_SOURCE="$TEMP_IMG"
else
    # Convert relative path to absolute based on qmd file location
    QMD_DIR=$(dirname "$QMD_FILE")
    if [[ "$IMAGE_PATH" = /* ]]; then
        THUMBNAIL_SOURCE="$IMAGE_PATH"
    else
        THUMBNAIL_SOURCE="$QMD_DIR/$IMAGE_PATH"
    fi

    if [ ! -f "$THUMBNAIL_SOURCE" ]; then
        echo "Error: Image file not found: $THUMBNAIL_SOURCE"
        exit 1
    fi
fi

# Banner dimensions (wide and short for stacking in roll-up posts)
BANNER_WIDTH=800
BANNER_HEIGHT=120

# Create thumbnail that matches banner height
THUMBNAIL_HEIGHT=$BANNER_HEIGHT
convert "$THUMBNAIL_SOURCE" -resize "x${THUMBNAIL_HEIGHT}" -gravity Center -crop "${THUMBNAIL_HEIGHT}x${THUMBNAIL_HEIGHT}+0+0" +repage /tmp/thumbnail.png

# Create text area (account for right padding and left margin from thumbnail)
LEFT_MARGIN=180
RIGHT_PADDING=20
TEXT_WIDTH=$((BANNER_WIDTH - THUMBNAIL_HEIGHT - LEFT_MARGIN - RIGHT_PADDING))
TEXT_HEIGHT=$BANNER_HEIGHT

# Create title text (larger font)
convert -size ${TEXT_WIDTH}x60 -background white -fill black \
    -font DejaVu-Sans-Bold -pointsize 24 -gravity West \
    caption:"$TITLE" /tmp/title.png

# Create description text (smaller font) if it exists
if [ -n "$DESCRIPTION" ]; then
    convert -size ${TEXT_WIDTH}x50 -background white -fill "#333333" \
        -font DejaVu-Sans -pointsize 16 -gravity NorthWest \
        caption:"$DESCRIPTION" /tmp/description.png
else
    # Create empty description
    convert -size ${TEXT_WIDTH}x1 xc:white /tmp/description.png
fi

# Create "now on RDeWald.com/blog - published DATE" line (italics) - increased height to prevent truncation
FOOTER_TEXT="now on RDeWald.com/blog"
if [ -n "$DATE" ]; then
    FOOTER_TEXT="${FOOTER_TEXT} - published ${DATE}"
fi

convert -size ${TEXT_WIDTH}x40 -background white -fill "#666666" \
    -font DejaVu-Sans-Oblique -pointsize 14 -gravity NorthWest \
    label:"$FOOTER_TEXT" /tmp/footer_text.png

# Stack title, description, and footer text vertically
convert /tmp/title.png /tmp/description.png /tmp/footer_text.png -background white \
    -gravity West -append /tmp/text_area.png

# Ensure text area is exactly the right height
convert /tmp/text_area.png -background white -gravity Center \
    -extent ${TEXT_WIDTH}x${TEXT_HEIGHT} /tmp/text_area_sized.png

# Create a spacer between thumbnail and text
SPACER_WIDTH=20
convert -size ${SPACER_WIDTH}x${BANNER_HEIGHT} xc:white /tmp/spacer.png

# Combine thumbnail, spacer, and text horizontally
convert /tmp/thumbnail.png /tmp/spacer.png /tmp/text_area_sized.png -background white \
    +append -gravity West -extent ${BANNER_WIDTH}x${BANNER_HEIGHT} /tmp/banner.png

# Add a subtle border
convert /tmp/banner.png -bordercolor "#dddddd" -border 1 /tmp/banner_final.png

# Generate output filename in img subfolder
QMD_DIR=$(dirname "$QMD_FILE")
QMD_BASENAME=$(basename "$QMD_FILE" .qmd)
OUTPUT_DIR="${QMD_DIR}/img"

# Create img directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="${OUTPUT_DIR}/${QMD_BASENAME}_footer.png"

mv /tmp/banner_final.png "$OUTPUT_FILE"

# Cleanup
rm -f /tmp/thumbnail.png /tmp/spacer.png /tmp/title.png /tmp/description.png /tmp/footer_text.png /tmp/text_area.png /tmp/text_area_sized.png /tmp/banner.png
if [[ "$IMAGE_PATH" =~ ^https?:// ]]; then
    rm -f "$TEMP_IMG"
fi

echo "Footer banner created: $OUTPUT_FILE"
