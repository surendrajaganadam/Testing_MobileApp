# Lebyy — Bank E2E Scenario Spec (Android + iOS)

**Purpose:** Self-contained brief for the bank flows in Appium (Java/Python), XCUITest, or Mobilewright.  
Same business path on both platforms. Prefer **accessibility id** `test-*` everywhere.

**Two roles.** A customer moves money. A manager approves large transfers and creates customers who can then sign in.  
**Companion:** Component practice flows live in `SCENARIOS.md`. Shop checkout lives in `SHOP_E2E.md`. This document is the bank path.

---

## 0. How to use this doc (for Cursor / codegen)

When generating a script from a scenario:

1. Use **AppiumBy.accessibilityId("…")** (Android `content-desc` / iOS `accessibilityIdentifier`).
2. Follow **Navigate** blocks exactly before steps.
3. Assert against the **Exact expected text** columns (case-sensitive where shown).
4. Apply **Platform notes** only where listed; default path is shared.
5. Prefer explicit waits on the screen ids in section 4 over fixed sleeps.
6. Do **not** invent locators — only use ids listed here.
7. On a **fresh app launch**, the first new transfer id is `TX-1001` and the next money movement is `TX-1002`. The seeded pending transfer is always `TX-9001`. Do not hard-code an id that this run did not create.
8. Money strings use a leading `₹` and two decimals (`₹500.00`). The separator in labels is a middle dot `·` (U+00B7), with a space on each side.

Suggested class names:

| Id | Class | Role |
|----|--------|------|
| BK-00 | `BankLoginGateTest` | either |
| BK-E2E-C | `BankCustomerE2ETest` | customer |
| BK-01 | `BankTransferValidationTest` | customer |
| BK-02 | `BankCardTest` | customer |
| BK-03 | `BankLargeTransferTest` | customer |
| BK-E2E-M | `BankManagerE2ETest` | manager |
| BK-04 | `BankRejectTransferTest` | manager |
| BK-05 | `BankCustomerAdminTest` | manager |

Run **BK-E2E-C** and **BK-E2E-M** as the two framework flows. Each one starts from a **fresh app launch**. Do not chain them in one process: approving `TX-9001` changes Demo User’s balance, and creating `asha` blocks a second create.

---

## 1. App identity

| | Android | iOS |
|--|---------|-----|
| Package / Bundle | `com.demo.lebyy` | `com.demo.lebyy` |
| Display name | Lebyy | Lebyy |
| Automation | UiAutomator2 | XCUITest |
| Deep link | `lebyy://bank` | `lebyy://bank` |

**Credentials**

| Who | Username | Password | After `test-LOGIN` |
|-----|----------|----------|--------------------|
| Customer | `demo_user` | `demo_pass` | Shop opens. Click `test-Tab-Bank` yourself |
| Manager | `manager_user` | `manager_pass` | Bank manager home opens |
| Created customer | whatever the manager saved | whatever the manager saved | Shop opens. Click `test-Tab-Bank` |

Invalid login contains `Invalid credentials` (id `test-LoginError`).  
Login hint `test-ManagerCredentials` text: `Manager: manager_user / manager_pass`.  
`test-DemoCredentials` still shows only `demo_user` / `demo_pass`.

**Rules**

| Rule | Value |
|------|--------|
| OTP success | `1234` (one digit per field) |
| OTP failure | any other 4 digits, including `0000` → `Result: OTP wrong` |
| Auto-complete limit | amount `<= 10000` debits immediately after OTP |
| Manager queue | amount `> 10000` does **not** debit. Receipt `Receipt: Pending approval TX-…` |
| Insufficient funds | amount greater than the selected account balance. No new completed row |
| Built-in customer | `demo_user` can be edited, not deleted |

**Common wait (customer bank home):**

```java
new WebDriverWait(driver, Duration.ofSeconds(15))
  .until(ExpectedConditions.visibilityOfElementLocated(
    AppiumBy.accessibilityId("test-BankHome")));
```

---

## 2. Seed data (fresh launch)

### Demo User (`demo_user`)

| Item | Value |
|------|--------|
| Display name | `Demo User` |
| Checking `test-Account-Checking` | `Checking ••0001 · ₹50000.00` |
| Savings `test-Account-Savings` | `Savings ••0002 · ₹12000.00` |
| Payees | Landlord `445566`, Alex `778899` |
| Bills | Electricity `₹850.00`, Mobile `₹499.00` (both paid from Checking) |
| Card | `Visa ••4242`, `Card status: Active`, limit field `20000` |

`••` is two bullet characters (U+2022).

### Seeded activity (newest first)

