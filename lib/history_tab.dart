import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> journalEntries;
  final Function(int id) onDeleteEntry;

  const HistoryTab({
    super.key,
    required this.journalEntries,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    // Group entries by date
    final Map<String, List<Map<String, dynamic>>> groupedEntries = {};
    for (final entry in journalEntries) {
      final date =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['date']));
      groupedEntries.putIfAbsent(date, () => []).add(entry);
    }

    // Sort dates descending
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length * 2, // Date header + entries
      itemBuilder: (context, index) {
        if (index.isOdd) return const SizedBox.shrink();

        final dateIndex = index ~/ 2;
        final date = sortedDates[dateIndex];
        final entries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                DateFormat('MMMM d, y').format(DateTime.parse(date)),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ...entries.map((entry) {
              final time =
                  DateFormat('h:mm a').format(DateTime.parse(entry['date']));
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: _getEntryColor(entry['sentiment'] ?? 'neutral'),
                child: ListTile(
                  title: Text(
                    entry['comments'],
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text('Time: $time',
                      style: TextStyle(color: Colors.grey.shade800)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDeleteEntry(entry['id']),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _getEntryColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green.shade100;
      case 'negative':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
