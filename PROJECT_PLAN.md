# 021 Trading App — Flutter Assignment Project Plan

## 1. Assignment Overview

Build a Flutter trading app with 4 core features:

1. Watchlist
2. Live Prices Mimic
3. Buy/Sell Ticket
4. Holdings

### Deadline
**Tuesday, 25 August 2026**

### Submission requirements
- Public GitHub repository containing the source code
- `README.md` with run instructions
- Short walkthrough video showing all features end-to-end
- App must run with:

```bash
flutter pub get
flutter run
```

No real backend is required. The market data must come from a **mock in-memory market feed**.

---

# 2. Important Implementation Principles

The assignment explicitly says LLM usage is allowed. The goal should therefore be to use the LLM as a coding assistant while keeping the architecture, data flow, validation, performance and edge cases deliberate and understandable.

## Non-negotiable technical principles

### A. One source of truth for prices
There must be exactly one market-data feed/service responsible for price ticks.

Do NOT create separate timers or random price generators inside individual screens/widgets.

Recommended flow:

```text
MockMarketFeed
      |
      v
Market Repository / Service
      |
      +----> Watchlist
      +----> Market Overview
      +----> Buy/Sell Ticket
      +----> Holdings / P&L
```

All screens must subscribe to the same current market state.

### B. Money must not use normal floating-point arithmetic
For rupee values, use integer minor units such as paise.

Example:

```text
₹152.35 -> 15235 paise
```

Recommended rule:

```dart
int pricePaise;
```

Calculations:

```text
orderValuePaise = quantityInMinorUnits * pricePaise
```

For the quantity, support fractional quantities without floating-point drift. A safe approach is to represent quantity as a fixed precision integer (for example quantity x 1000) and explicitly define the supported quantity precision.

Formatting should happen only at the UI boundary.

### C. Price updates must be granular
A tick for `TCS` should not force the entire app/list to rebuild.

Use per-symbol state/selectors so that:

```text
RELIANCE tick -> RELIANCE widgets update
TCS widgets -> unchanged
INFY widgets -> unchanged
```

Avoid a single giant `setState()` for the whole screen.

### D. Reordering must never break symbol-to-price binding
Watchlist rows should identify the stock by immutable symbol/key, not by list index.

Bad:

```text
price = prices[index]
```

Good:

```text
price = prices[stock.symbol]
```

### E. The feed continues when a screen is not visible
The market feed should live above individual screens and continue running while the user navigates.

When the user returns to a screen, it should read the latest current price from the shared market state.

### F. Persistence should happen at the domain boundary
Persist:
- watchlists
- wallet balance
- holdings
- order history

Do not continuously write every market tick to local storage.

Only persistent domain changes such as adding/removing/reordering watchlist stocks, executing orders, changing balance, or updating holdings should trigger persistence.

---

# 3. Recommended Architecture

Use a clean, feature-oriented architecture that is simple enough to finish quickly but still demonstrates professional engineering.

Recommended state management: **Riverpod**.

Recommended local persistence: **SharedPreferences** with JSON serialization for this assignment. Market ticks stay in memory and are never persisted.

Recommended navigation: **go_router**.

Suggested packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  shared_preferences: ^2.5.3
  go_router: ^16.0.0
  uuid: ^4.5.1
