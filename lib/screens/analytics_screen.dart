import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final firestore = FirestoreService();
  final Map<String, Color> categoryColors = {
    "Food": Colors.orange,
    "Transport": Colors.blue,
    "Personal": Colors.red,
    "Health": Colors.purple,
    "Finance": Colors.green,
    "Entertainment": Colors.yellow,
    "Other": Colors.pink,
  };

  Map<String, double> calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> data = {};

    for (var e in expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),

      body: StreamBuilder<List<Expense>>(
        stream: firestore.getExpenses(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!;
          final categoryData = calculateCategoryTotals(expenses);

          final totalSpent =
          expenses.fold(0.0, (sum, item) => sum + item.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Total Spent: ₹${totalSpent.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: categoryData.entries.map((entry) {

                        return PieChartSectionData(
                          value: entry.value,
                          title: entry.key,
                          radius: 80,

                          color: categoryColors[entry.key] ?? Colors.grey,
                        );


                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...expenses.reversed.take(5).map((e) {

                  return ListTile(
                    title: Text("₹${e.amount}"),
                    subtitle: Text(e.note),
                    trailing: Text(e.category),
                  );

                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}