# Lebyy — Automation Scenario Spec (Android + iOS)

**Purpose:** Self-contained brief for generating Appium (Java/Python) or XCUITest scripts.  
Same flows on both platforms. Prefer **accessibility id** `test-*` everywhere.

**Out of scope:** Shop E2E (catalog → cart → checkout → orders / payment / coupons). Automate that separately.

---

## 0. How to use this doc (for Cursor / codegen)

When generating a script from a scenario:

1. Use **AppiumBy.accessibilityId("…")** (Android `content-desc` / iOS `accessibilityIdentifier`).
2. Follow **Navigate** blocks exactly before steps.
3. Assert against the **Exact expected text** columns (case-sensitive where shown).
4. Apply **Platform notes** only where listed; default path is shared.
5. Prefer explicit waits on screen ids (`test-*-Screen` / hub ids) over fixed sleeps.
6. Do **not** invent locators — only use ids listed here.

Suggested class names:

| Id | Class |
|----|--------|
| SC-01 | `AlertsDialogsFlowTest` |
| SC-02 | `FormInputsTogglesFlowTest` |
| SC-03 | `FormSelectionValidationOtpFlowTest` |
| SC-04 | `GesturesSwipesFlowTest` |
| SC-05 | `ListsWaitsFlowTest` |
| SC-06 | `SystemWebViewFlowTest` |
| SC-07 | `AuthSettingsNavigationFlowTest` |

---

## 1. App identity

| | Android | iOS |
|--|---------|-----|
| Package / Bundle | `com.demo.lebyy` | `com.demo.lebyy` |
| Display name | Lebyy | Lebyy |
| Automation | UiAutomator2 | XCUITest |
| Deep link scheme | `lebyy://…` | `lebyy://…` |

**Credentials**

| Field | Value |
|-------|--------|
| Username | `demo_user` |
| Password | `demo_pass` |
| OTP success | `1234` |
| Invalid login message | contains `Invalid credentials` (id `test-LoginError`) |

**Common Appium Java find:**

```java
driver.findElement(AppiumBy.accessibilityId("test-Tab-Components")).click();
```

**Common wait pattern:**

```java
new WebDriverWait(driver, Duration.ofSeconds(10))
  .until(ExpectedConditions.visibilityOfElementLocated(
    AppiumBy.accessibilityId("test-AlertsScreen")));
```

---

## 2. Global shell navigation

### Bottom tabs

| Tab | Accessibility id | Visible label |
|-----|------------------|---------------|
| Home | `test-Tab-Home` | Home |
| Components | `test-Tab-Components` | Components |
| Shop | `test-Tab-Shop` | Shop |
| Account | `test-Tab-Account` | Account |

Shell container: `test-MainTabs`  
Android also: drawer `test-Menu-panel` (optional; prefer tabs).

**iOS tip:** Tab may resolve as `tabBars.buttons["Components"]` if id not on tab chrome; try accessibility id first, fall back to label.

### Components catalog (no login)

Open: `test-Tab-Components` → wait `test-ComponentsScreen`

| Category | Accessibility id |
|----------|------------------|
| Alerts & Dialogs | `test-Components-Alerts` |
| Form Controls | `test-Components-Forms` |
| Swipes | `test-Components-Swipes` |
| Gestures | `test-Components-Gestures` |
| Lists | `test-Components-Lists` |
| Waits | `test-Components-Waits` |
| System | `test-Components-System` |
| Navigation | `test-Components-Navigation` |
| WebView | `test-Components-WebView` |

### Form Controls hub

Open: `test-Components-Forms` → wait `test-FormControlsHub`