```

Version numbers may be adjusted to the versions compatible with the installed stable Flutter SDK.

Do not add packages unless they solve a real requirement.

---

# 4. Suggested Folder Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       └── app_text_styles.dart
│
├── core/
│   ├── constants/
│   │   ├── stock_constants.dart
│   │   └── app_constants.dart
│   ├── extensions/
│   ├── utils/
│   │   ├── money_formatter.dart
│   │   ├── quantity_parser.dart
│   │   └── debounce.dart
│   └── widgets/
│       ├── error_view.dart
│       ├── empty_state.dart
│       ├── loading_view.dart
│       └── price_flash.dart
│
├── features/
│   ├── market/
│   │   ├── data/
│   │   │   └── mock_market_feed.dart
│   │   ├── domain/
│   │   │   ├── stock.dart
│   │   │   └── price_tick.dart
│   │   └── presentation/
│   │       ├── market_screen.dart
│   │       ├── market_providers.dart
│   │       └── widgets/
│   │           └── market_price_row.dart
│   │
│   ├── watchlist/
│   │   ├── data/
│   │   │   └── watchlist_repository.dart
│   │   ├── domain/
│   │   │   └── watchlist.dart
│   │   └── presentation/
│   │       ├── watchlist_screen.dart
│   │       ├── watchlist_providers.dart
│   │       └── widgets/
│   │           ├── watchlist_row.dart
│   │           ├── watchlist_picker.dart
│   │           └── watchlist_selector.dart
│   │
│   ├── order/
│   │   ├── data/
│   │   │   └── order_repository.dart
│   │   ├── domain/
│   │   │   ├── order.dart
│   │   │   └── order_side.dart
│   │   └── presentation/
│   │       ├── order_ticket_screen.dart
│   │       ├── order_providers.dart
│   │       └── widgets/
│   │
│   ├── holdings/
│   │   ├── data/
│   │   │   └── holdings_repository.dart
│   │   ├── domain/
│   │   │   └── holding.dart
│   │   └── presentation/
│   │       ├── holdings_screen.dart
│   │       ├── holdings_providers.dart
│   │       └── widgets/
│   │           └── holding_row.dart
│   │
│   └── wallet/
│       ├── data/
│       │   └── wallet_repository.dart
│       ├── domain/
│       │   └── wallet.dart
│       └── presentation/
│           └── wallet_providers.dart
│
├── persistence/
│   ├── local_storage.dart
│   └── storage_keys.dart
│
└── main.dart
```

The structure can be simplified where useful, but feature responsibilities should remain separated.

---

# 5. Fixed Stock Universe

Use these exact 10 symbols everywhere:

```text
RELIANCE
TCS
INFY
HDFCBANK
ICICIBANK
SBIN
ITC
LT
BHARTIARTL
AXISBANK
```

Choose reasonable starting prices and keep them deterministic so testing is repeatable.

Example starting prices (illustrative only):

```text
RELIANCE     ₹1,420.00
TCS          ₹3,980.00
INFY         ₹1,720.00
HDFCBANK     ₹1,760.00
ICICIBANK    ₹1,320.00
SBIN         ₹820.00
ITC          ₹470.00
LT           ₹3,650.00
BHARTIARTL   ₹1,820.00
AXISBANK     ₹1,260.00
```

The exact values are not important; realistic behavior and correct calculations are.

---

# 6. Domain Models

## Stock

```text
symbol
companyName (optional)
startingPricePaise
```

## PriceTick

```text
symbol
ltpPaise
previousLtpPaise
deltaPaise
timestamp
```

## Watchlist

```text
id
name
symbols: List<String>
createdAt
```

## Holding

```text
symbol
quantityUnits
averagePricePaise
```

`quantityUnits` should use fixed precision, e.g. 1000 units = 1.000 quantity.

## Order

```text
id
symbol
side (buy/sell)
quantityUnits
executionPricePaise
orderValuePaise
timestamp
status
```

## Wallet

```text
balancePaise
```

Start with a reasonable simulated balance, for example:

```text
₹1,00,000.00
```

The exact starting balance can be changed in a constant.

---

# 7. Mock Market Feed Design

This is one of the most important parts of the assignment.

## Requirements

- continuously emit ticks
- support all 10 stocks
- configurable tick rate
- realistic small price movements
- single source of truth
- safe at 50+ ticks/sec overall
- current prices remain available when navigating

## Recommended design

Create a singleton/service such as:

```dart
class MockMarketFeed {
  Stream<PriceTick> get ticks;

  int ticksPerSecondPerStock;

  void start();
  void stop();

  int getLtpPaise(String symbol);
}
```

However, avoid creating 10 independent Flutter timers if a centralized scheduler is cleaner. A single timer/loop can update a selected set of symbols per cycle.

