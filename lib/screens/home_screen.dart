import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    final filteredTrips = tripProvider.searchTrips(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('TravelMate', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search trips...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: filteredTrips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.travel_explore, size: 80, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('No trips found. Start planning!', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTrips.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      return TripCard(trip: trip)
                          .animate()
                          .fadeIn(duration: 500.ms, delay: (100 * index).ms)
                          .slideX(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-trip'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.secondary,
        selectedItemColor: AppTheme.highlight,
        unselectedItemColor: AppTheme.textSecondary,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.beach_access), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/search');
        },
      ),
    );
  }
}