| Topic | Accessibility id | Topic screen id |
|-------|------------------|-----------------|
| Text Fields | `test-FormTopic-textFields` | `test-FormTopicScreen-textFields` |
| Switches | `test-FormTopic-switches` | `test-FormTopicScreen-switches` |
| Sliders | `test-FormTopic-sliders` | `test-FormTopicScreen-sliders` |
| Date & Time | `test-FormTopic-pickers` | `test-FormTopicScreen-pickers` |
| PickerView | `test-FormTopic-pickerView` | `test-FormTopicScreen-pickerView` |
| Selection | `test-FormTopic-selection` | `test-FormTopicScreen-selection` |
| Validation | `test-FormTopic-validation` | `test-FormTopicScreen-validation` |
| OTP / PIN | `test-FormTopic-otp` | `test-FormTopicScreen-otp` |
| Duplicate Locators | `test-FormTopic-duplicates` | `test-FormTopicScreen-duplicates` |

Shared forms banner on every form topic screen: **`test-FormsResult`** (starts as `Result: —`).

### Helper: open Components → category

```
1. click test-Tab-Components
2. wait test-ComponentsScreen
3. click test-Components-{Category}
4. wait matching screen id below
```

---

## 3. Element-type hints (Appium / XCUITest)

| Control | Typical query | Notes |
|---------|---------------|-------|
| Most buttons / rows | accessibility id | Works both platforms |
| Switch | Switch / SwitchCompat | value often `0`/`1` or `true`/`false` |
| Checkbox (iOS) | **Button** `test-Checkbox-1/2` | value `Checked` / `Unchecked` |
| Checkbox (Android) | CheckBox | standard checked state |
| Slider | Slider / SeekBar | set value via platform API / gestures |
| Picker wheel (iOS) | `pickerWheels` under `test-PickerView` | sendKeys / adjustToPickerWheelValue |
| Picker (Android) | NumberPicker `test-PickerView` | swipe or set value |
| Dropdown | `test-Dropdown` | open then pick by **visible text** |
| System alert buttons | label `OK` / `CANCEL` | often by name, not test-* |
| Nil / empty value (iOS) | **Other** `test-NilValue` | `.value` is `""`, not Swift `nil` |

**Duplicate ids:** use index — Appium `.get(0)` / `.get(1)`, XCUITest `element(boundBy:)`, Mobilewright `.nth(n)`.

---

## Scenario map

| # | Scenario | Login? |
|---|----------|--------|
| SC-01 | Alerts & Dialogs Marathon | No |
| SC-02 | Form Inputs & Toggles | No |
| SC-03 | Selection, Validation & OTP | No |
| SC-04 | Gestures & Swipes | No |
| SC-05 | Lists & Async Waits | No |
| SC-06 | System & Hybrid WebView | No |
| SC-07 | Auth, Settings & In-App Navigation | Partial |

---

# SC-01 — Alerts & Dialogs Marathon

### Navigate

```
test-Tab-Components → test-Components-Alerts
wait: test-AlertsScreen
```

### Locators

| Id | Role |
|----|------|
| `test-AlertsScreen` | Screen root |
| `test-Alert` | Open simple alert |
| `test-Confirm` | Open confirm |
| `test-Prompt` | Open prompt |
| `test-PromptInput` | Prompt text field (inside alert) |
| `test-CustomModal` | Open custom modal |
| `test-ModalBackdrop` | Dimmed backdrop |
| `test-ModalTitle` | Modal title |
| `test-ModalBody` | Modal body |
| `test-ModalOK` | Modal OK |
| `test-ModalCancel` | Modal Cancel |
| `test-BottomSheet` | Open sheet |
| `test-BottomSheetTitle` | Sheet title |
| `test-BottomSheetConfirm` | Confirm sheet |
| `test-BottomSheetDismiss` | Dismiss sheet |
| `test-BottomSheetContent` | Sheet container |
| `test-Toast` | Show toast |
| `test-ToastMessage` | Toast text |
| `test-AlertResult` | Result label |

### Steps

