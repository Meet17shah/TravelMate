import 'package:hive/hive.dart';

part 'itinerary_item_model.g.dart';

@HiveType(typeId: 2)
class ItineraryItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String tripId;
  
  @HiveField(2)
  DateTime date;
  
  @HiveField(3)
  String activity;
  
  @HiveField(4)
  String? time;
  
  @HiveField(5)
  String? notes;

  ItineraryItem({
    required this.id,
    required this.tripId,
    required this.date,
    required this.activity,
    this.time,
    this.notes,
  });
}
