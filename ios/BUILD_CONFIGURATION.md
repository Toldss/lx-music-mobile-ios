# iOS Build Configuration Guide

## Overview

This document describes the Xcode project configuration for LxMusicMobile iOS.

## Current Configuration

### Bundle Identifier
- **Bundle ID**: `com.lxmusic.mobile`
- Configured for both Debug and Release builds

### Deployment Target
- **Minimum iOS Version**: 13.4
- Set in project-level and target-level build settings

### Capabilities

#### Background Modes
The app is configured with the following background modes in `Info.plist`:

| Mode | Purpose |
|------|---------|
| `audio` | Enables background audio playback for music streaming |

This capability allows the app to continue playing music when the app is in the background or the device is locked.

**Info.plist Configuration:**
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### Code Signing

#### Development Team Setup (Required)

The `DEVELOPMENT_TEAM` setting is currently empty and **must be configured** before building:

1. **Open Xcode**: Open `ios/LxMusicMobile.xcworkspace`
2. **Select Project**: Click on "LxMusicMobile" in the project navigator
3. **Select Target**: Select the "LxMusicMobile" target
4. **Signing & Capabilities**: Go to the "Signing & Capabilities" tab
5. **Team Selection**: Select your Apple Developer Team from the "Team" dropdown

Alternatively, you can set the `DEVELOPMENT_TEAM` value directly in `project.pbxproj`:
- Find `DEVELOPMENT_TEAM = "";` 
- Replace with your Team ID, e.g., `DEVELOPMENT_TEAM = "ABCD1234EF";`

#### Code Sign Identity
- **Debug**: iPhone Developer (Development signing)
- **Release**: iPhone Developer (will use distribution certificate when archiving)

#### Signing Types

| Signing Type | Use Case | Certificate Required |
|--------------|----------|---------------------|
| **Development** | Testing on personal devices | iOS Development Certificate |
| **Ad Hoc** | Distribution to limited devices | iOS Distribution Certificate + Provisioning Profile |
| **App Store** | App Store submission | iOS Distribution Certificate + App Store Provisioning Profile |

### Build Configurations

| Configuration | Purpose | Optimizations |
|--------------|---------|---------------|
| Debug | Development and testing | Disabled (fast builds) |
| Release | App Store / Ad Hoc distribution | Enabled |

### Signing & Capabilities Setup in Xcode

To configure signing in Xcode:

1. **Open Project**: Open `ios/LxMusicMobile.xcworkspace` in Xcode
2. **Select Target**: Select "LxMusicMobile" target
3. **Signing & Capabilities Tab**:
   - Enable "Automatically manage signing" for development
   - Or manually select provisioning profiles for Ad Hoc/App Store distribution
4. **Add Capabilities** (if not already present):
   - Click "+ Capability"
   - Add "Background Modes"
   - Check "Audio, AirPlay, and Picture in Picture"

## CocoaPods Dependency Management

### Overview

This project uses CocoaPods for iOS dependency management. The `Podfile` is configured for React Native 0.73.11 and includes all necessary dependencies for the native modules.

### Prerequisites for Pod Install

Before running `pod install`, ensure you have:

1. **macOS** - CocoaPods only runs on macOS
2. **Ruby** - macOS comes with Ruby pre-installed
3. **CocoaPods gem** - Install with: `sudo gem install cocoapods`
4. **Node.js** - Required for React Native pod resolution
5. **Xcode Command Line Tools** - Install with: `xcode-select --install`

### Running Pod Install

Navigate to the `ios` directory and run:

```bash
cd ios
pod install
```

**Expected Output:**
```
Analyzing dependencies
Downloading dependencies
Installing React-Core (0.73.11)
Installing React-RCTText (0.73.11)
... (additional pods)
Generating Pods project
Integrating client project
Pod installation complete!
```

### Podfile Configuration

The current Podfile is configured with:

