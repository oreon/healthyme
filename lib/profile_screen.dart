import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications_service.dart'; // Import the NotificationService class

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
  //double _currentWeight = 0.0;
  String? _fastingDay;
  TimeOfDay? _feedingStartTime;
  TimeOfDay? _feedingEndTime;

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

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.init(); // Initialize the notification service
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _dateOfBirth = DateTime.tryParse(prefs.getString('dateOfBirth') ?? '');
      _gender = prefs.getString('gender') ?? '';
      // _currentWeight = prefs.getDouble('currentWeight') ?? 0.0;
      _fastingDay = prefs.getString('fastingDay');

      // Load feeding times
      final startTime = prefs.getString('feedingStartTime');
      final endTime = prefs.getString('feedingEndTime');
      if (startTime != null) {
        _feedingStartTime = TimeOfDay(
          hour: int.parse(startTime.split(':')[0]),
          minute: int.parse(startTime.split(':')[1]),
        );
      }
      if (endTime != null) {
        _feedingEndTime = TimeOfDay(
          hour: int.parse(endTime.split(':')[0]),
          minute: int.parse(endTime.split(':')[1]),
        );
      }
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
      //await prefs.setDouble('currentWeight', _currentWeight);
      await prefs.setString('fastingDay', _fastingDay ?? 'None');

      // Save feeding times
      if (_feedingStartTime != null) {
        await prefs.setString('feedingStartTime',
            '${_feedingStartTime!.hour}:${_feedingStartTime!.minute}');
      }
      if (_feedingEndTime != null) {
        await prefs.setString('feedingEndTime',
            '${_feedingEndTime!.hour}:${_feedingEndTime!.minute}');
      }

      // Schedule notifications for feeding start and end times
      if (_feedingStartTime != null && _feedingEndTime != null) {
        await _scheduleFeedingNotifications();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved!')),
      );
    }
  }

  Future<void> _scheduleFeedingNotifications() async {
    // Cancel any existing notifications
    await _notificationService.cancelAllNotifications();

    // Schedule feeding start notification
    if (_feedingStartTime != null && _feedingEndTime != null) {
      {
        await _notificationService.zonedSchedule(
          100, // Unique ID for feeding start notification
          'Feeding can start!',
          'It\'s time to start your meals.',
          _feedingStartTime!.hour, _feedingStartTime!.minute,
        );

        await _notificationService.zonedSchedule(
          101, // Unique ID for feeding start notification
          'Feeding Time over!',
          'Your feeding window has ended. Please do not consume anything till tomorro',
          _feedingEndTime!.hour, _feedingEndTime!.minute,
        );
      }
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

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _feedingStartTime = picked;
        } else {
          _feedingEndTime = picked;
        }
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
          child: ListView(
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
              // SizedBox(height: 20),
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'Current Weight (kg)'),
              //   keyboardType: TextInputType.number,
              //   // initialValue:
              //   //     _currentWeight == 0.0 ? '' : _currentWeight.toString(),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your weight';
              //     }
              //     if (double.tryParse(value) == null) {
              //       return 'Please enter a valid number';
              //     }
              //     return null;
              //   },
              //   onSaved: (value) {
              //     _currentWeight = double.parse(value!);
              //   },
              // ),
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
              InkWell(
                onTap: () => _selectTime(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Feeding Start Time'),
                  child: Text(
                    _feedingStartTime == null
                        ? 'Select Start Time'
                        : _feedingStartTime!.format(context),
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () => _selectTime(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Feeding End Time'),
                  child: Text(
                    _feedingEndTime == null
                        ? 'Select End Time'
                        : _feedingEndTime!.format(context),
                  ),
                ),
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
