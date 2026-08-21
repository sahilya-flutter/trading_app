# 021 Trading App — Flutter Assignment

A high-performance, production-grade Flutter trading application engineered with clean feature-oriented architecture, fixed-point financial calculations, granular reactive state management, a centralized realtime mock market feed, and local persistence.

---

## 🚀 Features

### 1. 📊 Market Overview & Live Prices Mimic
- **10 Fixed Stock Universe**: `RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`, `SBIN`, `ITC`, `LT`, `BHARTIARTL`, `AXISBANK`.
- **Centralized Realtime Feed**: Emits live price ticks from a single source of truth (`MockMarketFeed`).
- **Live Metrics**: LTP, absolute ₹ change, percentage change calculated against reference `previousClosePaise`.
- **Micro-Flash Indicator**: Visual green (up) and red (down) flash on price ticks.
- **Stress Mode Toggle**: Switch between **Normal Feed** (1-2 ticks/sec) and **Stress Mode** (50+ ticks/sec total) with smooth 60fps scrolling and zero UI freeze.

### 2. 📑 Watchlists Management
- **Multiple Watchlists**: Create, rename, delete, and switch between customized watchlists.
- **Stock Picker**: Add and remove stocks from the universe with duplicate prevention.
- **Drag-and-Drop Reordering**: Stable symbol-level key binding (`ValueKey('watchlist_row_${symbol}')`), guaranteeing that price bindings never shift across list positions.
- **Persistent State**: Watchlists and customized stock sequences survive full app restarts.

### 3. 🎫 Buy / Sell Order Ticket
- **Pre-filled Symbol**: Seamlessly opens with stock details when tapped from Market, Watchlist, or Holdings.
- **Live Execution & Value**: Dynamic order value calculation updating in real time as market LTP changes.
- **Robust Real-Time Validation**:
  - Validates positive quantities up to 3 decimal places (e.g., `10`, `1.500`, `0.250`).
  - Buy Validation: Verifies that estimated order value does not exceed available cash balance.
  - Sell Validation: Verifies that quantity does not exceed currently held units.
- **Exact Submit Execution**: Re-reads the exact authoritative current price at the moment of submission to avoid slippage or stale prices.
- **Instant Settlement**: Updates simulated wallet cash balance and recalculates weighted average holding prices.
- **Order Confirmation Receipt**: Displays detailed execution summary and persists order history.

### 4. 💼 Holdings & Realtime P&L
- **Portfolio Summary Card**: Top-level aggregate metrics for Total Current Value, Total Invested Amount, Overall P&L (₹), Overall P&L (%), and Available Cash.
- **Granular Position Tracking**: Tracks symbol, held quantity, average purchase price, live LTP, invested value, current market value, and real-time profit/loss.
- **Live Sorting**: Sort holdings by P&L (High to Low default), P&L (Low to High), Symbol (A-Z), Current Market Value, and Invested Capital. Sorting adapts dynamically as live ticks arrive.
- **Automatic Position Exit**: Positions are cleanly removed from active holdings when quantity reaches zero upon selling.

---

## 🛠️ Architecture & Technical Decisions

```
lib/
├── app/
│   ├── app.dart                   # Root MaterialApp with theme & router
│   ├── router.dart                # Declarative GoRouter configuration & bottom navigation
│   └── theme/
│       ├── app_colors.dart        # Custom trading dark-theme color tokens
│       ├── app_text_styles.dart   # Clean typography hierarchy
│       └── app_theme.dart         # Material 3 dark theme data
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # Precision multipliers, intervals, defaults
│   │   └── stock_constants.dart   # 10 universe stocks & reference prices
│   ├── utils/
│   │   ├── money_formatter.dart   # Integer paise to INR formatting & safe parsing
│   │   └── quantity_utils.dart    # Fixed-point quantity parsing & average price math
│   └── widgets/
│       ├── empty_state_view.dart  # Adaptive empty state placeholder
│       ├── error_view.dart        # Error display widget with retry action
│       ├── loading_view.dart      # Loading spinner
│       └── price_flash_widget.dart# Micro-animation container for price movements
│
├── features/
│   ├── market/
│   │   ├── data/
│   │   │   └── mock_market_feed.dart  # Centralized broadcast price tick engine
│   │   ├── domain/
│   │   │   ├── stock.dart             # Stock domain model
│   │   │   └── price_tick.dart        # Realtime price tick model with direction
│   │   └── presentation/
│   │       ├── market_providers.dart  # Granular per-symbol Riverpod selectors
│   │       ├── market_screen.dart     # Market overview & stress toggle
│   │       └── widgets/
│   │           └── market_price_row.dart
│   │
│   ├── watchlist/
│   │   ├── domain/
│   │   │   └── watchlist.dart         # Watchlist domain model
│   │   └── presentation/
│   │       ├── watchlist_providers.dart
│   │       ├── watchlist_screen.dart
│   │       └── widgets/
│   │           ├── add_stock_sheet.dart
│   │           ├── watchlist_row.dart
│   │           └── watchlist_selector_sheet.dart
│   │
│   ├── order/
│   │   ├── domain/
│   │   │   ├── order_model.dart       # Order model
│   │   │   └── order_side.dart        # Buy / Sell enum
│   │   └── presentation/
│   │       ├── order_providers.dart   # Atomic execution logic & order history
│   │       ├── order_ticket_screen.dart
│   │       └── order_confirmation_screen.dart
│   │
│   ├── holdings/
│   │   ├── domain/
│   │   │   └── holding.dart           # Holding model with fixed-point methods
│   │   └── presentation/
│   │       ├── holdings_providers.dart# Dynamic sorting & aggregate portfolio state
│   │       ├── holdings_screen.dart
│   │       └── widgets/
│   │           ├── holding_row.dart
│   │           └── portfolio_summary_card.dart
│   │
│   └── wallet/
│       ├── domain/
│       │   └── wallet_model.dart      # Wallet balance model
│       └── presentation/
│           └── wallet_providers.dart  # Ledger deduction & credit state
│
├── persistence/
│   ├── local_storage_service.dart     # Type-safe SharedPreferences wrapper with error handling
│   └── storage_keys.dart              # Persistent storage keys
│
└── main.dart                          # App entry point with async service initialization
```

