import 'package:flutter/material.dart';
import 'package:healthyme/journal_screen.dart';
import 'package:healthyme/profile_screen.dart';
import 'package:healthyme/recoder_screen.dart';
import 'package:healthyme/talk_to_ai_screen.dart';

import 'config.dart';

class AppDrawer extends StatelessWidget {
  final Config config;

  const AppDrawer({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Log your day'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.mic),
            title: Text('Audio Recorder'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioRecorderScreen(config: config),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Add navigation to settings screen if needed
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
