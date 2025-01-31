import 'package:healthyme/app_drawer.dart';
import 'package:healthyme/config.dart';
import 'package:healthyme/log_day.dart';
import 'package:healthyme/recoder_screen.dart';

import 'kickboxing_screen.dart';
import 'notifications_service.dart';
import 'package:flutter/material.dart';

import 'exercise_tab.dart';
import 'lowerbody_strength.dart';
import 'meditation_tab.dart';
import 'diet_tab.dart';
import 'log_tab.dart';
import 'pranayama_screen.dart';

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
  final Config config = await Config.load();
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminders();
  runApp(FitnessTrackerApp(config: config));
}

class FitnessTrackerApp extends StatelessWidget {
  final Config config;
  const FitnessTrackerApp({required this.config, super.key});

  //MyApp({required this.config});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(
        config: config,
      ),
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
  final Config config;
  const HomeScreen({super.key, required this.config});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  //final Config config;

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
        title: Text('Healthy me'),
      ),
      drawer: AppDrawer(config: widget.config),
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
