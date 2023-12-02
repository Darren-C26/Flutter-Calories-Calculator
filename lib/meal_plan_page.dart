// meal_plan_page.dart
import 'package:flutter/material.dart';
import 'database.dart';
import 'dart:convert';

class FoodItem {
  final String name;
  final int calories;
  final String imagePath;

  FoodItem(this.name, this.calories, this.imagePath);
}

class MealPlanPage extends StatefulWidget {
  final DateTime selectedDay;
  final int targetCalories;

  const MealPlanPage({
    required this.selectedDay,
    required this.targetCalories,
  });

  @override
  _MealPlanPageState createState() => _MealPlanPageState();
}

class MealPlanRecord {
  final int? id;
  final String date;
  final int targetCalories;
  final Map<String, int> items;

  MealPlanRecord({
    this.id,
    required this.date,
    required this.targetCalories,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'target_calories': targetCalories,
      'items': jsonEncode(items), // Convert the map to a JSON string
    };
  }

  factory MealPlanRecord.fromMap(Map<String, dynamic> map) {
    return MealPlanRecord(
      id: map['id'],
      date: map['date'],
      targetCalories: map['target_calories'],
      items: Map<String, int>.from(jsonDecode(map['items'])), // Parse the JSON string to a map
    );
  }
}

class _MealPlanPageState extends State<MealPlanPage> {

  final MealPlanDatabase _mealPlanDatabase = MealPlanDatabase();
  List<FoodItem> foodOptions = [
    FoodItem('Apple', 95, 'assets/apple.jpg'),
    FoodItem('Chicken Breast', 165, 'assets/chicken_breast.jpg'),
    FoodItem('Salmon', 206, 'assets/salmon.jpg'),
    FoodItem('Broccoli', 31, 'assets/broccoli.jpg'),
    FoodItem('Carrot', 41, 'assets/carrot.jpg'),
    FoodItem('Banana', 105, 'assets/banana.jpg'),
    FoodItem('Egg (Boiled)', 68, 'assets/egg_boiled.jpg'),
    FoodItem('Pasta (Cooked)', 200, 'assets/pasta.jpg'),
    FoodItem('Rice (Cooked)', 215, 'assets/rice.jpg'),
    FoodItem('Spinach', 7, 'assets/spinach.jpg'),
    FoodItem('Almonds', 7, 'assets/almonds.jpg'),
    FoodItem('Orange', 80, 'assets/orange.jpg'),
    FoodItem('Mango', 200, 'assets/mango.jpg'),
    FoodItem('Greek Yogurt', 100, 'assets/greek_yogurt.jpg'),
    FoodItem('Cheese (Cheddar)', 110, 'assets/cheddar_cheese.jpg'),
    FoodItem('Tomato', 22, 'assets/tomato.jpg'),
    FoodItem('Avocado', 240, 'assets/avocado.jpg'),
    FoodItem('Strawberries', 4, 'assets/strawberries.jpg'),
      FoodItem('Quinoa (Cooked)', 111, 'assets/quinoa.jpg'),
    FoodItem('Lentils (Cooked)', 230, 'assets/lentils.jpg'),
    // Add more food items
  ];

  Map<String, int> selectedFoodItemsMap = {};
  int calorieTotal = 0;
  late TextEditingController _calorieController;

