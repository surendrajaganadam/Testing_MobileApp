# Lebyy iOS

Same E2E practice app as Android — Shop, Alerts, Forms, Swipe, Gestures, WebView.

## Credentials (shown on login)

- Username: `demo_user`
- Password: `demo_pass`

## Bundle ID

`com.demo.lebyy`

## Generate / open project

```bash
cd "Mobile App/Lebyy-iOS"
xcodegen generate
open Lebyy.xcodeproj
```

## Build for Simulator

```bash
cd "Mobile App/Lebyy-iOS"
xcodegen generate
xcodebuild -scheme Lebyy -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath build \
  build
```

App path after build:

`build/Build/Products/Debug-iphonesimulator/Lebyy.app`

Install on booted simulator:

```bash
xcrun simctl boot "iPhone 16" || true
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Lebyy.app
xcrun simctl launch booted com.demo.lebyy
```

## Build for Real Device

1. Open `Lebyy.xcodeproj` in Xcode  
2. Select your **Team** under Signing & Capabilities (`DEVELOPMENT_TEAM`)  
3. Plug in the iPhone, trust the computer  
4. Choose your device as run destination and press Run  

Or from CLI (after setting your team id):

```bash
xcodebuild -scheme Lebyy -configuration Debug \
  -destination 'generic/platform=iOS' \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID \
  CODE_SIGN_STYLE=Automatic \
  -derivedDataPath build-device \
  build
```

IPA / installable app:

`build-device/Build/Products/Debug-iphoneos/Lebyy.app`

## Mobilewright config tip

```ts
platform: 'ios',
bundleId: 'com.demo.lebyy',
```
