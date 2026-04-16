# OpTracker - Smart Payment Tracker

A Flutter Android app that automatically tracks your online payments by reading notifications from payment apps. Features a polished shadcn-style UI with smooth animations and comprehensive budget management.

## Features

### Payment Tracking
- Auto-detects payments from notifications (PayPal, Venmo, Cash App, Google Pay, Zelle, bank apps)
- Parses amount, merchant/recipient, and transaction type from notification text
- Manual transaction entry with category selection
- Transaction history with search, filters, and date grouping

### User Management
- **Google Sign-In** for cloud-synced experience
- **Local account** with Username + PIN or Pattern lock (no Google account required)
- Multi-user support on the same device
- Secure PIN/pattern hashing with SHA-256

### Budget Control
- Set budgets per category (weekly, monthly, yearly)
- Visual progress bars with animated fill
- Spending alerts when approaching budget limits
- AI-powered budget suggestions based on spending patterns
- 50/30/20 rule distribution recommendations

### Dashboard
- Spending overview with income, balance, and available funds
- Interactive bar charts for daily spending trends
- Pie chart breakdown by category
- Recent transactions feed
- Period selector (Daily / Weekly / Monthly)

### Design
- Shadcn/Tailwind-inspired design system (zinc neutrals + indigo accent)
- Light and dark theme support
- Smooth page transitions and micro-interactions
- Staggered list animations
- Animated budget progress bars
- Shimmer loading states

## Tech Stack

- **Flutter 3.16+** with Material 3
- **Riverpod** for state management
- **GoRouter** for navigation with auth-aware redirects
- **SQLite (sqflite)** for local data persistence
- **fl_chart** for interactive charts
- **flutter_animate** for animations
- **Google Fonts (Inter)** for typography
- **notification_listener_service** for Android notification access

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── theme/                   # Colors, typography, spacing, theme
│   ├── constants/               # Enums and constants
│   ├── utils/                   # Currency formatter, date helpers
│   ├── services/                # Auth, notification, budget suggestion
│   ├── providers/               # Riverpod providers
│   └── router/                  # GoRouter configuration
├── data/
│   ├── models/                  # User, Transaction, Budget, NotificationLog
│   ├── database/                # SQLite database helper
│   └── repositories/            # Data access layer
├── features/
│   ├── auth/                    # Welcome, login, PIN, pattern screens
│   ├── dashboard/               # Dashboard with charts and overview
│   ├── transactions/            # Transaction list, detail, add
│   ├── budget/                  # Budget management and suggestions
│   └── settings/                # App settings and profile
└── widgets/
    └── common/                  # Reusable UI components
```

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on Android device/emulator
flutter run

# Build release APK
flutter build apk --release
```

## Permissions

The app requires **Notification Access** permission to auto-detect payments. Users are guided to grant this in Android Settings > Notification Access.