| Setting | Value | Description |
|---------|-------|-------------|
| Platform | `min_ios_version_supported` | Uses React Native's minimum iOS version |
| Flipper | Conditional | Enabled unless `NO_FLIPPER=1` is set |
| Frameworks | Optional | Supports static/dynamic linking via `USE_FRAMEWORKS` |

**Key Features:**
- Uses `react_native_pods.rb` for React Native integration
- Includes `LxMusicMobileTests` target for testing
- Runs `react_native_post_install` for proper configuration

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `NO_FLIPPER=1` | Disable Flipper debugging | `NO_FLIPPER=1 pod install` |
| `USE_FRAMEWORKS=static` | Use static frameworks | `USE_FRAMEWORKS=static pod install` |
| `USE_FRAMEWORKS=dynamic` | Use dynamic frameworks | `USE_FRAMEWORKS=dynamic pod install` |

### Troubleshooting Pod Install

#### Common Issues

1. **"Unable to find a specification for..."**
   ```bash
   pod repo update
   pod install
   ```

2. **Ruby version issues**
   ```bash
   # Use rbenv or rvm to manage Ruby versions
   rbenv install 3.0.0
   rbenv local 3.0.0
   gem install cocoapods
   ```

3. **Permission denied errors**
   ```bash
   sudo gem install cocoapods
   # Or use bundler
   bundle install
   bundle exec pod install
   ```

4. **Node modules not found**
   ```bash
   # Ensure node_modules are installed first
   cd ..
   npm install
   cd ios
   pod install
   ```

5. **Cache issues**
   ```bash
   pod cache clean --all
   rm -rf Pods
   rm Podfile.lock
   pod install
   ```

### Verifying Installation

After successful pod install:

1. **Check Pods directory exists**: `ls -la Pods/`
2. **Verify Podfile.lock created**: `cat Podfile.lock | head -20`
3. **Open workspace**: `open LxMusicMobile.xcworkspace`

### Important Notes

- **Always use `.xcworkspace`**: After pod install, always open `LxMusicMobile.xcworkspace`, not `LxMusicMobile.xcodeproj`
- **Re-run after changes**: Run `pod install` whenever:
  - Adding new React Native packages with native dependencies
  - Updating React Native version
  - Modifying the Podfile
- **Windows/Linux users**: Pod install must be performed on a macOS machine before building

---

## Building the App

### Prerequisites
1. Valid Apple Developer account (free or paid)
2. Xcode 12.0 or later installed
3. CocoaPods dependencies installed (`pod install` - **must be run on macOS**)
4. Development Team configured in Xcode

### Debug Build Verification Checklist

Before running the Debug build, verify the following components are in place:

#### Native Modules (All 5 Required)
| Module | Header File | Implementation File | Status |
|--------|-------------|---------------------|--------|
| CacheModule | `Modules/Cache/CacheModule.h` | `Modules/Cache/CacheModule.m` | ✅ |
| CryptoModule | `Modules/Crypto/CryptoModule.h` | `Modules/Crypto/CryptoModule.m` | ✅ |
| RSAUtils | `Modules/Crypto/RSAUtils.h` | `Modules/Crypto/RSAUtils.m` | ✅ |
| AESUtils | `Modules/Crypto/AESUtils.h` | `Modules/Crypto/AESUtils.m` | ✅ |
| LyricModule | `Modules/Lyric/LyricModule.h` | `Modules/Lyric/LyricModule.m` | ✅ |
| UserApiModule | `Modules/UserApi/UserApiModule.h` | `Modules/UserApi/UserApiModule.m` | ✅ |
| UtilsModule | `Modules/Utils/UtilsModule.h` | `Modules/Utils/UtilsModule.m` | ✅ |

#### AppDelegate Configuration
- [x] All native modules imported in `AppDelegate.mm`
- [x] React Native bridge properly initialized
- [x] ReactNativeNavigation bootstrapped

