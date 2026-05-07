import 'package:hive/hive.dart';

part 'participant_model.g.dart';

@HiveType(typeId: 1)
class Participant extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String? email;
  
  @HiveField(3)
  String tripId;
  
  @HiveField(4)
  String avatarColorHex;

  Participant({
    required this.id,
    required this.name,
    this.email,
    required this.tripId,
    required this.avatarColorHex,
  });
}
