import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/trip_model.dart';

class TripProvider with ChangeNotifier {
  final Box<Trip> _tripBox = Hive.box<Trip>('trips');
  Trip? _currentTrip;

  List<Trip> get trips => _tripBox.values.toList();
  Trip? get currentTrip => _currentTrip;

  set currentTrip(Trip? trip) {
    _currentTrip = trip;
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    await _tripBox.put(trip.id, trip);
    notifyListeners();
  }

  Future<void> updateTrip(Trip trip) async {
    await trip.save();
    notifyListeners();
  }

  Future<void> deleteTrip(String id) async {
    await _tripBox.delete(id);
    notifyListeners();
  }

  List<Trip> searchTrips(String query) {
    if (query.isEmpty) return trips;
    return trips.where((trip) => 
      trip.name.toLowerCase().contains(query.toLowerCase()) ||
      trip.destination.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
