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
            // Description above the calendar
            Text(
              'Select a day from the calendar to edit or create a meal plan. '
                  'If a meal plan was already created, it will appear below.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2024, 12, 31),
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Show a confirmation dialog before deleting
                          bool proceedToDelete = await _showDeleteConfirmationDialog();
                          if (proceedToDelete) {
                            await MealPlanDatabase().deleteMealPlan(mealPlanRecord.date);
                            setState(() {
                              // Reset the selected day after deleting
                              _selectedDay = DateTime.now();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Set the button color to red
                          foregroundColor: Colors.white, // Set the text color to white
                          minimumSize: Size(150, 40), // Set the button size
                        ),
                        child: Text('Delete Meal Plan'),
                      ),
                    ],
                  );
                } else {
                  // No Meal Plan for the selected day
                  return Text('No meal plan has been created for this day.',
                      style: TextStyle(fontSize: 18));
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

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Meal Plan'),
          content: Text('Are you sure you want to delete the meal plan for this day?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, cancel the action
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes, proceed with deleting
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false; // Default to false if the user cancels the dialog
  }

}