The feed should maintain:

```text
Map<String, int> currentPricesPaise
```

and emit only the changed symbol on every tick.

## Price movement

Use a small randomized delta, for example a bounded basis-point move.

Pseudo behavior:

```text
newPrice = oldPrice + smallRandomDelta
```

Ensure:
- price never becomes zero/negative
- no huge unrealistic jumps
- deterministic initial prices
- randomized ongoing movement

## Update flash

Each row should know whether the latest tick was:

```text
UP
DOWN
NO CHANGE
```

Display a brief visual flash without keeping long-lived animations running unnecessarily.

---

# 8. Performance Strategy

The assignment specifically tests behavior under load.

## Required strategy

- shared market feed
- symbol-keyed price state
- granular providers/selectors
- const widgets wherever possible
- avoid rebuilding the whole list on every tick
- use `ListView.builder`
- keep business logic out of build methods
- do not write ticks to persistent storage
- do not use `setState()` at a page/root level for every tick

## Stress test target

The implementation must remain usable at:

```text
5+ ticks/second per stock
10 stocks
50+ ticks/second total
```

During stress testing:
- scrolling should remain responsive
- only affected cells should visibly update
- navigation should remain responsive
- no unbounded memory growth

---

# 9. Feature 1 — Watchlist

## UI

Provide a way to switch between multiple watchlists.

Suggested layout:

```text
Watchlists
[ Default ▼ ]

RELIANCE   ₹1,421.35   +₹2.15   +0.15%
TCS        ₹3,975.10   -₹4.20   -0.11%
INFY       ₹1,726.50   +₹6.50   +0.38%

[ + Add Stock ]
```

## Required actions

- create watchlist
- rename watchlist
- delete watchlist
- add stock
- reorder using drag
- remove stock
- tap stock -> open Buy/Sell ticket

## Important edge cases

### Empty watchlist
Show a clear empty state.

### Duplicate stock
Prefer preventing duplicate symbols inside the same watchlist.

### Shared stock across watchlists
Both watchlists must bind to the same `symbol` price stream.

### Reordering
Use stable symbol keys. Never bind prices using list position.

### Removing stock
Once removed, no row/widget should remain subscribed through the watchlist UI.

---

# 10. Feature 2 — Live Prices Mimic

This should be the market overview screen.

For each stock show:

```text
Symbol
LTP
Change ₹
Change %
Update direction / flash
```

The screen must always use the same market feed used by watchlists, tickets and holdings.

## Change calculation

Use a clearly defined reference price.

Example:

```text
changePaise = ltpPaise - previousClosePaise
changePercent = changePaise / previousClosePaise * 100
```

Do not confuse the last tick with the daily change reference.

Store `previousClosePaise` separately from `ltpPaise`.

---

# 11. Feature 3 — Buy/Sell Ticket

The ticket opens with a prefilled symbol when launched from a watchlist or holding.

## UI fields

```text
Stock: RELIANCE
Side: [ Buy ] [ Sell ]
Quantity: [ 10.000 ]
LTP: ₹1,421.35
Estimated Order Value: ₹14,213.50
Available Balance: ₹1,00,000.00

[ Submit Order ]
```

## Live behavior

When LTP changes:

```text
LTP updates
     |
     v
Projected order value updates
```

The order execution price must be re-read at the exact submit moment.

Do not trust the projected value calculated earlier.

## Buy validation

Block submit if:

- quantity is empty
- quantity is zero
- quantity is negative
- quantity is invalid
- quantity exceeds supported precision
- order value > available balance

## Sell validation

Block submit if:

- quantity is empty
- quantity is zero
- quantity is negative
- invalid quantity
- quantity > currently held quantity

## Buy execution

On success:

```text
executionPrice = currentLtp
orderValue = quantity * executionPrice
wallet -= orderValue
```

Holding update:

```text
newQty = oldQty + boughtQty

newAveragePrice =
    ((oldQty * oldAvgPrice) + (boughtQty * executionPrice))
    / newQty
```

All math must use fixed-point integer units.

