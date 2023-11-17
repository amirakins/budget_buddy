import 'package:flutter/material.dart';

import 'login.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  String? _selectedCategory; // Variable to store the selected category.
  final List<String> _categories = ['Savings', 'Transportation', 'Food', 'Housing', 'Personal'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Function to handle the category selection.
  void _handleCategoryChange(String? newValue) {
    setState(() {
      _selectedCategory = newValue;
    });
  }

  // Function to handle the "Add" button press.
  void _handleAddExpense() {
    // Handle adding the expense here.
    // You can access the entered name, selected category, and amount.

    // Once added, you can navigate back to the home page.
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: _handleCategoryChange,
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount (\$)'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _handleAddExpense,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddExpensePage(),
  ));
}