| Id | Row text on `test-Activity-{id}` |
|----|----------------------------------|
| `TX-9001` | `Debit · Transfer to Landlord · ₹15000.00 · Pending` |
| `TX-8001` | `Credit · Salary · ₹20000.00 · Completed` |
| `TX-8002` | `Debit · Coffee · ₹120.00 · Completed` |

`TX-9001` is already in the manager queue. It does not reduce Checking until a manager approves it.

### BK-E2E-C expected money

Start Checking `₹50000.00`.

| Step | Movement | Checking after |
|------|----------|----------------|
| Transfer `500` to Alex | debit `₹500.00`, id `TX-1001` | `₹49500.00` |
| Pay Electricity | debit `₹850.00`, id `TX-1002` | `₹48650.00` |

Savings stays `₹12000.00`.

### A customer the manager creates

Checking = the balance typed on the form. Savings `₹0.00`. Same starter payees and bills. Card `Visa ••1111`, limit `20000`, active.

---

## 3. How to reach Bank

Bank is login-gated. Components is not.

### Logged out

```
click test-Tab-Bank
wait: test-BankLoginGateTitle   text: Bank needs login
click test-BankGoLogin          → Account / Login (test-Username)
```

Customer and manager actions are hidden while logged out.

### Login

```
click test-Tab-Account          (skip if already on login)
wait: test-Username
type username / password
click test-LOGIN
```

- Customer success opens **Shop**, not Bank. Then click `test-Tab-Bank` and wait `test-BankHome`.
- Manager success opens **Bank** directly. Wait `test-ManagerHome`.
- Failure shows `test-LoginError`.

Deep link `lebyy://bank` while logged out shows the bank gate (or Account, if login is required before the tab can render). After login, open Bank as above.

---

## 4. Screen map

| Screen | Wait for | How you got here |
|--------|----------|------------------|
| Bank gate | `test-BankLoginGateTitle` | `test-Tab-Bank` logged out |
| Customer home | `test-BankHome` | `test-Tab-Bank` as a customer |
| Manager home | `test-ManagerHome` | `test-Tab-Bank` as the manager, or immediately after manager login |
| Transfer | `test-BankTransferScreen` | `test-Bank-Transfer` |
| Confirm transfer | `test-BankTransferConfirmScreen` | `test-TransferContinue` when the amount is valid |
| OTP | `test-BankOtpScreen` | `test-TransferConfirm` when amount `<= 10000` |
| Receipt | `test-BankReceiptScreen` | OTP success, large-transfer confirm, or bill pay |
| Payees | `test-BankPayeesScreen` | `test-Bank-Payees` |
| Add payee | `test-BankAddPayeeScreen` | `test-AddPayee` |
| Bills | `test-BankBillsScreen` | `test-Bank-Bills` |
| Confirm bill | `test-BankBillConfirmScreen` | `test-Bill-Electricity` or `test-Bill-Mobile` |
| Cards | `test-BankCardsScreen` | `test-Bank-Cards` |
| Activity | `test-BankActivityScreen` | `test-Bank-Activity` |
| Pending queue | `test-BankPendingScreen` | `test-Bank-Pending` |
| Review request | `test-BankPendingDetailScreen` | `test-Pending-TX-9001` (or another pending id) |
| Customers | `test-BankCustomersScreen` | `test-Bank-Customers` |
| Customer form | `test-BankCustomerFormScreen` | `test-CustomerCreate` or `test-Customer-{username}` |
| Lookup marker | `test-BankCustomerLookupScreen` | Present on the form only when editing an existing customer |
| Decisions | `test-BankDecisionsScreen` | `test-Bank-Decisions` |

`test-BankDone` on the receipt returns to the bank home (`test-BankHome` or `test-ManagerHome`). Do not rely on the system back button to unwind the transfer stack.

### Bottom tabs (always)

| Tab | Accessibility id |
|-----|------------------|
| Home | `test-Tab-Home` |
| Components | `test-Tab-Components` |
| Shop | `test-Tab-Shop` |
| Bank | `test-Tab-Bank` |
| Account | `test-Tab-Account` |

Shell: `test-MainTabs`. Prefer tabs.

**iOS tip:** a tab may resolve as `tabBars.buttons["Bank"]` if the id is not on the tab chrome. Try the accessibility id first, then the label.

---

## 5. Locator catalog

### Customer home (`test-BankHome`)

| Id | Text |
|----|------|
| `test-BankCustomerName` | `Demo User` until a manager renames them |
| `test-BankRole` | `Role: Customer` |
| `test-Account-Checking` | `Checking ••0001 · ₹50000.00` on a fresh launch |
| `test-Account-Savings` | `Savings ••0002 · ₹12000.00` |
| `test-Bank-Transfer` | Opens transfer |
| `test-Bank-Payees` | Opens payees |
| `test-Bank-Bills` | Opens bills |
| `test-Bank-Cards` | Opens cards |
| `test-Bank-Activity` | Opens activity |