| # | Action | Exact assert on `test-AlertResult` (unless noted) |
|---|--------|--------------------------------------------------|
| 1 | Click `test-Alert` → accept system **OK** | `Result: Alert OK` |
| 2 | Click `test-Confirm` → **OK** | `Result: Confirm OK` |
| 3 | Click `test-Confirm` → **CANCEL** | `Result: Confirm CANCEL` |
| 4 | Click `test-Prompt` → type `Lucky` in `test-PromptInput` → **OK** | `Result: Prompt Lucky` |
| 5 | Click `test-CustomModal` → `test-ModalOK` | `Result: Modal OK` |
| 6 | Click `test-CustomModal` → `test-ModalCancel` | `Result: Modal Cancel` |
| 6b | (optional) Open modal → tap `test-ModalBackdrop` | `Result: Modal backdrop` |
| 7 | Click `test-BottomSheet` → `test-BottomSheetConfirm` | `Result: Bottom Sheet Confirm` |
| 8 | Click `test-BottomSheet` → `test-BottomSheetDismiss` | `Result: Bottom Sheet Dismiss` |
| 9 | Click `test-Toast` | Result `Result: Toast shown`; `test-ToastMessage` visible containing `Toast: Saved successfully` |

### Platform notes

- System Alert/Confirm/Prompt OK/CANCEL: match by **button name/label** (`OK`, `CANCEL`), not `test-*`.
- Custom modal / sheet / toast use `test-*` ids.

---

# SC-02 — Form Inputs & Toggles

### Navigate base

```
test-Tab-Components → test-Components-Forms
wait: test-FormControlsHub
```

Shared assert target: **`test-FormsResult`**.

---

### A. Text Fields

**Navigate:** `test-FormTopic-textFields` → wait `test-FormTopicScreen-textFields`

| Id | Type | Sample input | Exact / pattern assert (`test-FormsResult`) |
|----|------|--------------|-----------------------------------------------|
| `test-Input` | TextField | `hello` | `Result: Plain hello` |
| `test-SecureInput` | SecureField | `secret` | Android: `Result: Secure typed` · iOS: assert field non-empty |
| `test-EmailInput` | TextField | `a@b.com` | `Result: Email a@b.com` |
| `test-MultilineInput` | TextField multiline | `line1` | Contains `Result: Notes` |

---

### B. Switches & checkboxes

**Navigate:** back to hub → `test-FormTopic-switches` → wait `test-FormTopicScreen-switches`

| Id | Action | Assert |
|----|--------|--------|
| `test-Switch` | Toggle ON | Result `Result: Switch ON` |
| | | Status id becomes `test-SwitchStatus-ON` (both platforms); Android label text `Switch status: ON` |
| `test-Switch` | Toggle OFF | `Result: Switch OFF` / status id `test-SwitchStatus-OFF` |
| `test-Switch-Labeled` | Toggle | `Result: Labeled Switch ON` or `… OFF` |
| `test-Switch-Disabled` | Assert disabled / not clickable | Remains disabled |
| `test-Checkbox-1` | Check Option A | e.g. `Result: Checkbox A` |
| `test-Checkbox-2` | Check Option B | `Result: Checkbox A,B` (both) or `Result: Checkbox B` |

**iOS checkbox query:** `buttons["test-Checkbox-1"]` (not checkBoxes).  
**Android:** CheckBox by accessibility id.

---

### C. Sliders

**Navigate:** hub → `test-FormTopic-sliders` → wait `test-FormTopicScreen-sliders`

| Id | Range | Value label id | Result pattern |
|----|-------|----------------|----------------|
| `test-Slider` | 0–100 continuous | `test-SliderValue` like `Slider value: N` | `Result: Slider N` |
| `test-Slider-Stepped` | 1–5 step 1 | `test-SliderSteppedValue` like `Stepped value: N` | `Result: Stepped N` |

Use platform slider APIs (Android setProgress / iOS slider value / W3C drag).

---

# SC-03 — Selection, Validation & OTP

### Navigate base

