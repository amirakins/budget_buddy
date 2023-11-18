import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/savings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class AdditionalInfoPage extends StatefulWidget {
  @override
  _AdditionalInfoPageState createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  String? selectedPaymentFrequency;
  TextEditingController paymentAmountController = TextEditingController();
  double totalIncome = 0.0;

  List<String> paymentFrequencies = ['Weekly', 'Bi-Weekly', 'Monthly'];

  void calculateTotalIncome() {
    final String paymentAmount = paymentAmountController.text;
    double paymentAmountValue = double.tryParse(paymentAmount) ?? 0.0;

    switch (selectedPaymentFrequency) {
      case 'Weekly':
        totalIncome = paymentAmountValue * 4;
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
    final String paymentAmount = paymentAmountController.text;

    calculateTotalIncome();

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'paymentFrequency': selectedFrequency,
        'paymentAmount': paymentAmount,
        'totalIncome': totalIncome, // Save totalIncome to Firestore
      }).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SavingsInputPage()),
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
        backgroundColor: Colors.black,
          foregroundColor: Colors.white
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Add Your Income Details',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: paymentAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount (\$)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
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
                'Next',
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
