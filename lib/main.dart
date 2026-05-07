import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/trip_model.dart';
import 'models/participant_model.dart';
import 'models/itinerary_item_model.dart';
import 'models/expense_model.dart';
import 'providers/trip_provider.dart';
import 'providers/participant_provider.dart';
import 'providers/itinerary_provider.dart';
import 'providers/expense_provider.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/trip_creation_screen.dart';
import 'screens/trip_dashboard_screen.dart';
import 'screens/expense_entry_screen.dart';
import 'screens/itinerary_planning_screen.dart';
import 'screens/search_filter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TripAdapter());
  Hive.registerAdapter(ParticipantAdapter());
  Hive.registerAdapter(ItineraryItemAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Trip>('trips');
  await Hive.openBox<Participant>('participants');
  await Hive.openBox<ItineraryItem>('itinerary');
  await Hive.openBox<Expense>('expenses');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ParticipantProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const TravelPlannerApp(),
    ),
  );
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelMate',
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/create-trip': (context) => const TripCreationScreen(),
        '/dashboard': (context) => const TripDashboardScreen(),
        '/add-expense': (context) => const ExpenseEntryScreen(),
        '/add-itinerary': (context) => const ItineraryPlanningScreen(),
        '/search': (context) => const SearchAndFilterScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
