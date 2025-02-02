import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'history_tab.dart';
import 'write_journal_tab.dart'; // Import the DatabaseHelper class

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    List<Map<String, dynamic>> entries = await _dbHelper.getJournalEntries();
    setState(() {
      _journalEntries = entries;
    });
  }

  Future<void> _saveJournalEntry(String entry, String sentiment) async {
    await _dbHelper.insertJournalEntry(entry, sentiment);
    await _loadJournalEntries(); // Refresh the list of entries
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Journal entry saved!')),
    );
  }

  Future<void> _deleteJournalEntry(int id) async {
    await _dbHelper.deleteJournalEntry(id);
    await _loadJournalEntries(); // Refresh the list of entries
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Journal entry deleted!')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Your Day'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Write'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          WriteJournalTab(
            onSaveEntry: _saveJournalEntry,
          ),
          HistoryTab(
            journalEntries: _journalEntries,
            onDeleteEntry: _deleteJournalEntry,
          ),
        ],
      ),
    );
  }
}
