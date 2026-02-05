# Launch Image Generation Guide

This document describes the required launch image sizes for the iOS app launch screen.

## Source Icon
The source icon is located at: `doc/images/icon.png`

## Required Image Sizes

The following PNG files need to be generated from the source icon and placed in this directory:

| Filename | Pixel Size | Scale | Usage |
|----------|------------|-------|-------|
| `launch-icon.png` | 100x100 | @1x | Launch Screen Logo |
| `launch-icon@2x.png` | 200x200 | @2x | Launch Screen Logo |
| `launch-icon@3x.png` | 300x300 | @3x | Launch Screen Logo |

## Generation Instructions

### Using ImageMagick (macOS/Linux)
```bash
# Navigate to the source icon directory
cd doc/images

# Generate all required sizes
convert icon.png -resize 100x100 ../../ios/LxMusicMobile/Images.xcassets/LaunchImage.imageset/launch-icon.png
convert icon.png -resize 200x200 ../../ios/LxMusicMobile/Images.xcassets/LaunchImage.imageset/launch-icon@2x.png
convert icon.png -resize 300x300 ../../ios/LxMusicMobile/Images.xcassets/LaunchImage.imageset/launch-icon@3x.png
```

### Using sips (macOS built-in)
```bash
# Navigate to the LaunchImage.imageset directory
cd ios/LxMusicMobile/Images.xcassets/LaunchImage.imageset

# Copy source and resize for each size
cp ../../../../doc/images/icon.png launch-icon.png && sips -z 100 100 launch-icon.png
cp ../../../../doc/images/icon.png launch-icon@2x.png && sips -z 200 200 launch-icon@2x.png
cp ../../../../doc/images/icon.png launch-icon@3x.png && sips -z 300 300 launch-icon@3x.png
```

## Notes
- All images should be PNG format
- The launch image will be displayed centered on the launch screen
- The image will be displayed at 100pt (100x100 points) on all devices
