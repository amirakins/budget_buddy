import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data.dart';

class TestPage3 extends StatefulWidget {
  @override
  _TestPage3State createState() => _TestPage3State();
}

class _TestPage3State extends State<TestPage3> {
  String paymentAmount = "";

  @override
  void initState() {
    super.initState();

    // Fetch payment amount from Firebase
    /*
    PaymentData.fetchPaymentAmount().then((value) {
      setState(() {
        paymentAmount = value;
      });
    });
    */
  }

  @override
  Widget build(BuildContext context) {
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
            ElevatedButton(
              onPressed: () {
                _showAddExpenseDialog(context);
              },
              child: Text('Add Expense'),
            ),
            Text('Payment Amount: $paymentAmount'),
            Text("Transportation"),
            TransportationExpensesList(),
            Text("Food"),
            TransportationExpensesList(),
            Text("Housing"),
            TransportationExpensesList(),
            Text("Transportation"),
            TransportationExpensesList(),



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

class TransportationExpensesList extends StatelessWidget {
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
              final transportationExpenses = expenses
                  .where((expense) => expense['category'] == 'Transportation')
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  children: transportationExpenses.map((expense) {
                    return ListTile(
                      title: Text(expense['name'] ?? ''),
                      subtitle: Text('\$${expense['amount'] ?? ''}'),
                    );
                  }).toList(),
                ),
              );
            },
          );

        },
      );
    } else {
      return Container(); // Handle the case where the user is not logged in.
    }
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