```
test-Tab-Components → test-Components-Forms → test-FormControlsHub
```

---

### A. Selection Controls

**Navigate:** `test-FormTopic-selection` → wait `test-FormTopicScreen-selection`

**Dropdown options** (visible text after opening `test-Dropdown`):

- `surendra is awesome`
- `lebyy is awesome`
- `i love your content`
- `i refer this course to my friends`

| # | Action | Assert (`test-FormsResult`) |
|---|--------|------------------------------|
| 1 | Open `test-Dropdown` → pick `lebyy is awesome` | `Result: Dropdown lebyy is awesome` |
| 2 | Select radio 2 | Android: click `test-Radio-2` · iOS: segment in `test-RadioGroup` → Result contains `Radio 2` |
| 3 | Click `test-Active` | `Result: Active tapped (…)` |
| 4 | Click `test-Inactive` | `Result: Inactive tapped` |
| 5 | **iOS only:** find **Other** `test-NilValue` | `value` equals `""` (empty string; not nil) |

Android radios: `test-Radio-1`, `test-Radio-2` inside `test-RadioGroup`.

---

### B. Date & Time

**Navigate:** hub → `test-FormTopic-pickers` → wait `test-FormTopicScreen-pickers`

| Id | Action | Assert |
|----|--------|--------|
| `test-DatePicker` | Open / change date | `test-DateValue` updates; Result `Result: Date …` |
| `test-TimePicker` | Open / change time | `test-TimeValue` updates; Result `Result: Time …` |

**Android:** buttons open system DatePickerDialog / TimePickerDialog — confirm after selection.  
**iOS:** DatePicker — prefer reading `test-DateValue` / `test-TimeValue`. Calendar day cells use system labels; compute dynamically if tapping days.

---

### C. PickerView

**Navigate:** hub → `test-FormTopic-pickerView` → wait `test-FormTopicScreen-pickerView`

**Single wheel values:** `Apple`, `Banana`, `Cherry`, `Dragonfruit`, `Elderberry`, `Fig`, `Grape`  
**Multi colors:** `Red`, `Green`, `Blue`, `Yellow`, `Purple`  
**Multi sizes:** `S`, `M`, `L`, `XL`

| Id | Platform | Assert |
|----|----------|--------|
| `test-PickerView` | Both | After select `Banana`: `test-PickerViewValue` = `Selected: Banana`; Result `Result: PickerView Banana` |
| `test-PickerView-Multi` | Container | — |
| `test-PickerView-Color` / `test-PickerView-Size` | **Android** NumberPickers | Multi value e.g. `Selected: Blue / L` |
| iOS multi | `pickerWheels` under multi picker | Same text on `test-PickerViewMultiValue` |

---

### D. Validation

**Navigate:** hub → `test-FormTopic-validation` → wait `test-FormTopicScreen-validation`

| Id | Purpose |
|----|---------|
| `test-ValidationName` | Full name |
| `test-ValidationEmail` | Email |
| `test-ValidationSubmit` | Submit |
| `test-ValidationError-1` | First error |
| `test-ValidationError-2` | Second error |
| `test-ValidationSuccess` | Success text `Form looks good` |

| # | Action | Assert |
|---|--------|--------|
| 1 | Clear fields → `test-ValidationSubmit` | Result `Result: Validation failed`; `test-ValidationError-1` = `Name is required`; if email invalid also `test-ValidationError-2` = `Email is invalid` |
| 2 | Name `Demo User`, email `demo@lebyy.com` → Submit | Result `Result: Validation OK`; `test-ValidationSuccess` visible |

---

### E. OTP / PIN

**Navigate:** hub → `test-FormTopic-otp` → wait `test-FormTopicScreen-otp`

| Id | Role |
|----|------|
| `test-OTPGroup` | Group |
| `test-OTP-1` … `test-OTP-4` | Digit fields (1 char each) |
| `test-OTPValue` | Shows `OTP value: ####` |
| `test-OTPVerify` | Verify button |

