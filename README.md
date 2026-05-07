# ✈️ TravelMate — Smart Travel Itinerary Planner & Expense Splitter

A Flutter mobile application that helps groups of friends and students plan trips, organize daily itineraries, split shared expenses, and track payments — with full offline support.

---

## 📱 Screenshots & Screens

| Screen | Description |
|---|---|
| Home Screen | List of all trips with search |
| Trip Creation | Create trip with participants |
| Trip Dashboard | Stats, itinerary, expenses, balances |
| Expense Entry | Add & split expenses |
| Itinerary Planner | Day-wise activity planning |
| Search & Filter | Filter trips and expenses |

---

## 🚀 Features

### Trip Management
- Create trips with name, destination, and date range
- Add multiple participants per trip
- View trip duration and summary at a glance

### Itinerary Planning
- Add daily activities with optional time
- Day-wise grouped itinerary view
- Activities scoped to trip date range only

### Expense Tracking
- Log expenses with amount, description, and category
- Specify who paid and who shares the cost
- Categories: Food, Transport, Stay, Activity, Other

### Expense Splitting
- Automatically calculates each person's share
- Shows net balance per participant (who owes, who is owed)
- Greedy settlement algorithm minimizes number of transactions
- Example: *"Alice pays Bob ₹450"*

### Trip Dashboard
- Total expense overview
- Participant count and trip duration
- Pie chart breakdown of expenses by person
- Tabbed view: Overview | Itinerary | Expenses | Balances

### Search & Filter
- Search trips by name in real-time
- Filter trips: All / Upcoming / Active / Past
- Filter expenses by participant or date range

### Offline-First
- All data stored locally using Hive database
- Full functionality without internet connection
- Sync stub ready for future backend integration

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Local Storage | Hive + hive_flutter |
| Charts | fl_chart |
| Typography | google_fonts |
| Animations | flutter_animate |
| ID Generation | uuid |
| Date Formatting | intl |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, Hive init, providers
│
├── models/                      # Data models (Hive annotated)
│   ├── trip_model.dart
│   ├── participant_model.dart
│   ├── itinerary_item_model.dart
│   └── expense_model.dart
│
├── providers/                   # State management (ChangeNotifier)
│   ├── trip_provider.dart
│   ├── participant_provider.dart
│   ├── itinerary_provider.dart
│   └── expense_provider.dart
│
├── screens/                     # Full-page UI screens
│   ├── home_screen.dart
│   ├── trip_creation_screen.dart
│   ├── trip_dashboard_screen.dart
│   ├── expense_entry_screen.dart
│   ├── itinerary_planning_screen.dart
│   └── search_filter_screen.dart
│
├── widgets/                     # Reusable UI components
│   ├── trip_card.dart
│   ├── participant_avatar.dart
│   ├── expense_tile.dart
│   ├── balance_chip.dart
│   ├── itinerary_tile.dart
│   ├── stat_card.dart
│   └── gradient_card.dart
│
├── utils/                       # Helpers & configuration
│   ├── app_theme.dart
│   ├── constants.dart
│   └── formatters.dart
│
└── services/
    └── sync_service.dart        # Sync stub for future backend
```

---

## ⚙️ Installation & Setup

### Prerequisites
- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0`
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/your-username/travel_planner.git
cd travel_planner
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Generate Hive adapters**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**4. Run the app**
```bash
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0
  fl_chart: ^0.66.1
  intl: ^0.19.0
  uuid: ^4.3.3

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

---

## 🗺️ Navigation Routes

| Route | Screen |
|---|---|
| `/` | HomeScreen |
| `/create-trip` | TripCreationScreen |
| `/dashboard` | TripDashboardScreen |
| `/add-expense` | ExpenseEntryScreen |
| `/add-itinerary` | ItineraryPlanningScreen |
| `/search` | SearchAndFilterScreen |

---

## 💡 How Expense Splitting Works

### Balance Calculation
1. For each expense, the payer gets **credit** for the full amount
2. Each person in the split **owes** `amount ÷ number of people`
3. Net balance = total paid − total owed
   - **Positive** = others owe this person
   - **Negative** = this person owes others

### Settlement Algorithm
Uses a **greedy algorithm** to minimize transactions:
1. Separate participants into debtors and creditors
2. Repeatedly match the largest debtor with the largest creditor
3. Record the transaction and reduce balances
4. Repeat until all balances are zero

**Example:**
```
Alice paid ₹900 for dinner (split 3 ways)
Bob paid ₹300 for snacks (split 3 ways)
Charlie paid ₹0

Result:
  Alice is owed ₹600
  Bob is owed ₹0
  Charlie owes ₹600

Settlement: Charlie pays Alice ₹600
```

---

## 🎨 Design System

```dart
// Color Palette
primary:    Color(0xFF1A1A2E)   // Deep navy
secondary:  Color(0xFF16213E)   // Darker navy
accent:     Color(0xFF0F3460)   // Blue
highlight:  Color(0xFFE94560)   // Coral red
success:    Color(0xFF4CAF50)   // Green
warning:    Color(0xFFFF9800)   // Orange
cardBg:     Color(0xFF1E1E3A)   // Card background

// Fonts
Display:  Playfair Display  (headings)
Body:     DM Sans           (general text)
Numbers:  JetBrains Mono    (amounts & figures)
```

---

## ✅ Validation Rules

| Field | Rule |
|---|---|
| Trip Name | Required, minimum 3 characters |
| Destination | Required |
| End Date | Must be on or after start date |
| Participants | At least 1 required |
| Expense Amount | Required, must be greater than 0 |
| Paid By | Must select a participant |
| Split Among | At least 1 participant required |
| Activity | Required, minimum 3 characters |
| Itinerary Date | Must be within trip date range |

---

## 🔄 Offline & Sync

All data is stored locally in Hive boxes:

| Box Name | Stores |
|---|---|
| `trips` | Trip objects |
| `participants` | Participant objects |
| `itinerary` | Itinerary items |
| `expenses` | Expense objects |

The `SyncService` class is a stub prepared for future integration with Firebase or a REST API. Each model includes an `isSynced` flag to track pending sync status.

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

Sample data can be seeded using the `DevUtils` class included in the utils folder for development and testing purposes.

---

## 🔮 Future Enhancements

- [ ] Firebase backend sync
- [ ] Push notifications for payment reminders
- [ ] Export trip summary as PDF
- [ ] Currency conversion support
- [ ] Photo attachments for expenses
- [ ] Map integration for destinations
- [ ] Invite participants via link or QR code
- [ ] Receipt scanning with OCR

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m 'Add your feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

Built with ❤️ using Flutter

> *"Travel is the only thing you buy that makes you richer"*