### Transfer

| Id | Role |
|----|------|
| `test-TransferFrom-Checking` | Button. Label includes the live Checking balance |
| `test-TransferFrom-Savings` | Button. Label includes the live Savings balance |
| `test-TransferFromValue` | `From: Checking` or `From: Savings` |
| `test-TransferPayee-{Name}` | Example `test-TransferPayee-Alex`. Label `{Name} · {account number}` |
| `test-TransferPayeeValue` | `Payee: Alex` (empty until a payee is chosen: `Payee:`) |
| `test-TransferAmount` | Type digits only, e.g. `500` |
| `test-TransferContinue` | Validates, then opens confirm |
| `test-TransferSummary` | `Checking → Alex ₹500.00` |
| `test-TransferConfirm` | OTP path if amount `<= 10000`, otherwise queues approval |
| `test-BankOtpHint` | `Enter OTP 1234` |
| `test-BankOTP-1` … `test-BankOTP-4` | One character each |
| `test-BankOTPVerify` | |
| `test-BankReceipt` | `Receipt: Transfer completed TX-1001` or `Receipt: Pending approval TX-1001` or `Receipt: Bill paid TX-1002` |
| `test-BankDone` | Back to bank home |
| `test-BankResult` | Error or success sentence on the screen that produced it |

`test-BankResult` values for transfer:

| Text | When |
|------|------|
| `Result: Select a payee` | Continue with no payee |
| `Result: Amount is required` | Blank, `0`, or not a number |
| `Result: Insufficient funds` | Amount above the selected account |
| `Result: OTP wrong` | Verify with a code other than `1234` |

### Payees

| Id | Role |
|----|------|
| `test-AddPayee` | Opens the form |
| `test-PayeeName` | |
| `test-PayeeAccount` | Digits |
| `test-PayeeSave` | |
| `test-Payee-{Name}` | Example `test-Payee-Rita`. Text `Rita · 909090` |

| `test-BankResult` | When |
|-------------------|------|
| `Result: Name is required` | Blank name |
| `Result: Account number is required` | Blank account |
| `Result: Payee already exists` | Account number already on the list (`445566`, `778899`) |
| `Result: Payee saved` | Success. Form closes. The payees screen shows the new row |

### Bills

| Id | Role |
|----|------|
| `test-Bill-Electricity` | Amount due `₹850.00` |
| `test-Bill-Mobile` | Amount due `₹499.00` |
| `test-BillSummary` | `Electricity ₹850.00 from Checking` |
| `test-BillPay` | Debits Checking and opens the receipt |

### Cards

| Id | Role |
|----|------|
| `test-Card-Visa` | `Visa ••4242` for Demo User, `Visa ••1111` for a created customer |
| `test-CardStatus` | `Card status: Active` or `Card status: Frozen` |
| `test-CardFreeze` | Label `Freeze`, then `Unfreeze` |
| `test-CardLimit` | On open: `20000` |
| `test-CardSaveLimit` | |

| `test-BankResult` | When |
|-------------------|------|
| `Result: Card frozen` | After Freeze |
| `Result: Card active` | After Unfreeze |
| `Result: Limit saved` | Limit is a number `> 0` |
| `Result: Limit is required` | Blank or `0` |

Freezing the card does **not** block transfers or bill pay.

### Activity

The list does not change until `test-ActivitySearchApply` is clicked. Filter chips apply immediately.

| Id | Role |
|----|------|
| `test-ActivitySearch` | Matches title or id, case-insensitive |
| `test-ActivitySearchApply` | Applies the field |
| `test-ActivityFilter-All` | Default |
| `test-ActivityFilter-Credit` | |
| `test-ActivityFilter-Debit` | Includes pending debits |
| `test-ActivityFilter-Pending` | Status is `Pending` |
| `test-ActivityFilterValue` | `Filter: All` (or Credit / Debit / Pending) |
| `test-ActivityCount` | `Showing N` |
| `test-Activity-{id}` | Example `test-Activity-TX-8001` |

Fresh launch, filter All, empty search: `Showing 3`.

### Manager home (`test-ManagerHome`)

| Id | Fresh-launch text |
|----|-------------------|
| `test-ManagerName` | `Branch Manager` |
| `test-BankRole` | `Role: Manager` |
| `test-PendingCount` | `Pending: 1` |
| `test-CustomerCount` | `Customers: 1` |
| `test-Bank-Pending` | |
| `test-Bank-Customers` | |
| `test-Bank-Decisions` | |

