# Lebyy — Shop E2E Scenario Spec (Android + iOS)

**Purpose:** Self-contained brief for one complete shop checkout flow in Appium (Java/Python), XCUITest, or Mobilewright.  
Same business path on both platforms. Prefer **accessibility id** `test-*` everywhere.

**Companion:** Component practice flows live in `SCENARIOS.md`. This document is the shop path that file leaves out: catalog → cart → shipping → payment → coupon → place order → history → cancel → logout.

---

## 0. How to use this doc (for Cursor / codegen)

When generating a script from a scenario:

1. Use **AppiumBy.accessibilityId("…")** (Android `content-desc` / iOS `accessibilityIdentifier`).
2. Follow **Navigate** blocks exactly before steps.
3. Assert against the **Exact expected text** columns (case-sensitive where shown).
4. Apply **Platform notes** only where listed; default path is shared.
5. Prefer explicit waits on the screen ids in section 4 over fixed sleeps.
6. Do **not** invent locators — only use ids listed here.
7. Order ids are runtime values (`LB-` + unix seconds). Assert the **prefix** `LB-` on `test-OrderId`. Never hard-code the number.
8. Money strings use a leading `$` and two decimals. Discount lines use a Unicode minus: `−$` (U+2212), not a hyphen.

Suggested class names:

| Id | Class |
|----|--------|
| SH-00 | `ShopLoginGateTest` |
| SH-E2E | `ShopCheckoutE2ETest` |
| SH-01 | `ShopSearchSortTest` |
| SH-02 | `ShopCheckoutValidationTest` |
| SH-03 | `ShopCartRemoveTest` |

Run **SH-E2E** as the primary framework flow. The others cover gates and failures the same screens must still handle.

---

## 1. App identity

| | Android | iOS |
|--|---------|-----|
| Package / Bundle | `com.demo.lebyy` | `com.demo.lebyy` |
| Display name | Lebyy | Lebyy |
| Automation | UiAutomator2 | XCUITest |
| Deep link | `lebyy://shop` | `lebyy://shop` |

**Credentials**

| Field | Value |
|-------|--------|
| Username | `demo_user` |
| Password | `demo_pass` |
| Invalid login | contains `Invalid credentials` (id `test-LoginError`) |

**Payment fixture (practice card, no Luhn check)**

| Field | Type this | Field shows |
|-------|-----------|-------------|
| Card | `4242424242424242` | `4242 4242 4242 4242` |
| Expiry | `1228` | `12/28` |
| CVV | `123` | masked |
| Last 4 on review / order | — | `4242` |

Card and expiry auto-format while typing. Continue stays disabled until the card has **16 digits** and expiry is **5 characters** (`MM/YY`). CVV is stored but does **not** gate Continue.

**Common wait (catalog is up):**

```java
new WebDriverWait(driver, Duration.ofSeconds(15))
  .until(ExpectedConditions.visibilityOfElementLocated(
    AppiumBy.accessibilityId("test-ShopSearch")));
```

---

## 2. Catalog, addresses, coupons, money

### Products (default sort: Name A–Z)

| Id | Name (also locator `test-{Name}`) | Price |
|----|-------------------------------------|-------|
| c5 | CI/CD for QA | $12.99 |
| c3 | API Testing Bootcamp | $14.99 |
| c4 | Selenium WebDriver | $17.99 |
| c1 | Playwright Mastery | $19.99 |
| c6 | Mobilewright Essentials | $21.99 |
| c2 | Appium Mobile Testing | $24.99 |

Name A–Z order: API Testing Bootcamp, Appium Mobile Testing, CI/CD for QA, Mobilewright Essentials, Playwright Mastery, Selenium WebDriver.

Price Low–High order: CI/CD for QA, API Testing Bootcamp, Selenium WebDriver, Playwright Mastery, Mobilewright Essentials, Appium Mobile Testing.

### Saved addresses (Shipping screen)