### 1. Fixed-Point Financial Precision
- **Zero Floating-Point Drift**: All rupee currency values are strictly stored and computed as **integer minor units (`paise`)**. E.g., `₹152.35` is stored as `15235` paise.
- **Fractional Share Precision**: Quantities are stored as fixed units using a multiplier of `1000`, supporting up to 3 decimal places without rounding errors (e.g., `1.500` shares = `1500` units).

### 2. Single Source of Truth Market Feed
- All screens (Market Overview, Watchlist, Order Ticket, Holdings) subscribe to the exact same centralized `MockMarketFeed` instance.
- Avoids multiple timers or disparate price generators.

### 3. Granular Rebuild Performance
- Powered by `singleStockPriceProvider(symbol)` Riverpod family selectors.
- When `RELIANCE` receives a price tick, **only** the `RELIANCE` row rebuilds; all other stock rows remain untouched.
- Tested and verified under 50+ ticks/second stress mode.

### 4. Resilient Persistence
- Watchlists, cash balance, active holdings, and order history are persisted locally via `SharedPreferences`.
- Fast, non-blocking asynchronous JSON serialization.
- High-frequency market ticks remain in memory and are never persisted to disk.

---

## 📦 Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev) (Channel Stable, Flutter 3.44.6+, Dart 3.12.2+)
- **State Management**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) `^2.6.1`
- **Routing**: [go_router](https://pub.dev/packages/go_router) `^14.8.1`
- **Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences) `^2.5.3`
- **Identifiers & Formatting**: [uuid](https://pub.dev/packages/uuid) `^4.5.1`, [intl](https://pub.dev/packages/intl) `^0.20.2`

---

## 🏃 Run Instructions

### Prerequisites
- Flutter SDK installed and configured on your path (`flutter --version`).

### Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sahilya-flutter/trading_app.git
   cd trading_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```
   *(No backend setup is required — the simulated market engine runs in-memory out of the box).*

---

## 🧪 Testing & Verification

### Static Analysis
```bash
flutter analyze
```
*Result: 0 issues, 0 warnings.*

### Automated Tests
```bash
flutter test
```
*Covers:*
- Money formatter & paise parsing
- Fixed-point quantity parsing & weighted average price calculations
- Mock market feed emission & stress mode
- Holding valuation, P&L calculations, and negative price tolerance
- Atomic order execution, wallet balance deductions, and position exiting
- Watchlist CRUD, duplicate prevention, and reordering
- End-to-end widget navigation smoke test

---

## ⚡ Stress Testing Guide

1. Open the app and navigate to the **Market** tab.
2. In the top AppBar, toggle the **Stress 50+ t/s** chip.
3. Observe all 10 stocks receiving rapid tick updates with micro-flash animations.
4. Scroll the list and navigate across Watchlist and Holdings tabs to verify smooth 60fps performance without frame drops.

---

## 📝 Known Assumptions

- **Initial Simulated Balance**: Defaults to `₹1,00,000.00` (10,000,000 paise).
- **Supported Quantity Precision**: Maximum 3 decimal places (e.g. `0.001` shares).
- **Market Hours**: Simulated market feed runs continuously while the app is active.
