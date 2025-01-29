import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = '';
  double _currentWeight = 0.0;
  String? _fastingDay;

  final List<String> _daysOfWeek = [
    'None',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _dateOfBirth = DateTime.tryParse(prefs.getString('dateOfBirth') ?? '');
      _gender = prefs.getString('gender') ?? '';
      _currentWeight = prefs.getDouble('currentWeight') ?? 0.0;
      _fastingDay = prefs.getString('fastingDay');
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setString(
          'dateOfBirth', _dateOfBirth?.toIso8601String() ?? '');
      await prefs.setString('gender', _gender);
      await prefs.setDouble('currentWeight', _currentWeight);
      await prefs.setString('fastingDay', _fastingDay ?? 'None');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved!')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                  child: Text(
                    _dateOfBirth == null
                        ? 'Select Date'
                        : '${_dateOfBirth!.toLocal()}'.split(' ')[0],
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: _gender.isEmpty ? null : _gender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Current Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _currentWeight = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration:
                    InputDecoration(labelText: 'Fasting Day (Optional)'),
                value: _fastingDay,
                items: _daysOfWeek
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _fastingDay = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
