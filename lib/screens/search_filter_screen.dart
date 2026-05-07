import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';

class SearchAndFilterScreen extends StatefulWidget {
  const SearchAndFilterScreen({super.key});

  @override
  State<SearchAndFilterScreen> createState() => _SearchAndFilterScreenState();
}

class _SearchAndFilterScreenState extends State<SearchAndFilterScreen> {
  String _query = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final tripProv = Provider.of<TripProvider>(context);
    var trips = tripProv.searchTrips(_query);
    
    final now = DateTime.now();
    if (_filter == 'Upcoming') {
      trips = trips.where((t) => t.startDate.isAfter(now)).toList();
    } else if (_filter == 'Past') {
      trips = trips.where((t) => t.endDate.isBefore(now)).toList();
    } else if (_filter == 'Active') {
      trips = trips.where((t) => t.startDate.isBefore(now) && t.endDate.isAfter(now)).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Search Trips')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(hintText: 'Search by name or destination', prefixIcon: Icon(Icons.search)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Active', 'Upcoming', 'Past'].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (val) => setState(() => _filter = f),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) => TripCard(trip: trips[index]),
            ),
          ),
        ],
      ),
    );
  }
}
