import 'package:hive/hive.dart';

part 'trip_model.g.dart';

@HiveType(typeId: 0)
class Trip extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String destination;
  
  @HiveField(3)
  DateTime startDate;
  
  @HiveField(4)
  DateTime endDate;
  
  @HiveField(5)
  List<String> participantIds;
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  bool isSynced;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.participantIds,
    required this.createdAt,
    this.isSynced = false,
  });
}