## Sell execution

On success:

```text
executionPrice = currentLtp
orderValue = quantity * executionPrice
holdingQty -= soldQty
wallet += orderValue
```

If quantity becomes zero, remove the holding.

Unless the assignment explicitly asks otherwise, keep the original average cost of remaining shares after a sell.

## Confirmation

After success, navigate to a confirmation screen showing:

```text
Order successful
BUY / SELL
Symbol
Quantity
Execution Price
Order Value
Time
```

---

# 12. Feature 4 — Holdings

Show all non-zero holdings.

Each row:

```text
Symbol
Quantity
Average Cost
LTP
Current Value
P&L ₹
P&L %
```

## Calculations

```text
investedValue = quantity * averageCost
currentValue = quantity * ltp
pnl = currentValue - investedValue
pnlPercent = pnl / investedValue * 100
```

Use the same fixed-point arithmetic strategy.

## Summary

At the top:

```text
Total Invested
Current Value
Total P&L ₹
Total P&L %
```

The aggregate summary must be calculated from the same holding rows so it always matches them.

## Sorting

Support:

- P&L
- Symbol
- Current value

Default:

```text
P&L descending
```

When live prices change, the sorting must remain correct.

Example:

```text
Holding A P&L = -₹10
Holding B P&L = +₹5

B should appear above A.

If A later becomes +₹8,
A must move above B when sorting by P&L descending.
```

---

# 13. Persistence Design

Use local persistence for domain state only.

Suggested storage keys:

```text
watchlists
wallet
holdings
orders
```

Example JSON structure:

```json
{
  "watchlists": [
    {
      "id": "default",
      "name": "My Watchlist",
      "symbols": ["RELIANCE", "TCS", "INFY"]
    }
  ]
}
```

On app startup:

```text
load persistent data
        |
        v
initialize domain state
        |
        v
start / connect to market feed
```

Market prices themselves should NOT be restored from storage as authoritative state. The running feed owns current LTP.

---

# 14. Navigation Proposal

Recommended top-level navigation:

```text
Market | Watchlists | Holdings
```

The Buy/Sell ticket can be a separate route.

Suggested route names:

```text
/
/market
/watchlists
/watchlists/:watchlistId
/holdings
/order?symbol=RELIANCE
/order/confirmation
```

The exact route design can be simplified.

---

# 15. UI Design Direction

The assignment asks for thoughtful UI for dense data.

Aim for a modern trading-terminal feel without over-designing.

## Recommended visual hierarchy

- dark or neutral trading-friendly theme
- strong numeric typography
- compact rows
- consistent decimal formatting
- green for positive
- red for negative
- muted secondary text
- sticky/visible portfolio summary
- clear empty states
- clear inline validation errors

Do not spend most of the deadline on decorative animations. Prioritize correctness and performance.

---

# 16. Error and Edge Case Checklist

Handle at minimum:

- no watchlists yet
- empty watchlist
- duplicate stock add
- deleting the active watchlist
- renaming with blank name
- deleting the last watchlist
- invalid quantity
- zero quantity
- negative quantity
- fractional quantity beyond supported precision
- buy balance insufficient
- sell quantity greater than holding
- selling final quantity removes holding
- order execution during a price tick
- storage unavailable/corrupt JSON
- missing stock symbol in persisted data
- navigation while feed is running
- stress tick rate

A corrupted local JSON record should not crash the app. Fail safely and recover to a valid empty/default state where reasonable.

---

# 17. Testing Plan

Even if time is limited, write focused tests for the high-risk logic.

## Unit tests

### Money/quantity
- integer price calculations
- fractional quantity calculations
- no visible floating drift

### Holdings
- buy creates holding
- second buy recalculates weighted average
- partial sell reduces quantity
- full sell removes holding

### Wallet
- buy deducts correct amount
- sell credits correct amount
- insufficient balance blocked

### Watchlists
- create
- rename
- delete
- add
- remove
- reorder
- duplicate prevention

### Market feed
- emits ticks
- only valid symbols emitted
- prices remain positive
- configurable tick rate works

