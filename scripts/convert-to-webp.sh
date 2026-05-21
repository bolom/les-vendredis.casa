#!/bin/bash
# Converts all .jpg / .jpeg / .png in public/images/ to .webp
# Skips files that already have a .webp counterpart
# Requires: cwebp (brew install webp)

set -e

IMAGES_DIR="$(dirname "$0")/../public/images"
QUALITY=82
converted=0
skipped=0

for src in "$IMAGES_DIR"/*.{jpg,jpeg,png}; do
  [ -f "$src" ] || continue
  base="${src%.*}"
  dest="$base.webp"
  if [ -f "$dest" ]; then
    skipped=$((skipped + 1))
    continue
  fi
  echo "Converting: $(basename "$src") → $(basename "$dest")"
  cwebp -q $QUALITY "$src" -o "$dest" -quiet
  converted=$((converted + 1))
done

echo ""
echo "Done: $converted converted, $skipped already had .webp"