| # | Action | Assert |
|---|--------|--------|
| 1 | Enter `0000` → `test-OTPVerify` | `Result: OTP wrong` |
| 2 | Clear / enter `1234` → Verify | `Result: OTP success`; `test-OTPValue` contains `1234` |
| 3 | (optional) Enter only 2 digits → Verify | `Result: OTP incomplete` |

---

### F. Duplicate Locators

**Navigate:** hub → `test-FormTopic-duplicates` → wait `test-FormTopicScreen-duplicates`

| Id | Count | Index meaning |
|----|-------|---------------|
| `test-DuplicateHint` | 1 | Hint text |
| `test-DuplicateField` | **2** | 0 = Field A, 1 = Field B |
| `test-DuplicateButton` | **2** | 0 = first button, 1 = second |

| # | Action | Assert (`test-FormsResult`) |
|---|--------|------------------------------|
| 1 | Type `aaa` into field index 0 | `Result: FieldA aaa` |
| 2 | Type `bbb` into field index 1 | `Result: FieldB bbb` |
| 3 | Click button index 0 | `Result: DuplicateButton boundBy:0` |
| 4 | Click button index 1 | `Result: DuplicateButton boundBy:1` |

---

# SC-04 — Gestures & Swipes

---

### A. Gestures

**Navigate:**

```
test-Tab-Components → test-Components-Gestures
wait: test-GesturesScreen
```

| Id | Role |
|----|------|
| `test-GestureResult` | Result label |
| `test-LongPress` | Long-press target (~0.6s+) |
| `test-DoubleTap` | Double-tap target |
| `test-DragItem` | Draggable |
| `test-DropTarget` | Drop zone |
| `test-ResetDragDrop` | Reset drag |
| `test-PinchImage` | Pinch/zoom |
| `test-PinchValue` | Zoom text |
| `test-ResetPinch` | Reset zoom |
| `test-MultiTouch` / `test-MultiTouchBox` | Multi-touch area |
| `test-SimulateMultiTouch` | Button simulating 2-finger |
| `test-ContextMenuTarget` | Long-press for menu |
| `test-ContextCopy` / `test-ContextShare` / `test-ContextDelete` | Menu actions |
| `test-ContextMenu` | Android menu container (if shown) |

| # | Action | Exact `test-GestureResult` |
|---|--------|----------------------------|
| 1 | Long press `test-LongPress` | `Result: Long Pressed` |
| 2 | Double tap `test-DoubleTap` | `Result: Double Tapped` |
| 3 | Drag `test-DragItem` onto `test-DropTarget` | `Result: Drag Dropped` (or `Result: Drag Missed` if miss) |
| 4 | `test-ResetDragDrop` | `Result: —` |
| 5 | Pinch `test-PinchImage` | `Result: Pinch X.XXx`; `test-PinchValue` updates |
| 6 | `test-ResetPinch` | `Result: Pinch reset` |
| 7 | `test-SimulateMultiTouch` | `Result: Multi-touch N` (N ≥ 1) |
| 8 | Long-press `test-ContextMenuTarget` → `test-ContextCopy` | `Result: Context Copy` (Share/Delete similarly) |

Use W3C Actions for long-press, double-tap, drag, pinch.

---

### B. Swipes

**Navigate:**

```
test-Tab-Components → test-Components-Swipes
wait: test-SwipesHub
```

| Id | Role |
|----|------|
| `test-SwipeNav-Horizontal` | Open carousel |
| `test-SwipeCarousel` | Carousel container |
| `test-SwipeNav-Vertical` | Open vertical list |
| `test-SwipeVerticalList` | List |
| `test-Views Item {n}` | Row n (1…40), e.g. `test-Views Item 20` |