| Locator | Label | Fills |
|---------|-------|--------|
| `test-SavedAddress-home` | `Home — Demo City` | First `Demo`, Last `User`, Zip `560001` |
| `test-SavedAddress-work` | `Work — Lebyy Hub` | First `Surendra`, Last `QA`, Zip `500081` |
| `test-SavedAddress-lab` | `Lab — Automation Park` | First `Mobile`, Last `Wright`, Zip `94105` |

### Coupons (Review screen)

| Code | Title | Off |
|------|-------|-----|
| `LEBYY10` | Lebyy starter — 10% off | 10% |
| `SAVE15` | Weekend deal — 15% off | 15% |
| `WELCOME20` | Welcome bonus — 20% off | 20% |
| `STUDENT25` | Student special — 25% off | 25% |

Any other non-empty code is accepted and discounted at **10%**. Empty apply clears the coupon.

Discount = round-half-up of `subtotal × percent / 100` to cents. Total = subtotal − discount.

### SH-E2E expected totals

Cart built in the main flow:

| Line | Qty | Line total |
|------|-----|------------|
| Mobilewright Essentials @ $21.99 | 3 | $65.97 |
| Playwright Mastery @ $19.99 | 1 | $19.99 |
| **Subtotal** | | **$85.96** |
| WELCOME20 (−20%) | | **−$17.19** |
| **Total** | | **$68.77** |

Cart badge after both adds: **4** (3 + 1).

---

## 3. How to reach the catalog

Shop is login-gated. Components is not.

### Logged out

```
click test-Tab-Shop
wait: test-ShopLoginGateTitle   text: Shop needs login
click test-ShopGoLogin          → Account / Login (test-LoginScreen or test-Username)
```

`test-ShopOpenCatalog`, `test-OpenOrders`, and `test-Cart` are hidden while logged out.

### Login (from Account, or after Go to Login)

```
click test-Tab-Account          (skip if already on login)
wait: test-Username
type test-Username = demo_user
type test-Password = demo_pass
click test-LOGIN
```

Success leaves Account and opens Shop. Failure shows `test-LoginError`.

### Logged in — open catalog

**iOS:** the Shop tab **is** the catalog.

```
wait: test-ShopScreen
also visible: test-ShopSearch, test-OpenOrders, test-Cart
```

**Android:** selecting Shop auto-opens `CatalogActivity`. If the thin launcher is still showing, open it yourself.

```
if test-ShopReady is visible ("Shop ready"):
    click test-ShopOpenCatalog
wait: test-ShopSearch
toolbar title: Shop
also visible once catalog is up: test-OpenOrders, test-Cart
```

Deep link `lebyy://shop` while logged out sends the user to Account. After a successful login the pending shop destination opens.

---

## 4. Screen map

| Screen | Wait for | Title |
|--------|----------|-------|
| Shop gate | `test-ShopLoginGateTitle` | Shop |
| Shop ready (Android launcher only) | `test-ShopReady` | Shop |
| Catalog | `test-ShopSearch` (iOS also `test-ShopScreen`) | Shop |
| Product details | `test-ProductName` | Product Details |
| Cart | `test-CHECKOUT` **or** `test-CartEmptyTitle` | Your Cart |
| Shipping | `test-First Name` | Shipping |
| Payment | `test-Card Number` | Payment |
| Review | `test-PLACE ORDER` | Review Order |
| Order details | `test-OrderId` | Order Details |
| Order history | `test-Order` **or** `test-OrdersEmpty` | Order History |
| Account signed in | `test-AccountSignedIn` | Account |

### Bottom tabs (always)

| Tab | Accessibility id |
|-----|------------------|
| Home | `test-Tab-Home` |
| Components | `test-Tab-Components` |
| Shop | `test-Tab-Shop` |
| Account | `test-Tab-Account` |

Shell: `test-MainTabs`. Prefer tabs. Android drawer `test-Menu-panel` is optional.

**iOS tip:** a tab may resolve as `tabBars.buttons["Shop"]` if the id is not on the tab chrome. Try the accessibility id first, then the label.

---

## 5. Locator catalog

### Catalog

