import 'package:flutter/material.dart';

class WriteJournalTab extends StatefulWidget {
  final Function(String entry, String sentiment) onSaveEntry;

  const WriteJournalTab({super.key, required this.onSaveEntry});

  @override
  _WriteJournalTabState createState() => _WriteJournalTabState();
}

class _WriteJournalTabState extends State<WriteJournalTab> {
  final TextEditingController _journalController = TextEditingController();
  String _selectedSentiment = 'neutral'; // Default sentiment

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            onPressed: () {
              final entry = _journalController.text.trim();
              if (entry.isNotEmpty) {
                widget.onSaveEntry(entry, _selectedSentiment);
                _journalController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Please write something before saving.')),
                );
              }
            },
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
    );
  }
}
