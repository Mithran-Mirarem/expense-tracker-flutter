import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final firestore = FirestoreService();

  String selectedCategory = "Food";

  final categories = [
    "Food",
    "Transport",
    "Personal",
    "Health",
    "Finance",
    "Entertainment",
    "Other",
  ];
  final Map<String, Color> categoryColors = { "Food": Colors.orange, "Transport": Colors.blue, "Personal": Colors.red, "Health": Colors.purple, "Finance": Colors.green, "Entertainment": Colors.yellow, "Other": Colors.pink, };
  addExpense() async {

    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter amount")),
      );
      return;
    }

    final expense = Expense(
      id: DateTime.now().toString(),
      amount: double.tryParse(amountController.text) ?? 0,
      category: selectedCategory,
      date: DateTime.now(),
      note: noteController.text,
    );

    await firestore.addExpense(expense);

    amountController.clear();
    noteController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),

      // ✅ ONLY LIST IN BODY
      body: StreamBuilder<List<Expense>>(
        stream: firestore.getExpenses(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No expenses yet"));
          }

          final expenses = snapshot.data!;

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {

              final e = expenses[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: categoryColors[e.category] ?? Colors.grey,
                  radius: 10,
                ),

                title: Text("₹${e.amount}"),
                subtitle: Text("${e.note} • ${e.category}"),

                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                    onPressed: () {
                      firestore.deleteExpense(e.id);
                    },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,

            builder: (_) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Amount"),
                    ),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: "Category"),

                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),

                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: "Note"),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        addExpense();
                        Navigator.pop(context);
                      },
                      child: const Text("Add Expense"),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}