| Id | Role |
|----|------|
| `test-ShopTab` | Shop tab container |
| `test-ShopScreen` | **iOS** catalog root |
| `test-ShopSearch` | Search field. Hint `Search courses` |
| `test-ClearSearch` | Visible only while search is non-empty. Label `Clear Search` |
| `test-ShopSortBar` | Sort chip row |
| `test-Sort-NameAsc` | `Name A–Z` (default) |
| `test-Sort-NameDesc` | `Name Z–A` |
| `test-Sort-PriceLow` | `Price Low–High` |
| `test-Sort-PriceHigh` | `Price High–Low` |
| `test-ShopCount` | Count label. **See platform note** |
| `test-ShopEmpty` | `No courses found` |
| `test-ShopEmptyMessage` | **iOS only.** `Try another search term` |
| `test-{Product Name}` | Open that product. Example `test-Mobilewright Essentials` |
| `test-ProductCard` | **Android** card container (repeats) |
| `test-WISHLIST` / `test-UNWISH` | Card wishlist toggle (repeats; id swaps) |
| `test-ADD TO CART` / `test-REMOVE` | Card cart toggle (repeats; id swaps) |
| `test-OpenOrders` | Orders. Label `Orders` |
| `test-Cart` | Cart. Label `Cart` |
| `test-CartCount` | Badge. Hidden at 0. Text is the quantity sum (`99+` above 99) |

**`test-ShopCount` platform note**

- **iOS:** id stays `test-ShopCount`. Label/text is `Showing N courses`.
- **Android:** after the list refreshes, `contentDescription` is replaced by the sentence `Showing N courses`. Assert that **text**, not `test-ShopCount`.

### Product details

| Id | Role |
|----|------|
| `test-ProductName` | Course name |
| `test-ProductPrice` | `$19.99` style |
| `test-ProductDesc` | Description |
| `test-Rating-1` … `test-Rating-5` | Star buttons |
| `test-RatingBar` | Star row |
| `test-RatingValue` | **iOS** id. Text `Your rating: N/5`. **Android** overwrites the id with that same sentence — assert the text |
| `test-ADD TO WISHLIST` / `test-REMOVE FROM WISHLIST` | Detail wishlist (id swaps) |
| `test-QtyMinus` | Decrement. Floor is 1 |
| `test-QtyValue` | Current qty. Starts at `1` |
| `test-QtyPlus` | Increment. No cap |
| `test-ADD TO CART` | Adds `QtyValue` and **closes** details (returns to catalog) |

### Cart

| Id | Role |
|----|------|
| `test-CartEmptyTitle` | `Your cart is empty` |
| `test-CartEmptyMessage` | `Browse courses on Shop and tap ADD TO CART — no need to open product details first.` |
| `test-CONTINUE SHOPPING` | Empty cart only. Returns to catalog |
| `test-CartQty` | Repeats per line. Text `Qty: N | $X.XX` (line total) |
| `test-REMOVE` | Repeats per line. Removes that line |
| `test-CHECKOUT` | Hidden when cart is empty |

Cart footer text (no separate id): `Total: $X.XX`. On Android this is the cart total TextView under the list.

### Shipping

| Id | Role |
|----|------|
| `test-SavedAddress-home` / `work` / `lab` | Tap fills the three fields |
| `test-First Name` | |
| `test-Last Name` | |
| `test-Zip/Postal Code` | |
| `test-CONTINUE` | Disabled until all three fields are non-blank |
| `test-CANCEL` | **Android only.** Closes shipping |

### Payment

| Id | Role |
|----|------|
| `test-Card Number` | Groups digits in fours, max 16 |
| `test-Card Expiry` | Formats `MM/YY` |
| `test-Card CVV` | Digits only, max 4, secure field |
| `test-CardPlaceholder` | `Card: 4242 4242 4242 4242` |
| `test-ExpiryPlaceholder` | **iOS.** `Expiry: MM/YY  ·  CVV: 123` |
| `test-CONTINUE TO REVIEW` | Disabled until card length 16 and expiry length 5 |

### Review

