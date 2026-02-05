# App Icon Generation Guide

This document describes the required icon sizes for the iOS app.

## Source Icon
The source icon is located at: `doc/images/icon.png`

## Required Icon Sizes

The following PNG files need to be generated from the source icon and placed in this directory:

| Filename | Pixel Size | Point Size | Scale | Usage |
|----------|------------|------------|-------|-------|
| `icon-20@2x.png` | 40x40 | 20pt | @2x | iPhone Notification |
| `icon-20@3x.png` | 60x60 | 20pt | @3x | iPhone Notification |
| `icon-29@2x.png` | 58x58 | 29pt | @2x | iPhone Settings |
| `icon-29@3x.png` | 87x87 | 29pt | @3x | iPhone Settings |
| `icon-40@2x.png` | 80x80 | 40pt | @2x | iPhone Spotlight |
| `icon-40@3x.png` | 120x120 | 40pt | @3x | iPhone Spotlight |
| `icon-60@2x.png` | 120x120 | 60pt | @2x | iPhone App |
| `icon-60@3x.png` | 180x180 | 60pt | @3x | iPhone App |
| `icon-1024.png` | 1024x1024 | 1024pt | @1x | App Store Marketing |

## Generation Instructions

### Using ImageMagick (macOS/Linux)
```bash
# Navigate to the source icon directory
cd doc/images

# Generate all required sizes
convert icon.png -resize 40x40 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-20@2x.png
convert icon.png -resize 60x60 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-20@3x.png
convert icon.png -resize 58x58 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-29@2x.png
convert icon.png -resize 87x87 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-29@3x.png
convert icon.png -resize 80x80 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-40@2x.png
convert icon.png -resize 120x120 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-40@3x.png
convert icon.png -resize 120x120 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-60@2x.png
convert icon.png -resize 180x180 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-60@3x.png
convert icon.png -resize 1024x1024 ../../ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset/icon-1024.png
```

### Using sips (macOS built-in)
```bash
# Navigate to the AppIcon.appiconset directory
cd ios/LxMusicMobile/Images.xcassets/AppIcon.appiconset

# Copy source and resize for each size
cp ../../../../doc/images/icon.png icon-20@2x.png && sips -z 40 40 icon-20@2x.png
cp ../../../../doc/images/icon.png icon-20@3x.png && sips -z 60 60 icon-20@3x.png
cp ../../../../doc/images/icon.png icon-29@2x.png && sips -z 58 58 icon-29@2x.png
cp ../../../../doc/images/icon.png icon-29@3x.png && sips -z 87 87 icon-29@3x.png
cp ../../../../doc/images/icon.png icon-40@2x.png && sips -z 80 80 icon-40@2x.png
cp ../../../../doc/images/icon.png icon-40@3x.png && sips -z 120 120 icon-40@3x.png
cp ../../../../doc/images/icon.png icon-60@2x.png && sips -z 120 120 icon-60@2x.png
cp ../../../../doc/images/icon.png icon-60@3x.png && sips -z 180 180 icon-60@3x.png
cp ../../../../doc/images/icon.png icon-1024.png && sips -z 1024 1024 icon-1024.png
```

### Using Online Tools
You can also use online app icon generators:
- [App Icon Generator](https://appicon.co/)
- [MakeAppIcon](https://makeappicon.com/)

Upload the source icon (`doc/images/icon.png`) and download the generated icon set.

## Notes
- All icons should be PNG format
- Icons should not have transparency (for App Store)
- The 1024x1024 marketing icon must not have alpha channel
- Ensure icons have proper corner radius (iOS applies this automatically)