## Widget tests

At minimum:

- empty watchlist state
- order validation error
- buy success flow
- sell insufficient quantity
- holdings summary

## Manual stress test

Run the app with a high tick rate equivalent to:

```text
5+ ticks/sec/stock
50+ ticks/sec overall
```

Verify smooth scrolling and navigation.

---

# 18. Suggested Implementation Phases

The assignment should be developed in phases. Do not attempt all four features at once.

## Phase 0 — Project Bootstrap

Goal: create a clean compilable Flutter project.

Tasks:
- verify stable Flutter SDK
- create project
- add only required dependencies
- configure analysis/lints
- create folder structure
- create app theme
- create routing shell
- create placeholder screens

Acceptance:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

must all work.

---

## Phase 1 — Core Domain + Persistence

Goal: establish the data models and local storage before UI complexity.

Tasks:
- Stock constants
- PriceTick
- Watchlist
- Holding
- Order
- Wallet
- fixed-point money helpers
- quantity parser/formatter
- SharedPreferences repository
- JSON serialization/deserialization

Acceptance:
- data can be saved
- data can be loaded after restart
- invalid/corrupt records do not crash the app

---

## Phase 2 — Mock Market Feed

Goal: build the central realtime engine.

Tasks:
- deterministic starting prices
- previous-close values
- centralized current price map
- tick generation
- configurable stress tick rate
- stream of symbol-specific ticks
- current price lookup
- update direction

Acceptance:
- all 10 stocks receive updates
- no negative prices
- tick stream is continuous
- changing one stock does not rebuild unrelated widgets

---

## Phase 3 — Live Market Screen

Goal: prove that the market feed and performance design work before connecting trading logic.

Tasks:
- market overview list
- per-row live price binding
- change / change %
- update flash
- scrolling
- high-frequency stress test

Acceptance:
- 10 stocks visible
- rows update live
- only affected rows update visibly
- scrolling remains smooth at stress rate

---

## Phase 4 — Watchlists

Goal: implement complete watchlist CRUD and persistence.

Tasks:
- multiple watchlists
- create
- rename
- delete
- stock picker
- add/remove
- drag reorder
- empty state
- persistence
- open order ticket

Acceptance:
- restart restores watchlists
- same stock in different watchlists gets identical LTP
- reorder never mismatches prices
- removed stocks disappear after restart

---

## Phase 5 — Wallet + Buy/Sell Ticket

Goal: implement simulated order execution correctly.

Tasks:
- wallet state
- order ticket
- buy/sell selector
- quantity validation
- live LTP
- live projected value
- balance validation
- holding validation
- exact submit-time execution
- order history
- confirmation screen
- persistence

Acceptance:
- valid Buy succeeds
- valid Sell succeeds
- invalid orders are blocked
- exact execution value is used
- wallet and orders persist

---

## Phase 6 — Holdings + Live P&L

Goal: complete portfolio behavior.

Tasks:
- holdings list
- live LTP
- current value
- P&L
- P&L %
- aggregate summary
- sorting
- automatic removal at zero quantity
- open ticket from row

Acceptance:
- all values update from live prices
- aggregate equals rows
- sorting changes correctly as prices move
- all 10 holdings remain responsive under stress

---

## Phase 7 — Integration + Edge Cases

Goal: test complete user journeys.

Run these journeys exactly:

### Journey A — Watchlist persistence
1. create watchlist
2. add 3 stocks
3. reorder them
4. remove 1 stock
5. close app
6. relaunch
7. verify state

### Journey B — Shared prices
1. add RELIANCE to Watchlist A
2. add RELIANCE to Watchlist B
3. observe live prices
4. verify both are identical

### Journey C — Buy
1. open RELIANCE ticket
2. enter quantity
3. wait for LTP to change
4. verify projected value changes
5. submit
6. verify wallet deduction
7. verify holding
8. verify order history

### Journey D — Sell
1. open existing holding
2. enter smaller quantity
3. submit
4. verify holding quantity decreases
5. verify wallet increases