| Id | Role |
|----|------|
| `test-ReviewItem` | One row per line on **iOS**. **Android** is one block, lines joined with newlines. Text `• {name} x{qty} — ${line}` |
| `test-ReviewEmpty` | **iOS** if cart already placed: `Cart is empty — order already placed. Open Order History for details.` |
| `test-VIEW COUPONS` | Opens the sample list. Label becomes `HIDE COUPONS` while open |
| `test-HIDE COUPONS` | **Android only**, replaces the id while the list is open. **iOS** keeps `test-VIEW COUPONS` and changes the label |
| `test-CouponList` | Sample list container |
| `test-SampleCoupon-{CODE}` | Row. Example `test-SampleCoupon-WELCOME20` |
| `test-ApplyCoupon-{CODE}` | Row APPLY. Example `test-ApplyCoupon-WELCOME20` |
| `test-Coupon` | Manual code field. Stays visible after apply, value = applied code |
| `test-APPLY COUPON` | Applies whatever is in `test-Coupon` |
| `test-CouponApplied` | `Coupon applied: {CODE} (−{N}%)` |
| `test-ReviewShipping` | `{First} {Last}` newline `{Zip}` |
| `test-ReviewPayment` | `Card ending {last4}` |
| `test-ReviewSubtotal` | `Subtotal: $X.XX` |
| `test-ReviewDiscount` | Visible only when discount > 0. `Discount: −$X.XX` |
| `test-ReviewTotal` | `Total: $X.XX` |
| `test-PLACE ORDER` | Disabled when cart is empty |
| `test-CANCEL` | **Android only.** Closes review |

### Order details and history

| Id | Role |
|----|------|
| `test-OrderConfirmed` | `Order confirmed` while status is placed |
| `test-OrderCancelled` | `Order cancelled` after cancel. Replaces the confirmed id |
| `test-OrderId` | `LB-…` |
| `test-OrderDate` | Medium date + short time. Do not assert the clock |
| `test-OrderItem` | Same line format as review. **iOS** one node per item. **Android** one block |
| `test-OrderShipping` | Same shape as review shipping |
| `test-OrderPayment` | `Card ending {last4}` |
| `test-OrderSubtotal` | Shown only if discount > 0. `Subtotal: $X.XX` |
| `test-OrderDiscount` | `Discount ({CODE}): −$X.XX` |
| `test-OrderTotal` | `Total: $X.XX` |
| `test-CANCEL ORDER` | Visible only while status is placed. Tap once; no confirm dialog |
| `test-ORDER HISTORY` | Opens history. After checkout, this is the way out (back is hidden) |
| `test-Order` | **Every** history row. Use `.get(0)` / `element(boundBy: 0)` / `.nth(0)` for the newest |
| `test-OrderStatus-Cancelled` | **iOS** badge text `CANCELLED` on a cancelled row |
| `test-OrdersEmpty` | `No orders yet` |

History row text:

- **iOS:** id line plus `$68.77 · 2 item(s)` (`item(s)` = line count, not unit qty).
- **Android:** `{id}  ·  $68.77` and, after cancel, `{id}  ·  $68.77 · CANCELLED`.

### Account

| Id | Role |
|----|------|
| `test-Username` / `test-Password` / `test-LOGIN` | Login |
| `test-LoginError` | Bad credentials |
| `test-AccountSignedIn` | Text `Signed in` |
| `test-LOGOUT` | Clears cart, search, and checkout fields. **Keeps** order history |

---

## 6. Duplicate ids — how to click the right one

These ids repeat. Do not click the first match on the screen unless the step says so.

| Id | Where it repeats | How to target |
|----|------------------|---------------|
| `test-ADD TO CART` | Every catalog card not yet in the cart, and the details button | On the catalog, use the button in the same card as `test-{Product Name}`. On details there is only one |
| `test-REMOVE` | Catalog card (already in cart) and each cart line | Catalog: same card as the product name. Cart: the `test-REMOVE` in the row whose name you can read |
| `test-WISHLIST` / `test-UNWISH` | Every catalog card | Same card as `test-{Product Name}` |
| `test-CartQty` | Each cart line | Read all; assert the set of strings |
| `test-ReviewItem` / `test-OrderItem` | iOS: one per line | Assert each expected line is present |
| `test-Order` | Every history row | Newest is index 0 |
| `test-Cart` | Android icon and its parent | Either click is fine |