| # | Action | Assert |
|---|--------|--------|
| 1 | Open horizontal → swipe left/right on carousel | `test-SwipeCarousel` still present; page/card changes |
| 2 | Back → open vertical → scroll down | Element `test-Views Item 25` (or similar) becomes visible |

---

# SC-05 — Lists & Async Waits

---

### A. Lists

**Navigate:**

```
test-Tab-Components → test-Components-Lists
wait: test-ListsScreen
```

| Id | Role |
|----|------|
| `test-PullRefreshHint` | Hint |
| `test-PullRefreshList` | Pull-to-refresh list |
| `test-RefreshItem` | Row (multiple) |
| `test-RefreshCount` | Text like `Refresh count: N` |
| `test-SwipeActionsList` | Swipe actions list |
| `test-SwipeRow` | Row (multiple) |
| `test-SwipeDeleteAction` | Delete action |
| `test-SwipeEditAction` | Edit action |
| `test-SwipeActionResult` | Result of swipe action |
| `test-ResetSwipeRows` | Reset rows |
| `test-NestedHorizontalScroll` | Nested H-scroll |
| `test-NestedCard-1` … `test-NestedCard-10` | Cards |
| `test-InfiniteList` | Infinite list |
| `test-InfiniteItem` | Items (shared id) |
| `test-InfiniteLoading` | Loading indicator |
| `test-InfinitePageCount` | `Pages loaded: N` |

| # | Action | Assert |
|---|--------|--------|
| 1 | Pull down on `test-PullRefreshList` | `test-RefreshCount` increments (e.g. 0 → 1) |
| 2 | Swipe a `test-SwipeRow` → Delete | `test-SwipeActionResult` contains `Deleted:` |
| 3 | Or swipe → Edit | Contains `Edited:` |
| 4 | `test-ResetSwipeRows` | Rows restored |
| 5 | Scroll `test-NestedHorizontalScroll` | `test-NestedCard-8` (or higher) visible |
| 6 | Scroll `test-InfiniteList` to end repeatedly | `test-InfinitePageCount` increases; optional `test-InfiniteLoading` |

---

### B. Waits

**Navigate:**

```
test-Tab-Components → test-Components-Waits
wait: test-WaitsScreen
```

| Id | Role |
|----|------|
| `test-DelayStepper` | iOS stepper / Android group |
| `test-DelayMinus` / `test-DelayPlus` / `test-DelayValue` / `test-DelaySeek` | **Android** delay controls |
| `test-LoadDelayed` | Start delayed load |
| `test-LoadingSpinner` | Spinner while loading |
| `test-DelayedContent` | Appears after delay |
| `test-SimulateNetworkFail` | Force error |
| `test-SimulateNetworkSuccess` | Force success |
| `test-NetworkStatus-Idle` / `-Loading` / `-Error` / `-Success` | Status |
| `test-NetworkErrorMessage` | Error copy |
| `test-NetworkRetry` | Retry |

| # | Action | Assert |
|---|--------|--------|
| 1 | Set delay ~2–3s → `test-LoadDelayed` | `test-LoadingSpinner` then `test-DelayedContent` (text contains `Content ready after`) |
| 2 | `test-SimulateNetworkFail` | `test-NetworkStatus-Error` + `test-NetworkErrorMessage` |
| 3 | `test-NetworkRetry` | `test-NetworkStatus-Success` |
| 4 | (optional) `test-SimulateNetworkSuccess` | Success status |

Use explicit wait up to delay+buffer (e.g. 10s) for delayed content.

---

# SC-06 — System & Hybrid WebView

---

### A. System

**Navigate:**

```
test-Tab-Components → test-Components-System
wait: test-SystemScreen
```

