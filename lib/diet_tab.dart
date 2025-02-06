import 'package:flutter/material.dart';
import 'database_helper.dart';

class DietTab extends StatefulWidget {
  const DietTab({super.key});

  @override
  _DietTabState createState() => _DietTabState();
}

class _DietTabState extends State<DietTab> {
  final TextEditingController _foodController = TextEditingController();

  Future<void> _logMeal(String mealType) async {
    final date = DateTime.now().toIso8601String().split('T').first;
    await DatabaseHelper().logFood(date, mealType, 'Healthy Meal');
    await DatabaseHelper().logActivity(mealType, 0, _foodController.text);
    await DatabaseHelper().logScore(date, 'Healthy $mealType', 10);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$mealType logged!')),
    );
  }

  Future<void> _logCustomFood() async {
    if (_foodController.text.isNotEmpty) {
      await DatabaseHelper().logActivity("Snack", 0, _foodController.text);
      _foodController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Food logged!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Add this
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