Scroll the catalog until `test-{Product Name}` is visible before clicking its card button. Default sort puts **Mobilewright Essentials** and **Playwright Mastery** below the fold on a phone.

---

# SH-E2E — Complete shop checkout

**Login?** Yes. Start logged out (fresh launch).  
**Class:** `ShopCheckoutE2ETest`  
**Goal:** sign in, search, add two courses (one with quantity), check out with a saved address and WELCOME20, confirm the order, cancel it, and log out to an empty cart.

### Navigate

```
fresh app
test-Tab-Account → login demo_user / demo_pass → test-LOGIN
wait catalog: test-ShopSearch
```

Android may already be inside the catalog because Shop auto-opens after login. If `test-ShopReady` is what you see, click `test-ShopOpenCatalog`, then wait `test-ShopSearch`.

---

### Phase A — Login gate, then sign in

| # | Action | Exact assert |
|---|--------|--------------|
| A1 | Click `test-Tab-Shop` | `test-ShopLoginGateTitle` text `Shop needs login` |
| A2 | Click `test-ShopGoLogin` | `test-Username` visible |
| A3 | Type `demo_user` into `test-Username` | Field value `demo_user` |
| A4 | Type `demo_pass` into `test-Password` | Field non-empty (secure) |
| A5 | Click `test-LOGIN` | Catalog: `test-ShopSearch` visible. iOS also `test-ShopScreen`. Count text `Showing 6 courses` |

---

### Phase B — Search, then add Mobilewright Essentials × 3 from details

| # | Action | Exact assert |
|---|--------|--------------|
| B1 | Type `Mobilewright` into `test-ShopSearch` | `test-ClearSearch` visible. Count `Showing 1 courses`. `test-Mobilewright Essentials` visible. Price text `$21.99` |
| B2 | Click `test-Mobilewright Essentials` | `test-ProductName` = `Mobilewright Essentials`. `test-ProductPrice` = `$21.99`. `test-QtyValue` = `1`. `test-RatingValue` text `Your rating: 0/5` |
| B3 | Click `test-Rating-4` | Rating text `Your rating: 4/5` |
| B4 | Click `test-QtyPlus` | `test-QtyValue` = `2` |
| B5 | Click `test-QtyPlus` | `test-QtyValue` = `3` |
| B6 | Click `test-QtyMinus` | `test-QtyValue` = `2` |
| B7 | Click `test-QtyPlus` | `test-QtyValue` = `3` |
| B8 | Click `test-ADD TO CART` on **this details screen** | Details dismiss. Catalog is back. `test-CartCount` text `3` |
| B9 | Click `test-ClearSearch` | Search empty. `test-ClearSearch` gone. Count `Showing 6 courses` |

`test-ProductDesc` on that details screen contains `Native mobile UI automation with Mobilewright`.

---

### Phase C — Add Playwright Mastery × 1 from the catalog card

Do this on the card, not by opening details. The card button adds quantity 1.

| # | Action | Exact assert |
|---|--------|--------------|
| C1 | Scroll until `test-Playwright Mastery` is visible | Name visible. Price `$19.99` |
| C2 | On **that card only**, click `test-ADD TO CART` | That card’s button id becomes `test-REMOVE` and its label is `REMOVE`. `test-CartCount` text `4` |

Leave Mobilewright’s catalog card alone. It should now show `test-REMOVE` as well (it is already in the cart). Do not tap it — that would remove the ×3 line.

---

### Phase D — Cart

| # | Action | Exact assert |
|---|--------|--------------|
| D1 | Click `test-Cart` | Title area is the cart. `test-CHECKOUT` visible. `test-CartEmptyTitle` absent |
| D2 | Read every `test-CartQty` | Set contains `Qty: 3 \| $65.97` and `Qty: 1 \| $19.99` |
| D3 | Read the total line | `Total: $85.96` |

Row names on screen: `Mobilewright Essentials` and `Playwright Mastery`.

---

### Phase E — Shipping (saved work address)