#### Xcode Project Configuration
- [x] All source files added to `project.pbxproj`
- [x] All modules included in Sources build phase
- [x] Module groups properly organized in project structure

#### Info.plist Configuration
- [x] `UIBackgroundModes` includes `audio`
- [x] `NSAppTransportSecurity` configured
- [x] `NSLocalNetworkUsageDescription` set
- [x] `UIRequiredDeviceCapabilities` configured
- [x] Bundle Identifier set to `com.lxmusic.mobile`

#### Build Settings
- [x] Minimum deployment target: iOS 13.4
- [x] Debug configuration available
- [x] Code signing identity: iPhone Developer

### Debug Build (Development Signing)
```bash
cd ios
xcodebuild -workspace LxMusicMobile.xcworkspace -scheme LxMusicMobile -configuration Debug build
```

### Release Archive
```bash
cd ios
xcodebuild -workspace LxMusicMobile.xcworkspace -scheme LxMusicMobile -configuration Release archive -archivePath build/LxMusicMobile.xcarchive
```

### Export IPA

#### Development Export
Create `ExportOptions-Development.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

Export command:
```bash
xcodebuild -exportArchive -archivePath build/LxMusicMobile.xcarchive -exportPath build -exportOptionsPlist ExportOptions-Development.plist
```

#### Ad Hoc Export
Create `ExportOptions-AdHoc.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

Export command:
```bash
xcodebuild -exportArchive -archivePath build/LxMusicMobile.xcarchive -exportPath build -exportOptionsPlist ExportOptions-AdHoc.plist
```

## Requirements

- Xcode 12.0 or later
- Valid Apple Developer account
- iOS 13.4+ device or simulator for testing

## Notes

- The project uses CocoaPods for dependency management
- **Pod install must be run on macOS** - CocoaPods does not support Windows or Linux
- Run `pod install` before building if dependencies change
- Always open `.xcworkspace` file, not `.xcodeproj`
- Background audio mode is already configured in Info.plist
- Code signing identity is set to "iPhone Developer" for both Debug and Release configurations

## Quick Start for macOS Developers

```bash
# 1. Install dependencies (from project root)
npm install

# 2. Navigate to iOS directory
cd ios

# 3. Install CocoaPods dependencies
pod install

# 4. Open in Xcode
open LxMusicMobile.xcworkspace

# 5. Configure signing (in Xcode)
# - Select your Development Team
# - Enable automatic signing

# 6. Build and run
# - Select target device/simulator
# - Press Cmd+R to build and run
```

---

## Debug Build Process Details

### Command
```bash
cd ios
xcodebuild -workspace LxMusicMobile.xcworkspace -scheme LxMusicMobile -configuration Debug build
```

