import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'income_division.dart';
import 'login.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: AdditionalInfo2Page(),
  ));
}

class AdditionalInfo2Page extends StatefulWidget {
  @override
  _AdditionalInfo2PageState createState() => _AdditionalInfo2PageState();
}

class _AdditionalInfo2PageState extends State<AdditionalInfo2Page> {
  List<Expense> expenses = [];
  TextEditingController expenseNameController = TextEditingController();
  String? selectedCategory;
  String? selectedOccurrence;
  TextEditingController expenseAmountController = TextEditingController();

  List<String> categories = ['Transportation', 'Food', 'Housing', 'Personal'];
  List<String> occurrences = ['Weekly', 'Bi-Weekly', 'Monthly'];

  void _addExpense() {
    final String name = expenseNameController.text;
    final String occurrence = selectedOccurrence ?? '';
    final String amount = expenseAmountController.text;

    if (name.isEmpty || selectedCategory == null || occurrence.isEmpty || amount.isEmpty) {
      return;
    }

    final Expense newExpense = Expense(name, selectedCategory!, occurrence, amount);
    setState(() {
      expenses.add(newExpense);
    });

    expenseNameController.clear();
    selectedCategory = null;
    selectedOccurrence = null;
    expenseAmountController.clear();
  }

  void _deleteExpense(Expense expense) {
    setState(() {
      expenses.remove(expense);
    });
  }

  void _navigateToNextScreen() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      DocumentReference userDoc = users.doc(user.uid);

      Map<String, dynamic> additionalInfo = {
        'expenses': expenses.map((e) => e.toMap()).toList(),
      };

      userDoc.set(additionalInfo, SetOptions(merge: true)).then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeDivisionPage(totalIncome: 0,)));
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lets Add Your Recurring Expenses'),
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
        backgroundColor: Colors.black,
          foregroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 10, // Add spacing between columns
          columns: [
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Occurrence')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Action')),
          ],
          rows: expenses.map((expense) {
            return DataRow(
              cells: [
                DataCell(Text(expense.category)),
                DataCell(
                  Tooltip(
                    message: expense.name, // The description to show on hover
                    child: Text(expense.name),
                  ),
                ),
                DataCell(Text(expense.occurrence)),
                DataCell(Text(expense.amount)),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Expense'),
                            content: Text('Are you sure you want to delete this expense?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  _deleteExpense(expense);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      floatingActionButton: Stack(
        children: [
        Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add Expense'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            items: categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black, // Set text color to black
                                  ),
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
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black, // Set dropdown text color to black
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: expenseNameController,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Description',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            maxLines: 2,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          DropdownButtonFormField<String>(
                            value: selectedOccurrence,
                            items: occurrences.map((String occurrence) {
                              return DropdownMenuItem<String>(
                                value: occurrence,
                                child: Text(
                                  occurrence,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black, // Set text color to black
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedOccurrence = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Occurrence',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black, // Set dropdown text color to black
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: expenseAmountController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _addExpense();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 0),
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
              foregroundColor: Colors.white
          ),
        ),
      ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: ElevatedButton(
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                  primary: Colors.black,
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
        ],
    ),
    );
  }
}

class Expense {
  final String name;
  final String category;
  final String occurrence;
  final String amount;

  Expense(this.name, this.category, this.occurrence, this.amount);

  Map<String, dynamic> toMap() {
  return {
  'name': name,
  'category': category,
  'occurrence': occurrence,
  'amount': amount,
  };
  }
}
