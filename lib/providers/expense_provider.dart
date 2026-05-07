import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final Box<Expense> _box = Hive.box<Expense>('expenses');

  List<Expense> getExpensesForTrip(String tripId) {
    return _box.values.where((e) => e.tripId == tripId).toList();
  }

  double getTotalExpenses(String tripId) {
    return getExpensesForTrip(tripId).fold(0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getExpensesByParticipant(String tripId) {
    final expenses = getExpensesForTrip(tripId);
    final map = <String, double>{};
    for (var e in expenses) {
      map[e.paidById] = (map[e.paidById] ?? 0) + e.amount;
    }
    return map;
  }

  Map<String, double> calculateBalances(String tripId) {
    final expenses = getExpensesForTrip(tripId);
    final balances = <String, double>{};
    
    for (var e in expenses) {
      // PaidBy gets credit
      balances[e.paidById] = (balances[e.paidById] ?? 0) + e.amount;
      
      // SplitAmong members owe
      double splitAmount = e.amount / e.splitAmong.length;
      for (var pId in e.splitAmong) {
        balances[pId] = (balances[pId] ?? 0) - splitAmount;
      }
    }
    return balances;
  }

  List<Map<String, dynamic>> calculateSettlements(String tripId) {
    final balances = calculateBalances(tripId);
    final debtors = <_Balance>[];
    final creditors = <_Balance>[];

    balances.forEach((id, bal) {
      if (bal < -0.01) {
        debtors.add(_Balance(id, bal.abs()));
      } else if (bal > 0.01) creditors.add(_Balance(id, bal));
    });

    final settlements = <Map<String, dynamic>>[];
    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      double amount = debtors[i].amount < creditors[j].amount 
          ? debtors[i].amount 
          : creditors[j].amount;
      
      settlements.add({
        'from': debtors[i].id,
        'to': creditors[j].id,
        'amount': amount,
      });

      debtors[i].amount -= amount;
      creditors[j].amount -= amount;

      if (debtors[i].amount < 0.01) i++;
      if (creditors[j].amount < 0.01) j++;
    }
    return settlements;
  }

  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}

class _Balance {
  String id;
  double amount;
  _Balance(this.id, this.amount);
}