### Journey E — Validation
- buy above available balance
- sell above holding quantity
- zero quantity
- negative quantity
- invalid decimal quantity

### Journey F — Stress
- enable 50+ ticks/sec total
- scroll market screen
- navigate between all screens
- verify no obvious frame drops or freezing

---

## Phase 8 — Polish + Submission

Goal: make the repository submission-ready.

Tasks:
- improve dense-data UI
- remove debug prints
- remove dead code
- run formatter
- run analyzer
- run tests
- update README
- add architecture explanation
- add feature screenshots if useful
- create walkthrough video
- clean Git history
- push public repository

Required checks:

```bash
flutter format --set-exit-if-changed .
flutter analyze
flutter test
flutter pub get
flutter run
```

Use the exact command that matches the installed Flutter version for formatting if necessary.

---

# 19. Deadline Plan — 21 to 25 August 2026

The deadline is **25 August 2026**, so the work should be front-loaded.

## 21 Aug — Foundation + Market Feed

Target:
- project bootstrap
- architecture
- models
- fixed-point money utilities
- persistence base
- mock market feed
- initial market screen

End-of-day milestone:

```text
App runs
10 stocks visible
Prices update continuously
```

## 22 Aug — Watchlist

Target:
- multiple watchlists
- create/rename/delete
- add/remove
- reorder
- persistence
- watchlist -> order navigation

End-of-day milestone:

```text
Watchlist feature complete and survives restart
```

## 23 Aug — Orders + Wallet + Holdings

Target:
- Buy/Sell ticket
- validation
- wallet
- order history
- holding calculations
- persistence
- confirmation

End-of-day milestone:

```text
Buy and Sell flows work end-to-end
```

## 24 Aug — Realtime P&L + Performance + Testing

Target:
- live holdings P&L
- sorting
- aggregate summary
- stress tick mode
- rebuild optimization
- unit/widget tests
- edge cases

End-of-day milestone:

```text
All acceptance scenarios pass
```

## 25 Aug — Final Submission

Target:
- UI polish
- README
- final analyzer/test run
- GitHub push
- walkthrough recording
- final end-to-end verification

Do not schedule major architectural changes on the submission day.

---

# 20. Git Commit Strategy

The assignment mentions clear commit history. Keep commits small and meaningful.

Suggested sequence:

```text
chore: bootstrap flutter trading app
feat: add domain models and fixed point money handling
feat: add local persistence layer
feat: add centralized mock market feed
feat: add live market overview
feat: add watchlist management
feat: persist watchlists across restarts
feat: add buy sell ticket
feat: add wallet and order execution
feat: add holdings and live pnl
feat: add holdings sorting
perf: optimize per-symbol market updates
fix: handle order validation edge cases
test: add trading domain tests
docs: add setup and architecture readme
chore: prepare assignment submission
```

Avoid one giant commit containing the entire project.

---

# 21. README.md Requirements

The final README should contain:

## Project title

`021 Trading App — Flutter Assignment`

## Features

Short explanation of all four features.

## Tech stack

- Flutter
- Dart
- Riverpod
- SharedPreferences
- go_router

## Architecture

Explain the feature-oriented structure and central market feed.

## Run instructions

```bash
flutter pub get
flutter run
```

Mention that no backend setup is required.

## Mock market feed

Explain:
- centralized feed
- tick generation
- configurable tick rate
- current prices held in memory

## Money handling

Explain that rupee money is handled using integer minor units to avoid floating-point precision issues.

## Testing

Show:

```bash
flutter analyze
flutter test
```

## Stress test

Explain how the high tick-rate mode can be enabled and what was verified.

## Known assumptions

Document any deliberate assumptions, such as supported fractional quantity precision and starting balance.

---

# 22. Walkthrough Video Script

Keep the final video short and practical.

Suggested order:

### 1. Launch
Show app opening and live market prices.

### 2. Live market feed
Show several price updates and the green/red flash.

### 3. Watchlist
- create a watchlist
- add stocks
- reorder
- remove a stock
- create a second watchlist with the same stock
- demonstrate identical live prices