`test-PendingCount` and `test-CustomerCount` also appear on the queue screen and the customer list. Assert the one on the screen you are waiting for.

### Pending and decisions

| Id | Role |
|----|------|
| `test-Pending-TX-9001` | `TX-9001 · demo_user → Landlord · ₹15000.00` |
| `test-PendingSummary` | Same sentence on the detail screen |
| `test-PendingApprove` | |
| `test-PendingRejectReason` | |
| `test-PendingReject` | |
| `test-DecisionCount` | `Decisions: N` |
| `test-Decision-D-1` | First decision of the process. Text `Approved TX-9001 by Branch Manager` or `Rejected TX-9001 by Branch Manager · Over limit` |

| `test-BankResult` | When |
|-------------------|------|
| `Result: Approved` | Approve succeeded. Checking is debited. The row leaves the queue |
| `Result: Reason is required` | Reject with a blank reason. The row stays pending |
| `Result: Rejected` | Reject with a reason. Checking is **not** debited |

Approve of `TX-9001` on a fresh launch sets Demo User Checking to `₹35000.00` (`50000 − 15000`).

### Customers

Search does not apply until `test-CustomerSearchApply`.

| Id | Role |
|----|------|
| `test-CustomerSearch` | Matches display name or username |
| `test-CustomerSearchApply` | |
| `test-CustomerCreate` | Empty form. No lookup section |
| `test-CustomerCount` | `Customers: N` for the current filter |
| `test-Customer-demo_user` | `Demo User · demo_user` |
| `test-Customer-{username}` | Example `test-Customer-asha` |
| `test-CustomerName` | |
| `test-CustomerUsername` | |
| `test-CustomerPassword` | On edit, leave blank to keep the old password |
| `test-CustomerBalance` | Checking balance. Create: type `8000`. Edit Demo User on a fresh launch: field shows `50000.00` |
| `test-CustomerSave` | |
| `test-CustomerDelete` | Only when editing. Hidden on create |
| `test-Lookup-Checking` | `Checking ••0001 · ₹8000.00` |
| `test-Lookup-Savings` | `Savings ••0002 · ₹0.00` for a new customer |
| `test-LookupActivityTitle` | `Recent activity` |
| `test-Lookup-{txnId}` | Up to 5 newest rows |

| `test-BankResult` | When |
|-------------------|------|
| `Result: Customer created` | |
| `Result: Customer updated` | |
| `Result: Customer deleted` | Created customers only |
| `Result: Built-in customer cannot be deleted` | `test-CustomerDelete` on `demo_user` |
| `Result: Name is required` | |
| `Result: Username is required` | |
| `Result: Password is required` | Create only |
| `Result: Balance is required` | Blank or negative |
| `Result: Username already exists` | `demo_user`, `asha` again, or `manager_user` |

### Account (shared with Shop)

| Id | Role |
|----|------|
| `test-Username` / `test-Password` / `test-LOGIN` | |
| `test-LoginError` | |
| `test-DemoCredentials` | Unchanged shop hint |
| `test-ManagerCredentials` | `Manager: manager_user / manager_pass` |
| `test-AccountSignedIn` | `Signed in` |
| `test-LOGOUT` | Ends the session. **Keeps** bank customers, balances, the queue, and decisions until the process ends |

---

## 6. Duplicate ids

| Id | Where it repeats | How to target |
|----|------------------|---------------|
| `test-BankResult` | Whichever screen last set a result | Assert it only after the action, on that screen |
| `test-PendingCount` | Manager home and pending queue | Wait for `test-ManagerHome` or `test-BankPendingScreen` first |
| `test-CustomerCount` | Manager home and customer list | Same idea |
| `test-BankRole` | Customer home (`Role: Customer`) and manager home (`Role: Manager`) | Wait for `test-BankHome` or `test-ManagerHome` first |

---

# BK-E2E-C — Customer: payee, transfer, bill, activity

**Login?** Yes. Start logged out (fresh launch).  
**Class:** `BankCustomerE2ETest`  
**Goal:** sign in as Demo User, add payee Rita, send `₹500.00` to Alex with OTP, pay the electricity bill, see both rows in activity, and log out.

### Navigate

```
fresh app
test-Tab-Account → demo_user / demo_pass → test-LOGIN
click test-Tab-Bank
wait: test-BankHome
```

---

### Phase A — Gate, then sign in

