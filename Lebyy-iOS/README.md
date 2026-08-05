# Lebyy iOS

WebdriverIO-style **bottom tabs** + UIKitCatalog-style **Components**. Same app as Android.

**Locators:** see [`../LOCATORS.md`](../LOCATORS.md)

## Tabs

| Tab | Login? | What |
|-----|--------|------|
| Home | No | Brand + shortcuts |
| Components | No | Alerts, Forms (nested topics), Swipes, Gestures, Lists, Waits, System, Navigation, WebView |
| Shop | Yes | Full E2E catalog → cart → checkout → orders |
| Account | Login/logout | `demo_user` / `demo_pass` |

Form Controls → **Switches** shows multiple switch variants (default, labeled, disabled, checkboxes) like UIKitCatalog.

## Credentials

- Username: `demo_user`
- Password: `demo_pass`
- OTP practice: `1234`

## Bundle ID

`com.demo.lebyy`

## Build

```bash
cd "Mobile App/Lebyy-iOS"
xcodegen generate
xcodebuild -scheme Lebyy -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build build
```