### Alternative: Build for Simulator
```bash
cd ios
xcodebuild -workspace LxMusicMobile.xcworkspace -scheme LxMusicMobile -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Expected Build Output

A successful Debug build should show:
```
** BUILD SUCCEEDED **
```

The build process will:
1. Check Pods manifest lock
2. Compile all Objective-C source files including:
   - `AppDelegate.mm`
   - `main.m`
   - `CacheModule.m`
   - `CryptoModule.m`, `RSAUtils.m`, `AESUtils.m`
   - `LyricModule.m`
   - `UserApiModule.m`
   - `UtilsModule.m`
3. Link frameworks (Foundation, Security, JavaScriptCore, UIKit, MediaPlayer, etc.)
4. Bundle React Native code and images
5. Copy resources (Images.xcassets, LaunchScreen.storyboard, user-api-preload.js)
6. Sign the application

### Common Build Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `No signing certificate` | Development Team not configured | Set DEVELOPMENT_TEAM in project settings |
| `Module not found` | Missing CocoaPods | Run `pod install` |
| `Undefined symbols` | Source file not in build phase | Verify file is in project.pbxproj Sources |
| `Header not found` | Import path incorrect | Check import statements in AppDelegate.mm |

### Verification After Build

After a successful build, verify:
1. **App bundle created**: Check `DerivedData/Build/Products/Debug-iphonesimulator/LxMusicMobile.app`
2. **All modules linked**: The app should launch without "module not found" errors
3. **Resources bundled**: `user-api-preload.js` should be in the app bundle

### Build Status

| Component | Status | Notes |
|-----------|--------|-------|
| Native Modules | ✅ Ready | All 5 modules implemented and configured |
| AppDelegate | ✅ Ready | All modules imported |
| project.pbxproj | ✅ Ready | All source files included |
| Info.plist | ✅ Ready | All permissions configured |
| Build Settings | ✅ Ready | Debug configuration available |
| CocoaPods | ⚠️ Pending | Must run `pod install` on macOS |
| Code Signing | ⚠️ Pending | Must configure Development Team |

**Note**: Actual build execution requires macOS with Xcode installed. This verification confirms all code and configuration is in place for a successful build.

---

## Release Archive Verification

This section documents the verification of Release Archive configuration for IPA export.

### Release Build Configuration Verification

The following Release build settings have been verified in `project.pbxproj`:

#### Project-Level Release Settings (83CBBA211A601CBA00E9B192)

| Setting | Value | Purpose |
|---------|-------|---------|
| `CODE_SIGN_IDENTITY[sdk=iphoneos*]` | `iPhone Developer` | Code signing for device builds |
| `COPY_PHASE_STRIP` | `YES` | Strips debug symbols for smaller binary |
| `ENABLE_NS_ASSERTIONS` | `NO` | Disables assertions for production |
| `MTL_ENABLE_DEBUG_INFO` | `NO` | No Metal debug info in Release |
| `VALIDATE_PRODUCT` | `YES` | Validates product before archiving |
| `IPHONEOS_DEPLOYMENT_TARGET` | `13.4` | Minimum iOS version |

#### Target-Level Release Settings (13B07F951A680F5B00A75B9A)

| Setting | Value | Purpose |
|---------|-------|---------|
| `ASSETCATALOG_COMPILER_APPICON_NAME` | `AppIcon` | App icon asset catalog |
| `PRODUCT_BUNDLE_IDENTIFIER` | `com.lxmusic.mobile` | Bundle identifier for signing |
| `PRODUCT_NAME` | `LxMusicMobile` | Product name |
| `DEVELOPMENT_TEAM` | `""` (empty) | **Must be configured** |
| `SWIFT_VERSION` | `5.0` | Swift language version |
| `CURRENT_PROJECT_VERSION` | `1` | Build number |
| `MARKETING_VERSION` | `1.0` | Version string |

### Release Optimizations

The Release configuration inherits default Xcode optimizations:

| Optimization | Status | Description |
|--------------|--------|-------------|
| Compiler Optimization | ✅ Enabled | Default `-Os` (optimize for size) |
| Dead Code Stripping | ✅ Enabled | Removes unused code |
| Symbol Stripping | ✅ Enabled | `COPY_PHASE_STRIP = YES` |
| Assertions Disabled | ✅ Enabled | `ENABLE_NS_ASSERTIONS = NO` |
| Debug Info Disabled | ✅ Enabled | `MTL_ENABLE_DEBUG_INFO = NO` |

### Export Options Files Verification

#### ExportOptions-Development.plist ✅

| Key | Value | Description |
|-----|-------|-------------|
| `method` | `development` | Development signing method |
| `teamID` | `YOUR_TEAM_ID` | **Must be replaced** with actual Team ID |
| `compileBitcode` | `false` | Bitcode disabled (deprecated) |
| `destination` | `export` | Export destination |
| `signingStyle` | `automatic` | Automatic signing |
| `stripSwiftSymbols` | `true` | Strips Swift symbols |
| `thinning` | `<none>` | No app thinning |

#### ExportOptions-AdHoc.plist ✅

| Key | Value | Description |
|-----|-------|-------------|
| `method` | `ad-hoc` | Ad Hoc distribution method |
| `teamID` | `YOUR_TEAM_ID` | **Must be replaced** with actual Team ID |
| `compileBitcode` | `false` | Bitcode disabled (deprecated) |
| `destination` | `export` | Export destination |
| `signingStyle` | `automatic` | Automatic signing |
| `stripSwiftSymbols` | `true` | Strips Swift symbols |
| `thinning` | `<none>` | No app thinning |

### Archive and IPA Export Commands

#### Step 1: Create Archive

```bash
cd ios
xcodebuild -workspace LxMusicMobile.xcworkspace \
  -scheme LxMusicMobile \
  -configuration Release \
  -archivePath build/LxMusicMobile.xcarchive \
  archive
