import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data.dart';
import 'home.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  // Variable declarations, etc.
  String paymentAmount = "";
  String paymentFrequency = "";
  double monthlyIncome = 0.00;
  List<dynamic> expenses = [];
  Map<String, dynamic>? incomeDivision;
  Map<String, List<Map<String, dynamic>>> expensesByCategory = {};
  double savings = 0;

  late Stream<QuerySnapshot> expenseStream; // Stream to listen to expenses

  @override
  void initState() {
    super.initState();

    // Initialize Firestore streams
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? uid = user?.uid;

    expenseStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .snapshots();

    // Initialize categories
    if (expensesByCategory.isEmpty) {
      expensesByCategory["Food"] = [];
      expensesByCategory["Transportation"] = [];
      expensesByCategory["Personal"] = [];
      expensesByCategory["Housing"] = [];
    }

    // Fetch payment data
    /*
    PaymentData.fetchPaymentFrequency().then((value) {
      setState(() {
        paymentFrequency = value ?? "";
      });
    });

    PaymentData.fetchSavings().then((value) {
      setState(() {
        savings = value ?? 0;
      });
    });

    PaymentData.fetchPaymentAmount().then((value) {
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

    PaymentData.fetchExpenses().then((value) {
      setState(() {
        expenses = value ?? [];
      });
    });

    PaymentData.fetchIncomeDivision().then((value) {
      setState(() {
        incomeDivision = value;
      });
    });*/
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
      double amount = double.parse(expense['amount'] ?? "0.0");

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
        expensesByCategory['Food']!.add({'name': expense['name'], 'monthlyExpense': amount});
      } else if (category == "Housing") {
        expensesByCategory['Housing']!.add({'name': expense['name'], 'monthlyExpense': amount});
      } else if (category == "Personal") {
        expensesByCategory['Personal']!.add({'name': expense['name'], 'monthlyExpense': amount});
      } else if (category == "Transportation") {
        expensesByCategory['Transportation']!.add({'name': expense['name'], 'monthlyExpense': amount});
      }
    }

    var remainingBalance = (monthlyExpenses - monthlyIncome) * -1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Buddy'),
      ),
      body: paymentAmount.isEmpty
          ? CircularProgressIndicator()
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Payment Amount: $paymentAmount'),
            ExpensesList(
              remainingBalance: remainingBalance,
              monthlyIncome: monthlyIncome,
              transportationDiv: transportationDiv,
              monthlyExpenses: monthlyExpenses,
              transportationExpenses: transportationExpenses,
              foodDiv: foodDiv,
              foodExpenses: foodExpenses,
              housingDiv: housingDiv,
              housingExpenses: housingExpenses,
              personalDiv: personalDiv,
              personalExpenses: personalExpenses,
              expensesByCategory: expensesByCategory,
            ),
            ElevatedButton(
              onPressed: () {
                _showAddExpenseDialog(context);
              },
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
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

class ExpensesList extends StatelessWidget {

  final double remainingBalance;
  final double monthlyIncome;
  final double transportationDiv;
  final double monthlyExpenses;
  final double transportationExpenses;
  final double foodDiv;
  final double foodExpenses;
  final double housingDiv;
  final double housingExpenses;
  final double personalDiv;
  final double personalExpenses;
  final Map<String, List<Map<String, dynamic>>> expensesByCategory;

  ExpensesList({
    required this.remainingBalance,
    required this.monthlyIncome,
    required this.transportationDiv,
    required this.monthlyExpenses,
    required this.transportationExpenses,
    required this.foodDiv,
    required this.foodExpenses,
    required this.housingDiv,
    required this.housingExpenses,
    required this.personalDiv,
    required this.personalExpenses,
    required this.expensesByCategory,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return CircularProgressIndicator();
          }

          final expenses = (snapshot.data!['expenses'] as List) ?? [];



          return Column(
            children: [
              CategoryChart(
                categoryName: 'Remaining Balance: \$$remainingBalance',
                allocated: monthlyIncome,
                expenses: monthlyExpenses,
                showAddButton: true,
              ),
              SizedBox(height: 16.0),
              CategoryChart(
                categoryName: 'Transportation',
                allocated: (transportationDiv / 100) * monthlyIncome,
                expenses: transportationExpenses,
                showAddButton: false,
              ),
              //transportation list
              for (var category in expensesByCategory.keys) ...[
                if (expensesByCategory[category]!.isNotEmpty && category == "Transportation")
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: expensesByCategory[category]!.length,
                    itemBuilder: (context, index) {
                      final expense = expensesByCategory[category]![index];
                      return Text('${expense['name']} \$${expense['monthlyExpense']}');
                    },
                  ),
              ],
              SizedBox(height: 16.0),
              CategoryChart(
                categoryName: 'Food',
                allocated: (foodDiv / 100) * monthlyIncome,
                expenses: foodExpenses,
                showAddButton: false,
              ),
              //food list
              for (var category in expensesByCategory.keys) ...[
                if (expensesByCategory[category]!.isNotEmpty && category == "Food")
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: expensesByCategory[category]!.length,
                    itemBuilder: (context, index) {
                      final expense = expensesByCategory[category]![index];
                      return Text('${expense['name']} \$${expense['monthlyExpense']}');
                    },
                  ),
              ],
              SizedBox(height: 16.0),
              CategoryChart(
                categoryName: 'Housing',
                allocated: (housingDiv / 100) * monthlyIncome,
                expenses: housingExpenses,
                showAddButton: false,
              ),
              //housing list
              for (var category in expensesByCategory.keys) ...[
                if (expensesByCategory[category]!.isNotEmpty && category == "Housing")
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: expensesByCategory[category]!.length,
                    itemBuilder: (context, index) {
                      final expense = expensesByCategory[category]![index];
                      return Text('${expense['name']} \$${expense['monthlyExpense']}');
                    },
                  ),
              ],
              SizedBox(height: 16.0),
              CategoryChart(
                categoryName: 'Personal',
                allocated: (personalDiv / 100) * monthlyIncome,
                expenses: personalExpenses,
                showAddButton: false,
              ),
              //personal list
              for (var category in expensesByCategory.keys) ...[
                if (expensesByCategory[category]!.isNotEmpty && category == "Personal")
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: expensesByCategory[category]!.length,
                    itemBuilder: (context, index) {
                      final expense = expensesByCategory[category]![index];
                      return Text('${expense['name']} \$${expense['monthlyExpense']}');
                    },
                  ),
              ],
            ],
          );
        },
      );
    } else {
      return Container(); // Handle the case where the user is not logged in.
    }
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

    final double allocatedWidth = (allocated / totalAmount) * totalWidth;
    final double expenseWidth = (expenses / totalAmount) * totalWidth;

    return Column(
      children: [
        Text(
          categoryName,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                width: allocatedWidth - 2,
                color: Colors.green,
              ),
              Container(
                width: expenseWidth,
                color: Colors.red,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0),
        if (!showAddButton)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Allocated: \$${allocated.toStringAsFixed(2)}'),
              Text('Expenses: \$${expenses.toStringAsFixed(2)}'),
            ],
          ),
        SizedBox(height: 16.0),
        if (showAddButton)
          ElevatedButton(
            onPressed: () {
              _showAddExpenseDialog(context);
            },
            child: Text('Add Expense'),
          ),
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

    if (user != null && selectedCategory != null && description != null && amount != null) {
      final DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

      // Fetch the user's document
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Get the current expenses array
        final Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        final List<dynamic> currentExpenses = (userData?['expenses'] as List<dynamic>?) ?? [];
        // Create a new expense
        Map<String, dynamic> expenseData = {
          'category': selectedCategory,
          'name': description,
          'amount': amount,
          'occurrence': null,
        };

        // Add the new expense to the current expenses array
        currentExpenses.add(expenseData);

        // Update the expenses array in the user's document
        await userDocRef.update({'expenses': currentExpenses});

        // Optionally, you can update the UI or clear the form.
        print('Expense added to Firestore');
      } else {
        print('User document not found.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedCategory,
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue;
            });
          },
          decoration: InputDecoration(labelText: 'Category'),
        ),
        TextFormField(
          onChanged: (value) {
            description = value;
          },
          decoration: InputDecoration(labelText: 'Description'),
        ),
        TextFormField(
          onChanged: (value) {
            if (value.isNotEmpty) {
              amount = value;
            }
          },
          decoration: InputDecoration(labelText: 'Amount'),
        ),
        ElevatedButton(
          onPressed: () {
            _addExpenseToFirestore(); // Call the function to add expense to Firestore
          },
          child: Text('Add Expense'),
        ),
      ],
    );
  }
}