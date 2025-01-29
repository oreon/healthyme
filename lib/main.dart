import 'kickboxing_screen.dart';
import 'notifications_service.dart';
import 'package:flutter/material.dart';

import 'exercise_tab.dart';
import 'lowerbody_strength.dart';
import 'meditation_tab.dart';
import 'diet_tab.dart';
import 'log_tab.dart';
import 'pranayama_screen.dart';
import 'profile_screen.dart';
import 'talk_to_ai_screen.dart';
import 'yoga_screen.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final duration = inputData!["duration"] as int;
    var remainingTime = duration;

    // Simulate the timer logic
    while (remainingTime > 0) {
      await Future.delayed(Duration(seconds: 1));
      remainingTime--;
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminders();
  runApp(FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      routes: {
        '/exercise': (context) => LowerBodyWorkoutScreen(),
        '/yoga': (context) => YogaScreen(),
        '/pranayama': (context) => PranayamaScreen(),
        '/kickboxing': (context) => KickboxingScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Define the tabs
  final List<Widget> _tabs = [
    ExerciseTab(),
    MeditationTab(),
    DietTab(),
    LogScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Talk to AI'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TalkToAIScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _tabs[_selectedIndex], // Display the selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), // Workout icon
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement), // Meditation icon
            label: 'Meditation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant), // Diet icon
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list), // Log icon
            label: 'Log',
          ),
        ],
      ),
    );
  }
}