### 4. Buy
- open ticket from watchlist
- show live LTP
- enter quantity
- show projected value update
- submit
- show confirmation

### 5. Holdings
- show newly created holding
- show live P&L
- change sort

### 6. Sell
- open ticket from holdings
- sell part of the position
- show updated balance and quantity

### 7. Persistence
- restart app
- demonstrate watchlist/holdings/orders are restored

### 8. Stress behavior
Show the configurable high tick-rate setting and briefly demonstrate that navigation and scrolling remain responsive.

---

# 23. Claude / Antigravity Master Prompt

Use the following prompt as the master instruction for the coding agent.

---

## MASTER PROMPT

You are helping me complete a Flutter take-home assignment named **021 Trading App**. The assignment allows use of any LLM.

The deadline is **25 August 2026**.

I want the project developed in **strict implementation phases**, not as one giant code dump.

### Assignment requirements

Build a Flutter trading app with these four features:

1. Watchlist
2. Live Prices Mimic
3. Buy/Sell Ticket
4. Holdings

Use these 10 stocks everywhere:

- RELIANCE
- TCS
- INFY
- HDFCBANK
- ICICIBANK
- SBIN
- ITC
- LT
- BHARTIARTL
- AXISBANK

No real backend is needed. Implement a mock market-data feed.

The final app must run with:

```bash
flutter pub get
flutter run
```

### Engineering goals

Prioritize:

- clean readable code
- sensible architecture
- correct realtime behavior
- fixed-point money calculations
- robust validation
- error/edge-case handling
- good UI for dense data
- smooth behavior under 50+ ticks/second overall
- clear Git commits

### Required architecture decisions

1. Use a centralized mock market feed as the single source of price truth.
2. Do not create separate price timers per screen.
3. Use symbol-keyed price state so reordering cannot bind the wrong price to a row.
4. Keep the feed alive across navigation.
5. Use granular state selectors/providers so only affected widgets rebuild.
6. Store rupee money as integer paise, not double.
7. Represent fractional quantity with fixed precision rather than relying on floating-point arithmetic.
8. Persist watchlists, wallet, holdings and order history.
9. Never persist every market tick.
10. On order submission, read the current LTP again and execute at that exact value.

### Recommended stack

- Flutter stable
- Dart
- Riverpod
- SharedPreferences
- go_router

Use compatible package versions for the installed stable Flutter SDK.

### Required development workflow

Work phase-by-phase.

At the beginning of each phase:

1. Inspect the current codebase.
2. State the phase goal.
3. List the files that need to be created or changed.
4. Implement only that phase.
5. Run formatting/analyzer/tests where applicable.
6. Fix issues before moving forward.
7. Summarize what is complete and what remains.

Do NOT silently redesign unrelated completed phases.

Do NOT create unnecessary dependencies.

Do NOT generate fake backend/network code.

### Phase order

Phase 0: Project bootstrap
Phase 1: Domain models + persistence
Phase 2: Central mock market feed
Phase 3: Live market screen
Phase 4: Watchlists
Phase 5: Wallet + Buy/Sell ticket
Phase 6: Holdings + live P&L
Phase 7: Integration + edge cases + stress testing
Phase 8: Final polish + README + submission preparation

### Acceptance criteria

The implementation must satisfy all of these scenarios:

#### Watchlist
- restart restores watchlists and stocks
- reorder keeps correct live price binding
- removed stock stops appearing and remains removed after restart
- same stock in multiple watchlists has identical live LTP
- empty watchlist shows an empty state
- tapping row opens prefilled Buy/Sell ticket

#### Market feed
- all 10 stocks update continuously
- each row shows symbol, LTP, change and change %
- update flash differs for up/down
- configurable stress rate works
- only affected cells visibly update
- scrolling remains smooth at 50+ ticks/sec overall
- returning to a screen shows current prices, not stale snapshots