| # | Action | Exact assert |
|---|--------|--------------|
| A1 | Click `test-Tab-Bank` | `test-BankLoginGateTitle` = `Bank needs login`. `test-BankGoLogin` visible |
| A2 | Click `test-BankGoLogin` | `test-Username` visible |
| A3 | Type `demo_user` / `demo_pass`, click `test-LOGIN` | Shop is showing (`test-ShopSearch` or Android `test-ShopReady`). Bank home is **not** showing yet |
| A4 | Click `test-Tab-Bank` | `test-BankHome`. `test-BankRole` = `Role: Customer`. `test-BankCustomerName` = `Demo User` |
| A5 | Read accounts | `test-Account-Checking` = `Checking ••0001 · ₹50000.00`. `test-Account-Savings` = `Savings ••0002 · ₹12000.00` |

---

### Phase B — Add payee Rita

| # | Action | Exact assert |
|---|--------|--------------|
| B1 | Click `test-Bank-Payees` | `test-BankPayeesScreen`. `test-Payee-Landlord` and `test-Payee-Alex` visible |
| B2 | Click `test-AddPayee` | `test-BankAddPayeeScreen` |
| B3 | Leave both fields empty. Click `test-PayeeSave` | `test-BankResult` = `Result: Name is required` |
| B4 | Type `Rita` into `test-PayeeName`. Leave account empty. Click `test-PayeeSave` | `test-BankResult` = `Result: Account number is required` |
| B5 | Type `909090` into `test-PayeeAccount`. Click `test-PayeeSave` | Form closes. `test-BankPayeesScreen`. `test-Payee-Rita` = `Rita · 909090`. `test-BankResult` = `Result: Payee saved` |
| B6 | Back until `test-BankHome` | Checking balance still `₹50000.00` |

---

### Phase C — Transfer ₹500 from Checking to Alex

Pick the account and the payee **before** typing the amount.

| # | Action | Exact assert |
|---|--------|--------------|
| C1 | Click `test-Bank-Transfer` | `test-BankTransferScreen`. `test-TransferFromValue` = `From: Checking`. `test-TransferPayeeValue` = `Payee:` |
| C2 | Click `test-TransferFrom-Checking` | `test-TransferFromValue` = `From: Checking` |
| C3 | Click `test-TransferPayee-Alex` | `test-TransferPayeeValue` = `Payee: Alex` |
| C4 | Type `500` into `test-TransferAmount` | |
| C5 | Click `test-TransferContinue` | `test-BankTransferConfirmScreen`. `test-TransferSummary` = `Checking → Alex ₹500.00` |
| C6 | Click `test-TransferConfirm` | `test-BankOtpScreen`. `test-BankOtpHint` = `Enter OTP 1234` |
| C7 | Type `1`,`2`,`3`,`4` into `test-BankOTP-1` … `test-BankOTP-4` | Each field holds one digit |
| C8 | Click `test-BankOTPVerify` | `test-BankReceiptScreen`. `test-BankReceipt` = `Receipt: Transfer completed TX-1001` |
| C9 | Click `test-BankDone` | `test-BankHome`. `test-Account-Checking` = `Checking ••0001 · ₹49500.00`. Savings unchanged |

---

### Phase D — Pay Electricity from Checking

| # | Action | Exact assert |
|---|--------|--------------|
| D1 | Click `test-Bank-Bills` | `test-BankBillsScreen` |
| D2 | Click `test-Bill-Electricity` | `test-BankBillConfirmScreen`. `test-BillSummary` = `Electricity ₹850.00 from Checking` |
| D3 | Click `test-BillPay` | `test-BankReceipt` = `Receipt: Bill paid TX-1002` |
| D4 | Click `test-BankDone` | `test-BankHome`. `test-Account-Checking` = `Checking ••0001 · ₹48650.00` |

---

### Phase E — Activity, then log out

| # | Action | Exact assert |
|---|--------|--------------|
| E1 | Click `test-Bank-Activity` | `test-BankActivityScreen`. `test-ActivityFilterValue` = `Filter: All`. `test-ActivityCount` = `Showing 5` |
| E2 | `test-Activity-TX-1001` | `Debit · Transfer to Alex · ₹500.00 · Completed` |
| E3 | `test-Activity-TX-1002` | `Debit · Bill Electricity · ₹850.00 · Completed` |
| E4 | `test-Activity-TX-9001` | Still `Debit · Transfer to Landlord · ₹15000.00 · Pending` |
| E5 | Click `test-ActivityFilter-Pending` | `test-ActivityFilterValue` = `Filter: Pending`. `test-ActivityCount` = `Showing 1`. `test-Activity-TX-9001` visible. `test-Activity-TX-1001` absent |
| E6 | Click `test-ActivityFilter-All`. Type `Salary` into `test-ActivitySearch`. Click `test-ActivitySearchApply` | `test-ActivityCount` = `Showing 1`. `test-Activity-TX-8001` = `Credit · Salary · ₹20000.00 · Completed` |
| E7 | Click `test-Tab-Account` | `test-AccountSignedIn` = `Signed in` |
| E8 | Click `test-LOGOUT` | `test-Username` visible |
| E9 | Click `test-Tab-Bank` | `test-BankLoginGateTitle` = `Bank needs login` |

