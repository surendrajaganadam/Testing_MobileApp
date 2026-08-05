# Lebyy — E2E practice app (Android)

WebdriverIO-style **bottom tabs** + UIKitCatalog-style **Components**. Parity with iOS.

**Locators:** see [`../LOCATORS.md`](../LOCATORS.md)

## Tabs

| Tab | Login? | What |
|-----|--------|------|
| Home | No | Brand + shortcuts |
| Components | No | Practice categories (no login) |
| Shop | Yes | Catalog → cart → checkout → orders |
| Account | Login/logout | Credentials + settings + logout |

## Login

- Username: `demo_user`
- Password: `demo_pass`
- OTP: `1234`

## Build

```bash
cd "Mobile App/Lebyy-Android"
./gradlew assembleDebug
```

Package: `com.demo.lebyy`
