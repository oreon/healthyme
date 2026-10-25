import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'database_helper.dart';
import 'food.dart';

class DietTab extends StatefulWidget {
  const DietTab({super.key});

  @override
  _DietTabState createState() => _DietTabState();
}

class _DietTabState extends State<DietTab> {
  final TextEditingController _foodController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _db = DatabaseHelper();

  List<FoodSnapshot> _todaySnapshots = [];
  EatingWindow? _eatingWindow;

  String _caffeineType = CaffeineEntry.coffee;
  int _caffeineCups = 1;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  /// Reloads today's snapshots and re-derives the eating window from
  /// today's meal/snack logs plus the snapshot timestamps.
  Future<void> _refresh() async {
    final today = _db.getTodaysDate();
    final logs = await _db.getLogsByDate(today);
    final snapshots = await _db.getFoodSnapshots(date: today);
    if (!mounted) return;
    setState(() {
      _todaySnapshots = snapshots;
      _eatingWindow = deriveEatingWindow([
        ...mealTimesFromLogs(logs),
        ...snapshots.map((snapshot) => snapshot.capturedAt),
      ]);
    });
  }

  Future<void> _logMeal(String mealType) async {
    // await DatabaseHelper().logFood(date, mealType, 'Healthy Meal');
    await _db.logActivity(mealType, 0, _foodController.text);
    // await DatabaseHelper().logScore(date, 'Healthy $mealType', 10);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$mealType logged!')),
    );
    _refresh();
  }

  Future<void> _logCustomFood() async {
    if (_foodController.text.isNotEmpty) {
      await _db.logActivity("Snack", 0, _foodController.text);
      _foodController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food logged!')),
      );
      _refresh();
    }
  }

  Future<void> _logCaffeine() async {
    await _db.logCaffeine(CaffeineEntry(
      type: _caffeineType,
      cups: _caffeineCups,
      timestamp: DateTime.now(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '${_caffeineType == CaffeineEntry.coffee ? 'Coffee' : 'Tea'} logged!')),
    );
  }

  /// "Snapshot your food": pick a photo (camera or gallery), choose
  /// its meal, then keep a durable copy in the app's documents
  /// directory and record the entry locally. Diary only — the photo
  /// never leaves the device.
  Future<void> _snapshotFood() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final capturedAt = DateTime.now();
    if (!mounted) return;
    final meal = await _pickMeal(defaultMealForTime(capturedAt));
    if (meal == null) return;

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/food_photos');
    await dir.create(recursive: true);
    final dot = picked.path.lastIndexOf('.');
    final extension = dot >= 0 ? picked.path.substring(dot) : '.jpg';
    final dest = File(
        '${dir.path}/food_${capturedAt.millisecondsSinceEpoch}$extension');
    await File(picked.path).copy(dest.path);

    await _db.addFoodSnapshot(
      photoPath: dest.path,
      meal: meal,
      capturedAt: capturedAt,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food snapshot saved!')),
    );
    _refresh();
  }

  Future<String?> _pickMeal(String defaultMeal) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Which meal is this?'),
        children: mealCategories
            .map(
              (meal) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, meal),
                child: Row(
                  children: [
                    Icon(
                      meal == defaultMeal
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(meal),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _deleteSnapshot(FoodSnapshot snapshot) async {
    final removed = await _db.deleteFoodSnapshot(snapshot.id);
    if (removed != null) {
      final file = File(removed.photoPath);
      if (await file.exists()) await file.delete();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Snapshot deleted')),
    );
    _refresh();
  }

  Widget _buildSnapshotSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Snapshot your food',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                'A photo diary of everything you eat — stored only on this device.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _snapshotFood,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Snapshot your food'),
            ),
            if (_todaySnapshots.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("Today's snapshots",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _todaySnapshots.map((snapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(snapshot.photoPath),
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 96,
                            height: 96,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${snapshot.meal} · ${DateFormat('HH:mm').format(snapshot.capturedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        tooltip: 'Delete snapshot',
                        onPressed: () => _deleteSnapshot(snapshot),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCaffeineSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Caffeine',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Coffee'),
                  selected: _caffeineType == CaffeineEntry.coffee,
                  onSelected: (_) =>
                      setState(() => _caffeineType = CaffeineEntry.coffee),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tea'),
                  selected: _caffeineType == CaffeineEntry.tea,
                  onSelected: (_) =>
                      setState(() => _caffeineType = CaffeineEntry.tea),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _caffeineCups > 1
                      ? () => setState(() => _caffeineCups--)
                      : null,
                ),
                Text('$_caffeineCups ${_caffeineCups == 1 ? 'cup' : 'cups'}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _caffeineCups++),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logCaffeine,
              child: const Text('Log caffeine'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Add this
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_eatingWindow != null)
            Card(
              color: Colors.green[50],
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(_eatingWindow!.describe()),
              ),
            ),
          if (_eatingWindow != null) const SizedBox(height: 20),
          _buildSnapshotSection(),
          const SizedBox(height: 20),
          _buildCaffeineSection(),
          const SizedBox(height: 20),
          // Predefined Meal Suggestions
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=500', // Breakfast image
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Healthy Breakfast',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Banana Chocolate Smoothie with Soaked Almonds'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _logMeal('Breakfast'),
                        child: Text('Log Breakfast'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500', // Lunch image
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Healthy Lunch',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Healthy Rainbow Salad and Millets'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _logMeal('Lunch'),
                        child: Text('Log Lunch'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=500', // Dinner image
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Healthy Dinner',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Fruit Ice Cream'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _logMeal('Dinner'),
                        child: Text('Log Dinner'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Custom Food Input
          TextField(
            controller: _foodController,
            decoration: InputDecoration(
              hintText: 'Enter custom food details...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _logCustomFood,
            child: Text('Log Custom Food'),
          ),
          SizedBox(height: 20), // Add extra space at the bottom
        ],
      ),
    );
  }
}