---

### BK-E2E-C platform notes

- Customer login opens **Shop**. The script must click `test-Tab-Bank`.
- **Android** bank screens are a separate activity. **iOS** pushes them on the Bank tab. `test-BankDone` is the supported way back to `test-BankHome` from a receipt.
- **Android** `test-CustomerPassword` is a password field (value not readable). **iOS** it is a plain text field. Assert it is non-empty when you type; do not assert the password string on Android.
- OTP fields accept one character. Do not type `1234` into `test-BankOTP-1`.
- Dismiss the keyboard before Continue / Verify / Pay if it covers the button.

---

# BK-E2E-M — Manager: approve, create, edit, customer signs in

**Login?** Yes. Start logged out (fresh launch).  
**Class:** `BankManagerE2ETest`  
**Goal:** sign in as the manager, approve the seeded transfer, record the decision, create Asha, rename her, log out, and sign in as Asha on the customer bank home.

Do not run this in the same process as BK-E2E-C. Approve expects Checking to start at `₹50000.00`, and create expects username `asha` to be free.

### Navigate

```
fresh app
test-Tab-Account → manager_user / manager_pass → test-LOGIN
wait: test-ManagerHome
```

---

### Phase A — Manager home

| # | Action | Exact assert |
|---|--------|--------------|
| A1 | After login | `test-ManagerHome`. `test-ManagerName` = `Branch Manager`. `test-BankRole` = `Role: Manager` |
| A2 | Counts | `test-PendingCount` = `Pending: 1`. `test-CustomerCount` = `Customers: 1` |

---

### Phase B — Approve TX-9001

| # | Action | Exact assert |
|---|--------|--------------|
| B1 | Click `test-Bank-Pending` | `test-BankPendingScreen`. `test-PendingCount` = `Pending: 1` |
| B2 | Click `test-Pending-TX-9001` | `test-BankPendingDetailScreen`. `test-PendingSummary` = `TX-9001 · demo_user → Landlord · ₹15000.00` |
| B3 | Click `test-PendingApprove` | `test-BankResult` = `Result: Approved` |
| B4 | Back to `test-BankPendingScreen` | `test-PendingCount` = `Pending: 0`. `test-Pending-TX-9001` absent |
| B5 | Back to `test-ManagerHome` | `test-PendingCount` = `Pending: 0` |
| B6 | Click `test-Bank-Decisions` | `test-BankDecisionsScreen`. `test-DecisionCount` = `Decisions: 1`. `test-Decision-D-1` = `Approved TX-9001 by Branch Manager` |
| B7 | Back to `test-ManagerHome` | |

Approving debits Demo User. If you log in as `demo_user` later in this same process, Checking is `₹35000.00`, and `TX-9001` activity status is `Completed`.

---

### Phase C — Create Asha, then rename her

| # | Action | Exact assert |
|---|--------|--------------|
| C1 | Click `test-Bank-Customers` | `test-BankCustomersScreen`. `test-CustomerCount` = `Customers: 1`. `test-Customer-demo_user` visible |
| C2 | Click `test-CustomerCreate` | `test-BankCustomerFormScreen`. `test-BankCustomerLookupScreen` **absent**. `test-CustomerDelete` absent |
| C3 | `test-CustomerName` = `Asha`, `test-CustomerUsername` = `asha`, `test-CustomerPassword` = `asha_pass`, `test-CustomerBalance` = `8000` | |
| C4 | Click `test-CustomerSave` | `test-BankResult` = `Result: Customer created` |
| C5 | Back to `test-BankCustomersScreen` | `test-CustomerCount` = `Customers: 2`. `test-Customer-asha` = `Asha · asha` |
| C6 | Type `asha` into `test-CustomerSearch`. Click `test-CustomerSearchApply` | `test-CustomerCount` = `Customers: 1`. Only `test-Customer-asha` |
| C7 | Click `test-Customer-asha` | `test-BankCustomerLookupScreen` visible. `test-Lookup-Checking` = `Checking ••0001 · ₹8000.00`. `test-Lookup-Savings` = `Savings ••0002 · ₹0.00` |
| C8 | Change `test-CustomerName` to `Asha Rao`. Leave password blank. Click `test-CustomerSave` | `test-BankResult` = `Result: Customer updated` |
| C9 | Back to the customer list. Clear search and click `test-CustomerSearchApply` | `test-Customer-asha` = `Asha Rao · asha` |

---

