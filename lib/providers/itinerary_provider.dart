import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/itinerary_item_model.dart';

class ItineraryProvider with ChangeNotifier {
  final Box<ItineraryItem> _box = Hive.box<ItineraryItem>('itinerary');

  List<ItineraryItem> getItemsForTrip(String tripId) {
    var items = _box.values.where((item) => item.tripId == tripId).toList();
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Map<DateTime, List<ItineraryItem>> getItemsGroupedByDate(String tripId) {
    final items = getItemsForTrip(tripId);
    final grouped = <DateTime, List<ItineraryItem>>{};
    for (var item in items) {
      final dateOnly = DateTime(item.date.year, item.date.month, item.date.day);
      grouped.putIfAbsent(dateOnly, () => []).add(item);
    }
    return grouped;
  }

  Future<void> addItem(ItineraryItem item) async {
    await _box.put(item.id, item);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
