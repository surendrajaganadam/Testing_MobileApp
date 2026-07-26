# Lebyy — E2E practice app

Debuggable Android app for MobileWright training. Colors from [lebyy.com](https://lebyy.com).

## Login

Shown on screen:
- Username: `demo_user`
- Password: `demo_pass`

## Side menu

| Menu | What to practice |
|------|------------------|
| Shop | Add to cart / checkout E2E |
| Alerts | Alert, Confirm, Prompt (+ `android:id/button1`) |
| Forms | Text field, Switch, Dropdown, Checkboxes, Radios, Active/Inactive buttons |
| Swipe Left / Right | ViewPager carousel (WDIO-style) |
| Swipe Up / Down | Long list (ApiDemos Views-style) |
| Gestures | Long press + Double tap targets |
| Web Browser | Debuggable WebView |
| LOGOUT | Back to login |

## Useful accessibility ids

- `test-Menu`, `test-Shop`, `test-Alerts`, `test-Forms`
- `test-SwipeHorizontal`, `test-SwipeVertical`, `test-Gestures`
- `test-WEBVIEW`, `test-LOGOUT`
- `test-Alert`, `test-Confirm`, `test-Prompt`
- `test-Input`, `test-Switch`, `test-Dropdown`, `test-Checkbox-1`, `test-Radio-1`, `test-Active`
- `test-LongPress`, `test-DoubleTap`, `test-GestureResult`
- `test-SwipeCarousel`, `test-SwipeVerticalList`

## Build

```bash
cd "Mobile App/Lebyy-Android"
./gradlew assembleDebug
cp app/build/outputs/apk/debug/app-debug.apk \
  ../../_publish_Testing_MobileApp/releases/Lebyy-debug.apk
```

Package: `com.demo.lebyy`
