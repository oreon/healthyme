import 'package:flutter/foundation.dart';
import 'package:healthyme/app_drawer.dart';
import 'package:healthyme/config.dart';
import 'package:healthyme/today_screen.dart';

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
  // workmanager is Android/iOS only. Web preview has no background isolate.
  if (kIsWeb) return;
  Workmanager().executeTask((task, inputData) async {
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Config config = await Config.load();
  // Notifications and timezone plugins have no web implementation.
  if (!kIsWeb) {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.scheduleDailyReminders();
  }
  runApp(FitnessTrackerApp(config: config));
}

class FitnessTrackerApp extends StatelessWidget {
  final Config config;
  const FitnessTrackerApp({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
      ),
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

  final List<Widget> _tabs = [
    TodayScreen(),
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
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.accessible_outlined),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Meditation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Log',
          ),
        ],
      ),
    );
  }
}
