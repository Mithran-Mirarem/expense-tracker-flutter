import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import 'local_storage_service.dart';

class FirestoreService {

  final _db = FirebaseFirestore.instance;
  final local = LocalStorageService();

  CollectionReference get _ref => _db.collection("expenses");

  Future<void> addExpense(Expense expense) async {

    // Save locally first
    local.saveExpense(expense);

    // Try cloud sync
    try {
      await _ref.doc(expense.id).set(expense.toMap());
    } catch (e) {
      // Offline safe
    }
  }

  Stream<List<Expense>> getExpenses() {
    return _ref.snapshots().map((snapshot) {

      final cloudData = snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // Cache cloud to local
      for (var e in cloudData) {
        local.saveExpense(e);
      }

      return cloudData;
    });
  }

  Future<void> deleteExpense(String id) async {

    local.deleteExpense(id);

    try {
      await _ref.doc(id).delete();
    } catch (e) {
      // Offline safe delete
    }
  }
}