import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 3)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String tripId;
  
  @HiveField(2)
  double amount;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  String paidById;
  
  @HiveField(5)
  List<String> splitAmong;
  
  @HiveField(6)
  DateTime createdAt;
  
  @HiveField(7)
  String category;

  Expense({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.description,
    required this.paidById,
    required this.splitAmong,
    required this.createdAt,
    required this.category,
  });
}
