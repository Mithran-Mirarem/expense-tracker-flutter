import 'package:hive/hive.dart';
import '../models/expense.dart';

class LocalStorageService {

  final Box box = Hive.box('expenses');

  void saveExpense(Expense expense) {
    box.put(expense.id, expense.toMap());
  }

  List<Expense> getLocalExpenses() {
    final data = box.values.toList();

    return data.map((e) {
      return Expense.fromMap(Map<String, dynamic>.from(e));
    }).toList();
  }

  void deleteExpense(String id) {
    box.delete(id);
  }
}