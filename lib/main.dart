// main.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'meal_plan_page.dart'; // Import the MealPlanPage
import 'database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterCaloriesCalculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  TextEditingController _calorieController = TextEditingController();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  void _navigateToMealPlanPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPlanPage(
          selectedDay: _selectedDay,
          targetCalories: int.tryParse(_calorieController.text) ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlutterCaloriesCalculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2023, 12, 31),
              focusedDay: _selectedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: _navigateToMealPlanPage,
              child: Text('Edit/Create Meal Plan'),
            ),
            SizedBox(height: 20),
            // Display Meal Plan information if available
            FutureBuilder(
              // Check if there is a meal plan for the selected day
              future: MealPlanDatabase().getMealPlan(_formatSelectedDay(_selectedDay)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Meal Plan exists, display it
                  MealPlanRecord mealPlanRecord = snapshot.data as MealPlanRecord;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meal Plan for ${_formatSelectedDay(_selectedDay)}'),
                      Text('Target Calories: ${mealPlanRecord.targetCalories}'),
                      Text('Items: ${mealPlanRecord.items}'),
                    ],
                  );
                } else {
                  // No Meal Plan for the selected day
                  return Text('No meal plan has been created for this day.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatSelectedDay(DateTime date) {
    // Format the selected day as "Month day, year"
    return '${_getMonth(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonth(int month) {
    // Map month number to month name
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