| # | Action | Exact assert |
|---|--------|--------------|
| E1 | Click `test-CHECKOUT` | `test-First Name` visible. `test-CONTINUE` **disabled** |
| E2 | Click `test-SavedAddress-work` | `test-First Name` = `Surendra`. `test-Last Name` = `QA`. `test-Zip/Postal Code` = `500081`. `test-CONTINUE` **enabled** |
| E3 | Click `test-CONTINUE` | `test-Card Number` visible |

---

### Phase F — Payment

| # | Action | Exact assert |
|---|--------|--------------|
| F1 | On arrival | `test-CONTINUE TO REVIEW` **disabled**. `test-CardPlaceholder` text `Card: 4242 4242 4242 4242` |
| F2 | Type `4242424242424242` into `test-Card Number` | Field text `4242 4242 4242 4242` |
| F3 | Type `1228` into `test-Card Expiry` | Field text `12/28`. `test-CONTINUE TO REVIEW` **enabled** (CVV not required) |
| F4 | Type `123` into `test-Card CVV` | Field non-empty |
| F5 | Click `test-CONTINUE TO REVIEW` | `test-PLACE ORDER` visible |

If the keyboard covers Continue, hide the keyboard before the click.

---

### Phase G — Coupon and review

| # | Action | Exact assert |
|---|--------|--------------|
| G1 | Read items | Text contains `• Mobilewright Essentials x3 — $65.97` and `• Playwright Mastery x1 — $19.99` |
| G2 | Read shipping `test-ReviewShipping` | `Surendra QA` and `500081` |
| G3 | Read payment `test-ReviewPayment` | `Card ending 4242` |
| G4 | Read money before coupon | `test-ReviewSubtotal` = `Subtotal: $85.96`. `test-ReviewDiscount` absent. `test-ReviewTotal` = `Total: $85.96` |
| G5 | Click `test-VIEW COUPONS` | `test-CouponList` visible. `test-SampleCoupon-WELCOME20` visible. Button label `HIDE COUPONS` |
| G6 | Click `test-ApplyCoupon-WELCOME20` | List hides. `test-Coupon` value `WELCOME20`. `test-CouponApplied` = `Coupon applied: WELCOME20 (−20%)` |
| G7 | Read money after coupon | `test-ReviewSubtotal` = `Subtotal: $85.96`. `test-ReviewDiscount` = `Discount: −$17.19`. `test-ReviewTotal` = `Total: $68.77` |
| G8 | Click `test-PLACE ORDER` | Order details. `test-OrderConfirmed` = `Order confirmed`. `test-OrderId` starts with `LB-`. Remember this id as `{orderId}` |

---

### Phase H — Order details match the review

| # | Action | Exact assert |
|---|--------|--------------|
| H1 | `test-OrderItem` | Contains `• Mobilewright Essentials x3 — $65.97` and `• Playwright Mastery x1 — $19.99` |
| H2 | `test-OrderShipping` | `Surendra QA` and `500081` |
| H3 | `test-OrderPayment` | `Card ending 4242` |
| H4 | `test-OrderSubtotal` | `Subtotal: $85.96` |
| H5 | `test-OrderDiscount` | `Discount (WELCOME20): −$17.19` |
| H6 | `test-OrderTotal` | `Total: $68.77` |
| H7 | `test-CANCEL ORDER` | Visible. `test-OrderDate` visible (do not match the timestamp) |
| H8 | Click `test-ORDER HISTORY` | History shows at least one `test-Order`. Index 0 text contains `{orderId}` and `$68.77`. iOS also `2 item(s)` |

Back is hidden on the post-checkout details screen. Leave via `test-ORDER HISTORY` only.

Cart is already empty: placing the order clears lines, coupon, and checkout fields.

---

### Phase I — Cancel, then log out