| Id | Role |
|----|------|
| `test-PermissionCamera` / `test-PermissionLocation` / `test-PermissionNotifications` | Request permission |
| `test-PermissionAllow` / `test-PermissionDeny` | Dialog buttons |
| `test-PermissionResult` | e.g. `Permission: Camera Allow` |
| `test-PickPhoto` | Photos picker |
| `test-UseSampleImage` | Sample image |
| `test-SelectedImage` | Selection text |
| `test-ImagePreview` | Preview (if sample) |
| `test-ShareText` | Text field |
| `test-CopyClipboard` / `test-PasteClipboard` | Clipboard |
| `test-ShareSheet` | Share sheet |
| `test-ClipboardResult` | Clipboard status |
| `test-OrientationHint` | Hint |
| `test-ForcePortrait` | Toggle |
| `test-Orientation-Portrait` / `test-Orientation-All` | Mode id (dynamic) |

| # | Action | Assert |
|---|--------|--------|
| 1 | `test-PermissionCamera` → `test-PermissionAllow` | `test-PermissionResult` = `Permission: Camera Allow` |
| 2 | (optional) Deny path → `Permission: Camera Deny` | |
| 3 | `test-UseSampleImage` | `test-SelectedImage` not `None`; preview may show |
| 4 | Set `test-ShareText` to `Lebyy QA` → Copy → Paste | `test-ClipboardResult` contains copied/pasted value |
| 5 | Toggle `test-ForcePortrait` | Mode id switches Portrait ↔ All |

OS permission sheets may still appear on real devices — handle system Allow/Don’t Allow if needed.

---

### B. WebView

**Navigate:**

```
test-Tab-Components → test-Components-WebView
wait: test-WebBrowserScreen
```

| Id | Role |
|----|------|
| `test-enter a https url here...` | URL field (**exact id**, includes spaces + ellipsis) |
| `test-GO TO SITE` | Load URL |
| `test-LoadStarterPage` | Load starter HTML |
| `test-LoadJSAlertPage` | Page that fires JS alert |
| `test-WebResult` | Native result/status |
| `test-WebView` / `test-WebViewInner` | WebView |

| # | Action | Assert |
|---|--------|--------|
| 1 | `test-LoadStarterPage` | `test-WebView` present; `test-WebResult` updates |
| 2 | Type `https://example.com` into URL field → `test-GO TO SITE` | Page loads |
| 3 | **Context switch (Android critical):** `getContextHandles()` → `driver.context("WEBVIEW_…")` → optional web DOM assert → `driver.context("NATIVE_APP")` | Context switch succeeds |
| 4 | `test-LoadJSAlertPage` → accept JS alert | Alert handled; native result/status updates |

**iOS:** print context names before switching (`WEBVIEW_<bundle>` may differ).

---

# SC-07 — Auth, Settings & In-App Navigation

**Do not** run full Shop checkout in this scenario.

---

### A. Login gestures (while logged out)

**Navigate:** `test-Tab-Account` → wait `test-LoginScreen`

| Id | Role |
|----|------|
| `test-LoginScreen` | Screen |
| `test-LoginBrand` | Brand |
| `test-DemoCredentials` | Creds hint |
| `test-Username` | Username field |
| `test-Password` | Password field |
| `test-LOGIN` | Login button |
| `test-LoginError` | Error text |
| `test-QuickGestures` | Section header |
| `test-LoginLongPress` | Long press (~2s) |
| `test-LoginDoubleTap` | Double tap |
| `test-LoginGestureResult` | Gesture result |
| `test-LoginGestureResult-Dismiss` | Dismiss result |

| # | Action | Assert |
|---|--------|--------|
| 1 | Long press `test-LoginLongPress` | `test-LoginGestureResult` = `Long press done` |
| 2 | Double tap `test-LoginDoubleTap` | `Double tap done` |
| 3 | Username `bad` / Password `bad` → `test-LOGIN` | `test-LoginError` visible |
| 4 | Username `demo_user` / Password `demo_pass` → `test-LOGIN` | `test-AccountSignedIn` or `test-AccountScreen` |

---

### B. Account & Settings (logged in)

