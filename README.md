# Lebyy — Mobile E2E Practice App

Debuggable practice app for **Android** and **iOS** automation (MobileWright / Appium / XCUITest style).

Branding from [lebyy.com](https://lebyy.com).

| Item | Value |
|------|--------|
| App name | **Lebyy** |
| Package / Bundle ID | `com.lebyy.app` |
| Login username | `demo_user` |
| Login password | `demo_pass` |

---

## Repository layout

```text
Testing_MobileApp/
├── README.md                 ← you are here
├── releases/
│   └── Lebyy-debug.apk       ← ready-to-install Android APK
├── android/                  ← Android Studio / Gradle project
└── ios/                      ← Xcode project (SwiftUI)
    ├── Lebyy.xcodeproj
    ├── project.yml           ← XcodeGen (optional)
    └── Lebyy/                ← Swift source + assets
```

---

## 1) Android — quickest way (share APK)

No source needed for testers who only want to install:

1. Download [`releases/Lebyy-debug.apk`](releases/Lebyy-debug.apk)
2. Copy to an Android phone
3. Enable **Install unknown apps** for Files / Chrome / Drive
4. Open the APK → Install → Open **Lebyy**

**Package name:** `com.lebyy.app`

### Build Android from source (optional)

Requirements: Android Studio (or JDK 17 + Android SDK).

```bash
cd android
./gradlew assembleDebug
# Output:
# android/app/build/outputs/apk/debug/app-debug.apk
```

Install with adb:

```bash
adb install -r releases/Lebyy-debug.apk
# or
adb install -r android/app/build/outputs/apk/debug/app-debug.apk
```

---

## 2) iOS — build in Xcode (recommended for sharing)

Apple does **not** allow installing a random IPA from Drive on any iPhone.  
Others should **clone this repo and run in Xcode**.

### What you need

| Requirement | Notes |
|-------------|--------|
| **Mac** | Required |
| **Xcode 15+** | From Mac App Store |
| **Apple ID** | Free Apple ID works for Simulator + personal device |
| **(Optional) XcodeGen** | Only if you regenerate the project from `project.yml` |

### Step-by-step (Simulator — easiest)

1. Clone this repo:

   ```bash
   git clone https://github.com/surendrajaganadam/Testing_MobileApp.git
   cd Testing_MobileApp/ios
   ```

2. Open the project in Xcode:

   ```bash
   open Lebyy.xcodeproj
   ```

   Or in Finder: open `ios/Lebyy.xcodeproj`.

3. In Xcode top bar:
   - Scheme: **Lebyy**
   - Destination: any **iPhone simulator** (e.g. iPhone 16)

4. Press **▶ Run** (or `Cmd + R`)

5. App launches → login with `demo_user` / `demo_pass`

### Run on a real iPhone — what YOU must change

These are the only common changes each person must do on their machine:

#### A) Select your Team (signing)

1. Open `Lebyy.xcodeproj`
2. Select the **Lebyy** target in the left project navigator
3. Open **Signing & Capabilities**
4. Enable **Automatically manage signing**
5. **Team** → choose **your** Apple ID / Personal Team  
   - If empty: **Xcode → Settings → Accounts → + → Apple ID**
6. If Xcode shows a Bundle ID conflict, change Bundle Identifier temporarily, e.g.:

   `com.lebyy.app.yourname`

   (default in this repo is `com.lebyy.app`)

#### B) Trust the developer on the phone (first time only)

1. Plug in iPhone, unlock it, tap **Trust**
2. On iPhone: **Settings → General → VPN & Device Management**
3. Trust your developer certificate
4. In Xcode choose your **physical device** as destination → Run

#### C) Optional: change Bundle ID in `project.yml`

If you use XcodeGen and need a unique Bundle ID:

```yaml
# ios/project.yml
PRODUCT_BUNDLE_IDENTIFIER: com.lebyy.app.yourname
```

Then regenerate:

```bash
brew install xcodegen   # once
cd ios
xcodegen generate
open Lebyy.xcodeproj
```

Most people can **skip XcodeGen** and just open the existing `Lebyy.xcodeproj`.

### What you usually do NOT need to change

- Swift source under `ios/Lebyy/`
- Login credentials (`demo_user` / `demo_pass`)
- UI / feature code
- App display name (**Lebyy**)

### CLI build (optional)

Simulator:

```bash
cd ios
xcodebuild -scheme Lebyy -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath build \
  build
```

Real device (replace `YOUR_TEAM_ID`):

```bash
cd ios
xcodebuild -scheme Lebyy -configuration Debug \
  -destination 'generic/platform=iOS' \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID \
  CODE_SIGN_STYLE=Automatic \
  -derivedDataPath build-device \
  build
```

Find your Team ID: [Apple Developer Membership](https://developer.apple.com/account) → Membership details, or Xcode → Settings → Accounts → Team.

---

## 3) App features (both platforms)

Side menu:

| Menu | Practice |
|------|----------|
| Shop | Add to cart, badge count, REMOVE toggle, checkout |
| Alerts | Alert / Confirm / Prompt |
| Forms | Text, Switch (+ status), Dropdown, Checkboxes, Radios, Active/Inactive |
| Swipe Left / Right | Horizontal carousel |
| Swipe Up / Down | Long list |
| Gestures | Long press + Double tap |
| Web Browser | Debuggable WebView |
| LOGOUT | Back to login |

### Useful accessibility ids

- `test-Menu`, `test-Shop`, `test-Alerts`, `test-Forms`
- `test-SwipeHorizontal`, `test-SwipeVertical`, `test-Gestures`
- `test-WEBVIEW`, `test-LOGOUT`
- `test-Username`, `test-Password`, `test-LOGIN`
- `test-ADD TO CART`, `test-REMOVE`, `test-Cart`, `test-CartCount`
- `test-Switch`, `test-SwitchStatus-ON` / `test-SwitchStatus-OFF`
- `test-Alert`, `test-Confirm`, `test-Prompt`
- `test-LongPress`, `test-DoubleTap`

---

## 4) Automation config tip (MobileWright)

```ts
// Android
platform: 'android',
bundleId: 'com.lebyy.app',
installApps: './releases/Lebyy-debug.apk',

// iOS
platform: 'ios',
bundleId: 'com.lebyy.app',
```

If you changed the iOS Bundle ID for signing, use **that** Bundle ID in tests.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| iOS: *Signing for "Lebyy" requires a development team* | Add Apple ID in Xcode Accounts, pick Team |
| iOS: *Failed to install / Untrusted Developer* | Trust certificate on iPhone under Device Management |
| iOS: Bundle ID already in use | Change to `com.lebyy.app.yourname` |
| Android: *App not installed* | Uninstall older package first: `adb uninstall com.lebyy.app` |
| Android Studio can't find SDK | Open project once in Android Studio so it creates `local.properties` |

---

## License / purpose

Training / demo app for mobile automation practice. Not an App Store production release.