### Phase D — Asha signs in as a customer

| # | Action | Exact assert |
|---|--------|--------------|
| D1 | `test-Tab-Account` → `test-LOGOUT` | `test-Username` visible |
| D2 | Type `asha` / `asha_pass`, click `test-LOGIN` | Shop opens (same as any customer) |
| D3 | Click `test-Tab-Bank` | `test-BankHome`. `test-BankRole` = `Role: Customer`. `test-BankCustomerName` = `Asha Rao` |
| D4 | Accounts | `test-Account-Checking` = `Checking ••0001 · ₹8000.00`. `test-Account-Savings` = `Savings ••0002 · ₹0.00` |
| D5 | Click `test-Bank-Payees` | `test-Payee-Landlord` and `test-Payee-Alex` are already there |
| D6 | `test-Tab-Account` → `test-LOGOUT` | `test-Username` visible |
| D7 | Click `test-Tab-Bank` | `Bank needs login` |

---

### BK-E2E-M platform notes

- Manager login opens Bank. Do not click Shop in between.
- Back from a bank screen: **Android** toolbar back. **iOS** navigation back. Receipts in this scenario are not used.
- Blank password on edit keeps `asha_pass`. The later login proves that.
- `test-Decision-D-1` is only `D-1` when this approve is the first decision of the process.

---

# BK-00 — Bank login gate

**Login?** No.  
**Class:** `BankLoginGateTest`

### Navigate

```
fresh app, logged out
```

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Click `test-Tab-Bank` | `test-BankLoginGateTitle` = `Bank needs login`. `test-BankGoLogin` visible. `test-Bank-Transfer` absent. `test-Bank-Pending` absent |
| 2 | Click `test-BankGoLogin` | `test-Username` visible. `test-ManagerCredentials` = `Manager: manager_user / manager_pass` |
| 3 | Type `wrong` / `wrong`, click `test-LOGIN` | `test-LoginError` contains `Invalid credentials` |
| 4 | Clear fields. Type `manager_user` / `manager_pass`, click `test-LOGIN` | `test-ManagerHome`. `test-BankRole` = `Role: Manager` |
| 5 | `test-Tab-Account` → `test-LOGOUT` | `test-Username` |
| 6 | Click `test-Tab-Bank` | Gate is back |

---

# BK-01 — Transfer stays blocked until the form is valid

**Login?** `demo_user`. Fresh launch. Open `test-Bank-Transfer`.  
**Class:** `BankTransferValidationTest`  
**Do not** finish a successful transfer if you still need the fresh `₹50000.00` balance in a later test in this process. This scenario’s last step does complete a `₹1.00` transfer so OTP failure can be checked first.

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Click `test-TransferContinue` with no payee and empty amount | `test-BankResult` = `Result: Select a payee` |
| 2 | Click `test-TransferPayee-Alex`. Click Continue with empty amount | `Result: Amount is required` |
| 3 | Type `0`. Continue | `Result: Amount is required` |
| 4 | Type `999999`. Continue | `Result: Insufficient funds`. Still on `test-BankTransferScreen` |
| 5 | Replace amount with `1`. Continue | `test-TransferSummary` = `Checking → Alex ₹1.00` |
| 6 | Confirm. Type `0`,`0`,`0`,`0`. Click `test-BankOTPVerify` | `test-BankResult` = `Result: OTP wrong`. Still on `test-BankOtpScreen` |
| 7 | Replace with `1`,`2`,`3`,`4`. Verify | `test-BankReceipt` = `Receipt: Transfer completed TX-1001` |
| 8 | Done | Checking `Checking ••0001 · ₹49999.00` |

---

# BK-02 — Freeze the card and change the limit

**Login?** `demo_user`. Open `test-Bank-Cards`.  
**Class:** `BankCardTest`  
Money balances do not change.

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | On open | `test-Card-Visa` = `Visa ••4242`. `test-CardStatus` = `Card status: Active`. `test-CardLimit` = `20000`. Button label `Freeze` |
| 2 | Click `test-CardFreeze` | `test-CardStatus` = `Card status: Frozen`. `test-BankResult` = `Result: Card frozen`. Button label `Unfreeze` |
| 3 | Click `test-CardFreeze` again | `Card status: Active`. `Result: Card active` |
| 4 | Clear `test-CardLimit`. Click `test-CardSaveLimit` | `Result: Limit is required` |
| 5 | Type `30000`. Click `test-CardSaveLimit` | `Result: Limit saved` |
| 6 | Leave and reopen Cards | `test-CardLimit` = `30000`. Status still Active |

---

# BK-03 — Transfer above ₹10000 waits for the manager