| Id | Role |
|----|------|
| `test-AccountScreen` | Account root |
| `test-AccountSignedIn` | Signed-in label |
| `test-DisplayName` | Display name field |
| `test-OpenSettings` | Open settings |
| `test-LOGOUT` | Logout |
| `test-SettingsScreen` | Settings root |
| `test-SaveProfile` | Save |
| `test-ProfileSaved` | Saved banner |
| `test-SessionTimeoutToggle` | Enable auto logout |
| `test-SessionTimeoutStepper` | Timeout seconds |
| `test-SessionCountdown` | Countdown text |
| `test-ResetSessionTimer` | Reset timer |
| `test-ForceLogout` | Force logout |

| # | Action | Assert |
|---|--------|--------|
| 1 | `test-OpenSettings` → edit `test-DisplayName` → `test-SaveProfile` | `test-ProfileSaved` contains `Saved:` |
| 2 | Enable `test-SessionTimeoutToggle`; adjust stepper | `test-SessionCountdown` appears / ticks |
| 3 | Prefer `test-ForceLogout` or Account `test-LOGOUT` (don’t wait full timeout in CI) | Back to `test-LoginScreen` |

---

### C. Navigation practice + shop gate (no full E2E)

**Navigate (logged out OK):**

```
test-Tab-Components → test-Components-Navigation
wait: test-NavigationScreen
```

| Id | Role |
|----|------|
| `test-LastDeepLink` | Last deep link label |
| `test-DeepLinkHelp` | Help text |
| `test-BottomTabs` | Nested demo tab bar |
| `test-Tab-Home` / `test-Tab-Search` / `test-Tab-Profile` | Nested demo tabs (**not** shell tabs when on this screen) |
| `test-TabContent-Home` / `-Search` / `-Profile` | Tab content |
| `test-SelectedTab` | Selected tab label |
| `test-ShopLoginGateTitle` | Shop gate title |
| `test-ShopGoLogin` | Go to login from shop |

**Caution:** Nested Navigation also uses `test-Tab-Home`. Prefer content ids / labels Search & Profile after opening Navigation screen.

| # | Action | Assert |
|---|--------|--------|
| 1 | Switch nested tabs | `test-SelectedTab` / `test-TabContent-*` match |
| 2 | (optional) Deep link via `driver.get("lebyy://waits")` / simctl | `test-LastDeepLink` or Home `test-HomeDeepLink` shows URL |
| 3 | While logged out: shell `test-Tab-Shop` | `test-ShopLoginGateTitle` + `test-ShopGoLogin` → Account login |

**Deep link examples:** `lebyy://home`, `lebyy://components`, `lebyy://alerts`, `lebyy://forms`, `lebyy://swipes`, `lebyy://gestures`, `lebyy://lists`, `lebyy://waits`, `lebyy://system`, `lebyy://navigation`, `lebyy://webview`, `lebyy://account`, `lebyy://login`, `lebyy://shop`, `lebyy://settings`

---

## 4. Intentionally not covered here

| Item | Reason |
|------|--------|
| Shop catalog → cart → checkout → payment → orders | Separate framework E2E |
| Sign up / register | Not in Lebyy (WDIO Appium scripts only) |
| Launch-only smoke | Add `wait test-MainTabs` / `test-HomeScreen` in `@Before` if needed |
| Bank customer + manager | `BANK_E2E.md` (BK-E2E-C and BK-E2E-M) |

---

## 5. Minimal `@Before` checklist for generated tests

1. Start driver with package/bundle `com.demo.lebyy`.
2. Wait for `test-MainTabs` or `test-HomeScreen`.
3. SC-01…SC-06: Components tab; login not required.
4. SC-07: start logged out for login steps.
5. After SC-07: leave logged out for next run (`noReset: false` or explicit logout).

Bank customer and manager scripts are specified in `BANK_E2E.md`, the same way shop checkout is specified in `SHOP_E2E.md`.