```

**Expected Output:**
```
** ARCHIVE SUCCEEDED **
```

#### Step 2: Export IPA (Development)

```bash
xcodebuild -exportArchive \
  -archivePath build/LxMusicMobile.xcarchive \
  -exportPath build/Development \
  -exportOptionsPlist ExportOptions-Development.plist
```

#### Step 3: Export IPA (Ad Hoc)

```bash
xcodebuild -exportArchive \
  -archivePath build/LxMusicMobile.xcarchive \
  -exportPath build/AdHoc \
  -exportOptionsPlist ExportOptions-AdHoc.plist
```

**Expected Output:**
```
** EXPORT SUCCEEDED **
```

The exported IPA will be located at:
- Development: `build/Development/LxMusicMobile.ipa`
- Ad Hoc: `build/AdHoc/LxMusicMobile.ipa`

### Pre-Archive Checklist

Before running Archive, verify:

- [ ] **Development Team configured**: Set `DEVELOPMENT_TEAM` in project.pbxproj or Xcode
- [ ] **Team ID in ExportOptions**: Replace `YOUR_TEAM_ID` in both plist files
- [ ] **CocoaPods installed**: Run `pod install` on macOS
- [ ] **Valid certificates**: Ensure iOS Development/Distribution certificates are installed
- [ ] **Provisioning profiles**: Ensure valid provisioning profiles are available

### Archive Verification Status

| Component | Status | Notes |
|-----------|--------|-------|
| Release Configuration | ✅ Verified | Optimizations enabled |
| Code Signing Identity | ✅ Configured | `iPhone Developer` |
| Bundle Identifier | ✅ Set | `com.lxmusic.mobile` |
| Deployment Target | ✅ Set | iOS 13.4 |
| ExportOptions-Development.plist | ✅ Created | Team ID placeholder |
| ExportOptions-AdHoc.plist | ✅ Created | Team ID placeholder |
| Development Team | ⚠️ Pending | Must be configured |
| CocoaPods | ⚠️ Pending | Must run on macOS |

### Requirements Verification

This configuration satisfies the following requirements:

| Requirement | Description | Status |
|-------------|-------------|--------|
| 8.3 | Archive generates exportable archive | ✅ Configuration ready |
| 8.4 | Support Ad Hoc and Development export | ✅ Both plist files created |

### Troubleshooting Archive Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `No signing certificate` | Missing certificate | Install iOS Development certificate in Keychain |
| `No provisioning profile` | Missing profile | Download from Apple Developer Portal |
| `Team ID invalid` | Wrong Team ID | Get correct Team ID from developer.apple.com |
| `Archive failed` | Build errors | Fix compilation errors first |
| `Export failed` | Signing mismatch | Ensure certificate matches provisioning profile |

### Notes

- **Windows/Linux users**: Archive and IPA export must be performed on macOS with Xcode
- **Actual archive execution**: This document verifies configuration; actual archive requires macOS
- **Team ID**: Find your Team ID at https://developer.apple.com/account under Membership
- **Certificates**: Manage certificates in Xcode > Preferences > Accounts