**Login?** `demo_user`. Fresh launch (so the new id is `TX-1001` and Checking is still `₹50000.00`).  
**Class:** `BankLargeTransferTest`

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Transfer screen. From Checking. Payee Landlord. Amount `15000`. Continue | `test-TransferSummary` = `Checking → Landlord ₹15000.00` |
| 2 | Click `test-TransferConfirm` | No OTP screen. `test-BankReceipt` = `Receipt: Pending approval TX-1001` |
| 3 | Done | `test-Account-Checking` still `Checking ••0001 · ₹50000.00` |
| 4 | Activity, filter Pending | `Showing 2`. Both `test-Activity-TX-9001` and `test-Activity-TX-1001` (`Debit · Transfer to Landlord · ₹15000.00 · Pending`) |

A manager login in this **same** process then sees `Pending: 2`. Do not expect `Pending: 1` in BK-E2E-M after this scenario.

---

# BK-04 — Reject the seeded transfer

**Login?** `manager_user`. Fresh launch (so `TX-9001` is still pending).  
**Class:** `BankRejectTransferTest`  
Use this **instead of** the approve phase in BK-E2E-M. Do not approve and reject the same id.

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Open `test-Pending-TX-9001` | Summary `TX-9001 · demo_user → Landlord · ₹15000.00` |
| 2 | Leave `test-PendingRejectReason` empty. Click `test-PendingReject` | `test-BankResult` = `Result: Reason is required`. Summary still visible |
| 3 | Type `Over limit`. Click `test-PendingReject` | `Result: Rejected` |
| 4 | Back to the queue | `test-PendingCount` = `Pending: 0` |
| 5 | `test-Bank-Decisions` | `test-DecisionCount` = `Decisions: 1`. `test-Decision-D-1` = `Rejected TX-9001 by Branch Manager · Over limit` |

Demo User Checking stays `₹50000.00`. Activity `TX-9001` status becomes `Rejected`.

---

# BK-05 — Edit Demo User, delete protection, delete a created customer

**Login?** `manager_user`. Fresh launch.  
**Class:** `BankCustomerAdminTest`  
Do not combine with BK-E2E-M in one process if that test already created `asha`.

| # | Action | Exact assert |
|---|--------|--------------|
| 1 | Open `test-Customer-demo_user` | `test-Lookup-Checking` contains `₹50000.00`. `test-CustomerBalance` = `50000.00`. `test-CustomerDelete` visible |
| 2 | Click `test-CustomerDelete` | `test-BankResult` = `Result: Built-in customer cannot be deleted`. `test-Customer-demo_user` still exists |
| 3 | Create `Neel` / `neel` / `neel_pass` / balance `1000` | `Result: Customer created`. `test-Customer-neel` = `Neel · neel` |
| 4 | Create again with username `neel` | `Result: Username already exists` |
| 5 | Create with username `manager_user` | `Result: Username already exists` |
| 6 | Open `test-Customer-neel`. Click `test-CustomerDelete` | `Result: Customer deleted`. Back on the list. `test-Customer-neel` absent. `test-Customer-demo_user` still present |
| 7 | Log out. Try `neel` / `neel_pass` | `test-LoginError` contains `Invalid credentials` |

---

## 7. What these flows do not cover

Leave these out of the two E2E tests:

- Deep link `lebyy://bank`.
- Session timeout on Account → Settings.
- Paying the Mobile bill (`₹499.00`) — same screens as Electricity.
- A transfer from Savings (`test-TransferFrom-Savings`).
- Shop checkout. That is `SHOP_E2E.md`.

---

## 8. Generator checklist

- [ ] Accessibility id only.
- [ ] Fresh app launch for BK-E2E-C and for BK-E2E-M. Do not run them in one process.
- [ ] Customer login: wait for Shop, then click `test-Tab-Bank`.
- [ ] Manager login: wait for `test-ManagerHome`.
- [ ] Wait on `test-BankHome`, `test-BankTransferScreen`, `test-BankTransferConfirmScreen`, `test-BankOtpScreen`, `test-BankReceipt`, `test-ManagerHome`, `test-BankPendingDetailScreen`, `test-BankCustomerFormScreen`.
- [ ] Assert `₹48650.00` at the end of BK-E2E-C and `Receipt: Transfer completed TX-1001` / `Receipt: Bill paid TX-1002`.
- [ ] Assert `Approved TX-9001 by Branch Manager` and `Asha Rao` in BK-E2E-M.
- [ ] Type OTP as four separate fields.
- [ ] Click `test-ActivitySearchApply` and `test-CustomerSearchApply` before asserting a search.
- [ ] Leave the receipt with `test-BankDone`.
- [ ] End logged out, with `test-BankLoginGateTitle` = `Bank needs login`.
