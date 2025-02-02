import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import the DatabaseHelper class

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _journalController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _journalEntries = [];
  String _selectedSentiment = 'neutral'; // Default sentiment

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

  Future<void> _saveJournalEntry() async {
    String entry = _journalController.text.trim();
    if (entry.isNotEmpty) {
      await _dbHelper.insertJournalEntry(entry, _selectedSentiment);
      _journalController.clear();
      await _loadJournalEntries(); // Refresh the list of entries
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Journal entry saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write something before saving.')),
      );
    }
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
    _journalController.dispose();
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
          // Write Journal Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _journalController,
                    maxLines: null, // Allows the text field to expand
                    decoration: InputDecoration(
                      hintText: 'Write about your day...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSentiment = 'positive';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSentiment == 'positive'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text('Positive'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSentiment = 'neutral';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSentiment == 'neutral'
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      child: Text('Neutral'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSentiment = 'negative';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSentiment == 'negative'
                            ? Colors.red
                            : Colors.grey,
                      ),
                      child: Text('Negative'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveJournalEntry,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Save Entry',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          // Journal History Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _journalEntries.isEmpty
                ? Center(
                    child: Text(
                      'No journal entries yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _journalEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _journalEntries[index];
                      final sentiment = entry['sentiment'] ?? 'neutral';
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: sentiment == 'positive'
                            ? Colors.green[50]
                            : sentiment == 'negative'
                                ? Colors.red[50]
                                : Colors.grey[50],
                        child: ListTile(
                          title: Text(entry['entry']),
                          subtitle: Text(
                            'Date: ${DateTime.parse(entry['date']).toLocal().toString()}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteJournalEntry(entry['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