  int calculateCalorieTotal(Map<String, int> foodItems) {
    int totalCalories = 0;
    for (var entry in foodItems.entries) {
      String foodName = entry.key;
      int quantity = entry.value;
      FoodItem foodItem = foodOptions.firstWhere((item) => item.name == foodName);
      totalCalories += foodItem.calories * quantity;
    }
    return totalCalories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit/Create Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Selected Day: ${_formatSelectedDay()}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Enter Target Calories:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _calorieController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Calories',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Current Items in Meal Plan:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (selectedFoodItemsMap.isEmpty)
              Text(
                'Select food items from the options listed below.',
                style: TextStyle(fontSize: 16),
              ),
            if (selectedFoodItemsMap.isNotEmpty)
              SizedBox(
                height: (MediaQuery.of(context).size.height) / 4,
                child: ListView.builder(
                  itemCount: selectedFoodItemsMap.length,
                  itemBuilder: (context, index) {
                    String foodName = selectedFoodItemsMap.keys.elementAt(index);
                    int quantity = selectedFoodItemsMap[foodName] ?? 0;

                    return ListTile(
                      title: Text('$foodName (Quantity: $quantity)'),
                      subtitle: Text(
                        '${foodOptions.firstWhere((item) => item.name == foodName).calories * quantity} Calories',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            calorieTotal -= foodOptions
                                .firstWhere((item) => item.name == foodName)
                                .calories *
                                quantity;

                            selectedFoodItemsMap.remove(foodName);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Food Options:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: foodOptions.length,
                itemBuilder: (context, index) {
                  FoodItem foodItem = foodOptions[index];
                  return GestureDetector(
                    onTap: () {
                      _showFoodItemDialog(foodItem);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: AssetImage(foodItem.imagePath),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.2), // Adjust opacity here
                            BlendMode.dstATop,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            foodItem.name,
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${foodItem.calories} Calories',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Calorie Total: $calorieTotal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? targetCalories = int.tryParse(_calorieController.text);

                if (targetCalories != null && calorieTotal <= targetCalories) {
                  await _saveMealPlan();
                } else {
                  // Display a confirmation dialog
                  bool clearItems = await _showClearItemsDialog();
                  if (clearItems) {
                    // Clear items and update target calories
                    setState(() {
                      selectedFoodItemsMap.clear();
                      calorieTotal = 0;
                    });
                  }
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController(text: widget.targetCalories.toString());
    _loadMealPlan();
  }

  // Load the meal plan for the selected date, if it exists
  void _loadMealPlan() async {
    MealPlanRecord? existingMealPlan = await _mealPlanDatabase.getMealPlan(_formatSelectedDay());

    if (existingMealPlan != null) {
      // Load existing meal plan
      setState(() {
        selectedFoodItemsMap = existingMealPlan.items;
        calorieTotal = calculateCalorieTotal(selectedFoodItemsMap);
      });
    }
  }

  Future<bool> _showClearItemsDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(
            'Target calories is lower than calorie total. This will require removing the current items from the meal plan. Do you want to proceed?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No, cancel the action
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes, proceed with clearing items
              },
              child: Text('Proceed'),
            ),
          ],
        );
      },
    ) ?? false; // Default to false if the user cancels the dialog
  }

  Future<void> _saveMealPlan() async {
    // Parse the target calories from the text field
    int targetCalories = int.tryParse(_calorieController.text) ?? 1000;

    // Check if the list of selected food items is empty
    if (selectedFoodItemsMap.isEmpty) {
      // Show an alert dialog
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Empty Meal Plan'),
            content: Text('Please select food items to add to the meal plan.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Do not proceed with saving the meal plan
    }

    // Save or update meal plan in the database
    MealPlanRecord mealPlanRecord = MealPlanRecord(
      date: _formatSelectedDay(),
      targetCalories: targetCalories,
      items: selectedFoodItemsMap,
    );

    await _mealPlanDatabase.saveMealPlan(mealPlanRecord);
  }


  String _formatSelectedDay() {
    // Format the selected day as "Month day, year"
    return '${_getMonth(widget.selectedDay.month)} ${widget.selectedDay.day}, ${widget.selectedDay.year}';
  }

  String _getMonth(int month) {
    // Map month number to month name
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _showFoodItemDialog(FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuantityDialog(
          foodItem: foodItem,
          onQuantityChanged: (quantity) {
            _updateSelectedFoodItems(foodItem, quantity);
          },
        );
      },
    );
  }

  void _updateSelectedFoodItems(FoodItem foodItem, int quantity) {
    setState(() {
      selectedFoodItemsMap.update(
        foodItem.name,
            (value) => value + quantity,
        ifAbsent: () => quantity,
      );
      calorieTotal += foodItem.calories * quantity;
    });
  }
}


class QuantityDialog extends StatefulWidget {
  final FoodItem foodItem;
  final ValueChanged<int> onQuantityChanged;

  const QuantityDialog({
    required this.foodItem,
    required this.onQuantityChanged,
  });

  @override
  _QuantityDialogState createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Quantity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.foodItem.name),
          SizedBox(height: 8),
          Text('${widget.foodItem.calories} Calories'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
              ),
              Text(quantity.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onQuantityChanged(quantity);
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}