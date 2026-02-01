import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/expense_screen.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/analytics_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('expenses');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      darkTheme: ThemeData.dark(useMaterial3: true),

      themeMode: ThemeMode.system,

      home: StreamBuilder(
        stream: AuthService().authStateChanges(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  final pages = [
    const ExpenseScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Expenses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Analytics",
          ),
        ],
      ),
    );
  }
}