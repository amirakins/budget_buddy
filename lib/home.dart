import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'login.dart';
import 'profile.dart';
import 'add_expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'realtime_list.dart';

void main() async {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable declarations, etc.
  String paymentAmount = "";
  String paymentFrequency = "";
  double monthlyIncome = 0.00;
  List<dynamic> expenses = [];
  Map<String, dynamic>? incomeDivision;
  Map<String, List<Map<String, dynamic>>> expensesByCategory = {};
  double savings = 0;

  @override
  void initState() {
    super.initState();

    // Initialize categories
    if (expensesByCategory.isEmpty) {
      expensesByCategory["Food"] = [];
      expensesByCategory["Transportation"] = [];
      expensesByCategory["Personal"] = [];
      expensesByCategory["Housing"] = [];
    }

    // Fetch payment data
    PaymentData.streamPaymentFrequency().listen((value) {
      setState(() {
        paymentFrequency = value ?? "";
      });
    });

    PaymentData.streamSavings().listen((value) {
      setState(() {
        savings = value ?? 0;
      });
    });

    PaymentData.streamPaymentAmount().listen((value) {
      setState(() {
        paymentAmount = value ?? "";
        double dpa = double.parse(paymentAmount);
        monthlyIncome = dpa * 1;

        if (paymentFrequency == "Weekly") {
          monthlyIncome = dpa * 4;
        }
        if (paymentFrequency == "Bi-Weekly") {
          monthlyIncome = dpa * 2;
        }
        monthlyIncome = monthlyIncome - savings;
      });
    });

    PaymentData.streamExpenses().listen((value) {
      setState(() {
        expenses = value ?? [];
      });
    });

    PaymentData.streamIncomeDivision().listen((value) {
      setState(() {
        incomeDivision = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize variables
    var foodDiv = incomeDivision?['Food'] ?? 0;
    var housingDiv = incomeDivision?['Housing'] ?? 0;
    var personalDiv = incomeDivision?['Personal'] ?? 0;
    var transportationDiv = incomeDivision?['Transportation'] ?? 0;
    var monthlyExpenses = 0.00;
    var foodExpenses = 0.00;
    var housingExpenses = 0.00;
    var personalExpenses = 0.00;
    var transportationExpenses = 0.00;

    // Calculate monthly expenses
    for (var expense in expenses) {
      String? occurrence = expense['occurrence'];
      String? category = expense['category'];
      double amount = double.parse(expense['amount'] ?? "0.00");

      // Adjust the amount based on the occurrence
      if (occurrence == 'Weekly') {
        monthlyExpenses += amount * 4;
        if (category == "Food") {
          foodExpenses += amount * 4;
        } else if (category == "Housing") {
          housingExpenses += amount * 4;
        } else if (category == "Personal") {
          personalExpenses += amount * 4;
        } else if (category == "Transportation") {
          transportationExpenses += amount * 4;
        }
      } else if (occurrence == 'Monthly') {
        monthlyExpenses += amount;
        if (category == "Food") {
          foodExpenses += amount;
        } else if (category == "Housing") {
          housingExpenses += amount;
        } else if (category == "Personal") {
          personalExpenses += amount;
        } else if (category == "Transportation") {
          transportationExpenses += amount;
        }
      } else if (occurrence == 'Bi-Weekly') {
        monthlyExpenses += amount * 2;
        if (category == "Food") {
          foodExpenses += amount * 2;
        } else if (category == "Housing") {
          housingExpenses += amount * 2;
        } else if (category == "Personal") {
          personalExpenses += amount * 2;
        } else if (category == "Transportation") {
          transportationExpenses += amount * 2;
        }
      } else {
        monthlyExpenses += amount;
        if (category == "Food") {
          foodExpenses += amount;
        } else if (category == "Housing") {
          housingExpenses += amount;
        } else if (category == "Personal") {
          personalExpenses += amount;
        } else if (category == "Transportation") {
          transportationExpenses += amount;
        }
      }
    }

    // Group expenses by category
    for (var expense in expenses) {
      String? occurrence = expense['occurrence'];
      String? category = expense['category'];
      double amount = double.parse(expense['amount'] ?? "0.0");

      if (occurrence == 'Weekly') {
        amount = amount * 4;
      } else if (occurrence == 'Bi-Weekly') {
        amount = amount * 2;
      } else if (occurrence == 'Monthly') {
        amount = amount;
      } else {
        amount = amount;
      }

      if (category == "Food") {
        expensesByCategory['Food']!
            .add({'name': expense['name'], 'monthlyExpense': amount});
      } else if (category == "Housing") {
        expensesByCategory['Housing']!
            .add({'name': expense['name'], 'monthlyExpense': amount});
      } else if (category == "Personal") {
        expensesByCategory['Personal']!
            .add({'name': expense['name'], 'monthlyExpense': amount});
      } else if (category == "Transportation") {
        expensesByCategory['Transportation']!
            .add({'name': expense['name'], 'monthlyExpense': amount});
      }
    }

    var remainingBalance = (monthlyExpenses - monthlyIncome) * -1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Buddy', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.person),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: paymentAmount.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Card 1 - Balance Chart
                  Card(
                    color: Colors.white,
                    elevation: 5.0,
                    child: CategoryChart(
                      categoryName:
                          'Balance: \$${remainingBalance.toStringAsFixed(2)} / \$${monthlyIncome.toStringAsFixed(2)}',
                      allocated: monthlyIncome,
                      expenses: monthlyExpenses,
                      showAddButton: true,
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Card 2 - Transportation
                  Card(
                    color: Colors.white,
                    elevation: 5.0,
                    child: CategoryChart(
                      categoryName: 'Transportation',
                      allocated: (transportationDiv / 100) * monthlyIncome,
                      expenses: transportationExpenses,
                      showAddButton: false,
                    ),
                  ),
                  TransportationExpensesList(),
                  SizedBox(height: 16.0),

                  // Card 3 - Food
                  Card(
                    color: Colors.white,
                    elevation: 5.0,
                    child: CategoryChart(
                      categoryName: 'Food',
                      allocated: (foodDiv / 100) * monthlyIncome,
                      expenses: foodExpenses,
                      showAddButton: false,
                    ),
                  ),
                  FoodExpensesList(),
                  SizedBox(height: 16.0),

                  // Card 4 - Housing
                  Card(
                    color: Colors.white,
                    elevation: 5.0,
                    child: CategoryChart(
                      categoryName: 'Housing',
                      allocated: (housingDiv / 100) * monthlyIncome,
                      expenses: housingExpenses,
                      showAddButton: false,
                    ),
                  ),
                  HousingExpensesList(),
                  SizedBox(height: 16.0),

                  // Card 5 - Personal
                  Card(
                    color: Colors.white,
                    elevation: 5.0,
                    child: CategoryChart(
                      categoryName: 'Personal',
                      allocated: (personalDiv / 100) * monthlyIncome,
                      expenses: personalExpenses,
                      showAddButton: false,
                    ),
                  ),
                  PersonalExpensesList(),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
    );
  }
}

class CategoryChart extends StatelessWidget {
  final String categoryName;
  final double allocated;
  final double expenses;
  final bool showAddButton;

  CategoryChart({
    required this.categoryName,
    required this.allocated,
    required this.expenses,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final double totalWidth = 300.0;
    final double totalAmount = allocated + expenses;

    double allocatedWidth = (expenses / allocated) * totalWidth;
    if (expenses == allocated || expenses > allocated) {
      allocatedWidth = totalWidth - 2;
    }

    return Column(
      children: [
        Text(
          categoryName,
          style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Container(
          height: 20.0,
          width: totalWidth,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            children: [
              Container(
                width: allocatedWidth,
                color: expenses > allocated ? Colors.red : Colors.black,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0),
        if (!showAddButton)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), // Add horizontal padding
                    child: Text(
                      'Allocated: \$${allocated.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), // Add horizontal padding
                    child: Text(
                      'Expenses: \$${expenses.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
            ],
          ),
        SizedBox(height: 16.0),
        if (showAddButton)
          Padding(
            padding: const EdgeInsets.only(top: 10.0), // Adjust top padding
            child: OutlinedButton(
              onPressed: () {
                _showAddExpenseDialog(context);
              },
              child: Text(
                'Add Expense',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 100),
                backgroundColor: Colors.black, // Stretch the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        SizedBox(height: 10.0),
      ],
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: AddExpenseForm(),
        );
      },
    );
  }
}

class AddExpenseForm extends StatefulWidget {
  @override
  _AddExpenseFormState createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  String? selectedCategory;
  String? description;
  String? amount;
  List<String> categories = ['Transportation', 'Food', 'Housing', 'Personal'];

  final _firestore = FirebaseFirestore.instance; // Firestore instance

  Future<void> _addExpenseToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null &&
        selectedCategory != null &&
        description != null &&
        amount != null) {
      final DocumentReference userDocRef =
          _firestore.collection('users').doc(user.uid);

      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        final List<dynamic> currentExpenses =
            (userData?['expenses'] as List<dynamic>?) ?? [];

        Map<String, dynamic> expenseData = {
          'category': selectedCategory,
          'name': description,
          'amount': amount,
          'occurrence': null,
        };

        currentExpenses.add(expenseData);

        await userDocRef.update({'expenses': currentExpenses});

        print('Expense added to Firestore');
      } else {
        print('User document not found.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: TextStyle(fontSize: 16.0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            onChanged: (value) {
              description = value;
            },
            style: TextStyle(fontSize: 16.0),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(fontSize: 16.0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            onChanged: (value) {
              if (value.isNotEmpty) {
                amount = value;
              }
            },
            style: TextStyle(fontSize: 16.0),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Amount (\$)',
              labelStyle: TextStyle(fontSize: 16.0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              _addExpenseToFirestore();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'Add',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
