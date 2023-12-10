import 'package:budget_buddy/profile.dart';
import 'package:flutter/material.dart';
import 'package:budget_buddy/savings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'login.dart';

class EditRecurringIncomePage extends StatefulWidget {
  @override
  _EditRecurringIncomeState createState() => _EditRecurringIncomeState();
}

class _EditRecurringIncomeState extends State<EditRecurringIncomePage> {
  String? selectedPaymentFrequency;
  TextEditingController paymentAmountController = TextEditingController();
  double totalIncome = 0.0;

  List<String> paymentFrequencies = ['Weekly', 'Bi-Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore and populate the form fields
    fetchUserData();
  }

  // Fetch user data from Firestore and populate the form fields
  void fetchUserData() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((userDoc) {
        if (userDoc.exists) {
          setState(() {
            selectedPaymentFrequency = userDoc.data()?['paymentFrequency'];
            paymentAmountController.text = userDoc.data()?['paymentAmount'] ?? '';
            calculateTotalIncome(); // Calculate total income based on fetched data
          });
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
      });
    }
  }

  void calculateTotalIncome() {
    final String paymentAmount = paymentAmountController.text;
    double paymentAmountValue = double.tryParse(paymentAmount) ?? 0.0;

    switch (selectedPaymentFrequency) {
      case 'Weekly':
        totalIncome = paymentAmountValue * 4; // Assuming 4 weeks in a month
        break;
      case 'Bi-Weekly':
        totalIncome = paymentAmountValue * 2;
        break;
      case 'Monthly':
        totalIncome = paymentAmountValue;
        break;
      default:
        totalIncome = 0.0;
    }
  }

  void _handleSubmit() {
    final String selectedFrequency = selectedPaymentFrequency ?? 'Weekly';
    String paymentAmount = paymentAmountController.text;
    double doublePaymentAmount = double.parse(paymentAmount);
    doublePaymentAmount = double.parse(doublePaymentAmount.toStringAsFixed(2));
    paymentAmount = doublePaymentAmount.toString();

    calculateTotalIncome();

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'paymentFrequency': selectedFrequency,
        'paymentAmount': paymentAmount,
        'totalIncome': double.parse(totalIncome.toStringAsFixed(2)),
      }).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      }).catchError((error) {
        print("Error saving data: $error");
      });
    } else {
      print('User is not signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Edit Your Income',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedPaymentFrequency,
              items: paymentFrequencies.map((String frequency) {
                return DropdownMenuItem<String>(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPaymentFrequency = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Payment Frequency',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(
                  fontSize: 22.0, // Set the desired label font size
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: paymentAmountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Payment Amount (\$)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(
                  fontSize: 22.0, // Set the desired label font size
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 0),
                primary: Colors.black,
              ),
              child: Text(
                'Save',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