| # | Action | Exact assert |
|---|--------|--------------|
| I1 | Click `test-Order` index 0 | Details for `{orderId}`. `test-OrderConfirmed` still `Order confirmed` |
| I2 | Click `test-CANCEL ORDER` | `test-OrderCancelled` = `Order cancelled`. `test-CANCEL ORDER` gone. `test-OrderTotal` still `Total: $68.77` |
| I3 | Click `test-ORDER HISTORY` | Index 0 still `{orderId}`. **iOS:** `test-OrderStatus-Cancelled` text `CANCELLED`. **Android:** row text contains `CANCELLED` |
| I4 | Back to the shell. Click `test-Cart` (catalog toolbar, or Android Shop launcher) | `test-CartEmptyTitle` = `Your cart is empty`. `test-CHECKOUT` absent. `test-CartCount` absent |
| I5 | Click `test-CONTINUE SHOPPING` | Catalog `test-ShopSearch` visible |
| I6 | Click `test-Tab-Account` | `test-AccountSignedIn` = `Signed in` |
| I7 | Click `test-LOGOUT` | Login fields are back (`test-Username`). Click `test-Tab-Shop` → `test-ShopLoginGateTitle` = `Shop needs login` |

Logout keeps the cancelled order in memory for this process, but the cart and the coupon are gone. A fresh app launch starts with an empty history.

---

### SH-E2E platform notes

- **Android Shop tab** is a launcher (`test-ShopReady`, `test-ShopOpenCatalog`) plus an auto-opened catalog. **iOS Shop tab** is the catalog (`test-ShopScreen`). There is no `test-ShopOpenCatalog` on iOS.
- **Android `test-ShopCount` and `test-RatingValue`** lose the `test-*` id at runtime. Assert the visible sentence (`Showing N courses`, `Your rating: N/5`).
- **Hide coupons id:** Android switches the button to `test-HIDE COUPONS`. iOS keeps `test-VIEW COUPONS` and only the label changes.
- **Android** shipping and review have `test-CANCEL`. iOS uses the navigation back button.
- **System keyboard** on payment: number pad. Dismiss before `test-CONTINUE TO REVIEW` if it covers the button.
- **Unicode minus** in `Discount: −$17.19` and `Coupon applied: WELCOME20 (−20%)`. Copy the character from this doc; a hyphen `-` will fail the assert.
- Cart line order is not guaranteed. Assert the **set** of `test-CartQty` strings.

---

# SH-00 — Shop login gate

**Login?** No.  
**Class:** `ShopLoginGateTest`

### Navigate

```
fresh app, logged out
```

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Click `test-Tab-Shop` | `test-ShopLoginGateTitle` = `Shop needs login`. `test-ShopGoLogin` visible. `test-ShopOpenCatalog` absent |
| 2 | Click `test-ShopGoLogin` | `test-Username` visible |
| 3 | Type `wrong` / `wrong`, click `test-LOGIN` | `test-LoginError` contains `Invalid credentials`. Still logged out |
| 4 | Clear fields. Type `demo_user` / `demo_pass`, click `test-LOGIN` | Catalog `test-ShopSearch`. Count `Showing 6 courses` |
| 5 | Click `test-Tab-Account`, click `test-LOGOUT` | `test-Username` visible |
| 6 | Click `test-Tab-Shop` | Gate is back: `Shop needs login` |

---

# SH-01 — Search, sort, empty catalog

**Login?** Yes (complete SH-E2E phase A, or log in the same way).  
**Class:** `ShopSearchSortTest`  
**Cart:** leave it empty.

### Navigate

```
logged in → catalog (test-ShopSearch)
```

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Default catalog | Count `Showing 6 courses`. Sort `test-Sort-NameAsc` is the selected chip. First name on screen is `API Testing Bootcamp` |
| 2 | Click `test-Sort-PriceLow` | First name is `CI/CD for QA` at `$12.99`. Last, after scroll, is `Appium Mobile Testing` at `$24.99` |
| 3 | Click `test-Sort-PriceHigh` | First name is `Appium Mobile Testing` at `$24.99` |
| 4 | Click `test-Sort-NameDesc` | First name is `Selenium WebDriver` |
| 5 | Click `test-Sort-NameAsc` | First name is `API Testing Bootcamp` again |
| 6 | Type `appium` into `test-ShopSearch` | Count `Showing 1 courses`. Only `test-Appium Mobile Testing` |
| 7 | Replace search with `zzzz` | Count `Showing 0 courses`. `test-ShopEmpty` = `No courses found`. iOS: `test-ShopEmptyMessage` = `Try another search term` |
| 8 | Click `test-ClearSearch` | Count `Showing 6 courses`. `test-ShopEmpty` absent |