#### Buy/Sell
- stock is prefilled when opened from watchlist/holdings
- live LTP updates while ticket is open
- projected value updates with LTP
- insufficient balance blocks Buy
- insufficient holding blocks Sell
- zero/negative/invalid quantities are blocked
- exact current LTP is used at submit time
- successful Buy deducts wallet and updates holding average price
- successful Sell reduces holding and credits wallet
- order history persists
- confirmation screen appears

#### Holdings
- row contains symbol, qty, avg cost, LTP, current value, P&L ₹ and P&L %
- P&L updates live
- summary equals sum of rows
- sorting by P&L, symbol and current value works
- default sorting is P&L descending
- zero quantity removes holding
- all 10 holdings remain responsive under load

### Performance requirements

The mock feed must support at least:

```text
5+ ticks/sec/stock
10 stocks
50+ ticks/sec total
```

Use symbol-level selectors and avoid rebuilding the entire list on every tick.

### Money precision requirement

Use integer paise for money.

Example:

```text
₹152.35 -> 15235
```

Never use double for persisted money or critical order calculations.

### UI requirement

Create a clean, professional dense-data trading interface.

Prioritize:
- readability
- consistent decimal formatting
- clear positive/negative colors
- compact rows
- obvious actions
- clear empty states
- inline errors

Do not over-invest in decoration.

### Testing requirement

Write focused unit/widget tests for:

- money calculations
- quantity parsing
- buy/sell execution
- weighted average cost
- balance validation
- holding quantity validation
- watchlist CRUD
- persistence
- major empty/error states

Also perform manual stress testing.

### Final submission requirement

Before declaring the project complete, verify:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Then prepare:

- clean public GitHub repository
- README.md
- architecture explanation
- run instructions
- assumptions
- test/stress instructions
- walkthrough video checklist

### Critical instruction

Do not optimize for speed of code generation. Optimize for a submission that is easy to review and demonstrates strong engineering judgment.

When unsure between two implementations, prefer the simpler implementation that preserves the required realtime behavior, correctness and testability.

---

# 24. Agent Behavior Rules

When using Claude Code / Antigravity / Cursor:

1. First read the current project before modifying it.
2. Do not overwrite working features unnecessarily.
3. Preserve the existing architecture unless there is a strong reason to change it.
4. After each major phase run `flutter analyze`.
5. Add tests alongside risky business logic.
6. Keep commits small.
7. Explain important tradeoffs.
8. Never use list index as the identity of a stock.
9. Never use a per-screen random price generator.
10. Never calculate critical money values with `double`.
11. Never persist every price tick.
12. Never block order submission using the previously displayed LTP; re-read current price at submit time.

---

# 25. Definition of Done

The assignment is ready for submission only when all are true:

- [ ] App builds and runs from a clean checkout
- [ ] No backend setup required
- [ ] All 10 stocks are implemented
- [ ] Single source of market truth exists
- [ ] Live prices update continuously
- [ ] Watchlists work and persist
- [ ] Reordering is correct
- [ ] Buy/Sell works with validation
- [ ] Money calculations are fixed-point
- [ ] Wallet persists
- [ ] Orders persist
- [ ] Holdings persist
- [ ] Live P&L works
- [ ] Holdings sorting works
- [ ] Empty/error states work
- [ ] 50+ ticks/sec stress test is acceptable
- [ ] No obvious jank under scrolling/navigation
- [ ] Tests pass
- [ ] Analyzer passes
- [ ] README is complete
- [ ] Git history is understandable
- [ ] Walkthrough video is recorded
- [ ] Public GitHub repository is ready

---

# 26. Final Submission Checklist

Before sending the GitHub link, verify:

```text
Repository: PUBLIC
README.md: PRESENT
Source code: PRESENT
flutter pub get: PASS
flutter analyze: PASS
flutter test: PASS
flutter run: PASS
Walkthrough video: READY
All 4 features demonstrated: YES
Persistence demonstrated: YES
Stress behavior demonstrated: YES
```

The safest strategy is to reach a fully working end-to-end version by **24 August**, and use **25 August only for final verification, polish and submission**.