Search matches name **or** description, case-insensitive. `appium` hits the Appium course only.

---

# SH-02 — Checkout stays blocked until fields are valid

**Login?** Yes. Cart must contain one unit of API Testing Bootcamp.  
**Class:** `ShopCheckoutValidationTest`

### Setup

```
catalog → card test-API Testing Bootcamp → that card's test-ADD TO CART
test-CartCount = 1
test-Cart → test-CHECKOUT
```

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Arrive on Shipping with empty fields | `test-CONTINUE` disabled |
| 2 | Type `Ada` into `test-First Name` only | `test-CONTINUE` still disabled |
| 3 | Type `Lovelace` into `test-Last Name` | Still disabled |
| 4 | Type `10001` into `test-Zip/Postal Code` | `test-CONTINUE` enabled |
| 5 | Click `test-CONTINUE` | Payment. `test-CONTINUE TO REVIEW` disabled |
| 6 | Type `4242` into `test-Card Number` | Still disabled (not 16 digits) |
| 7 | Type the rest so the field reads `4242 4242 4242 4242` | Still disabled until expiry is complete |
| 8 | Type `12` into `test-Card Expiry` | Still disabled (length ≠ 5) |
| 9 | Type `28` so the field reads `12/28` | `test-CONTINUE TO REVIEW` enabled |
| 10 | Click `test-CONTINUE TO REVIEW` | `test-ReviewTotal` = `Total: $14.99`. `test-PLACE ORDER` enabled |
| 11 | Do **not** place the order. Leave review | No new `test-Order` |

---

# SH-03 — Remove a cart line

**Login?** Yes.  
**Class:** `ShopCartRemoveTest`

### Setup

Add **CI/CD for QA** and **Selenium WebDriver** from their catalog cards (qty 1 each). `test-CartCount` = `2`.

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Open `test-Cart` | Total `Total: $30.98` (`12.99 + 17.99`). Both qty lines present: `Qty: 1 \| $12.99` and `Qty: 1 \| $17.99` |
| 2 | Click `test-REMOVE` on the **CI/CD for QA** row | That row is gone. Remaining qty `Qty: 1 \| $17.99`. Total `Total: $17.99`. Badge `test-CartCount` = `1` |
| 3 | Click `test-REMOVE` on the Selenium row | `test-CartEmptyTitle` = `Your cart is empty`. `test-CHECKOUT` absent. Badge hidden |
| 4 | Click `test-CONTINUE SHOPPING` | Catalog. Both cards show `test-ADD TO CART` again (not `test-REMOVE`) |

---

## 7. What this flow does not cover

Leave these out of SH-E2E unless you add a separate test:

- Wishlist (`test-WISHLIST` → `test-UNWISH` on the card, `test-ADD TO WISHLIST` on details).
- A typed coupon such as `QA` (expect `Coupon applied: QA (−10%)`).
- Deep link `lebyy://shop` / `lebyy://orders`.
- Session timeout on Account → Settings.
- Re-placing an order from a review screen whose cart is already empty (`test-PLACE ORDER` stays disabled).

---

## 8. Generator checklist

- [ ] Accessibility id only, except Android sentences that replace `test-ShopCount` and `test-RatingValue`.
- [ ] Scope duplicate `test-ADD TO CART` / `test-REMOVE` to the product card or cart row.
- [ ] Wait on `test-ShopSearch`, `test-ProductName`, `test-First Name`, `test-Card Number`, `test-PLACE ORDER`, `test-OrderId`.
- [ ] Assert `$68.77`, `−$17.19`, and `WELCOME20` exactly.
- [ ] Assert `test-OrderId` **starts with** `LB-`.
- [ ] After place order, exit details with `test-ORDER HISTORY`.
- [ ] End logged out, cart empty, shop gate showing.
