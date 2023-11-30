import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'additional_info2.dart';
import 'data.dart';
import 'login.dart';

class SavingsInputPage extends StatefulWidget {
  @override
  _SavingsInputPageState createState() => _SavingsInputPageState();
}

class _SavingsInputPageState extends State<SavingsInputPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  TextEditingController savingsController = TextEditingController();
  double monthlySavingsAmount = 0.0;
  double savingsPercentage = 0.0;
  bool isPercentage = true;
  var paymentAmount;
  String paymentFrequency = "";
  double monthlyIncome = 0.0;


  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Initialize Firestore
  String? userId;

  @override
  void initState() {
    super.initState();
    // Check if a user is logged in
    if (user != null) {
      userId = user?.uid; // Set userId to the UID of the logged-in user
    } else {
      // Handle the case where no user is logged in
      print('No user is logged in.');
    }
    PaymentData.streamTotalIncome().listen((value) {
      setState(() {
        monthlyIncome = value ?? 0;
      });
    });
  }

  void calculateSavingsAmount() {
    if (isPercentage) {
      monthlySavingsAmount = double.parse(((savingsPercentage / 100) * monthlyIncome).toStringAsFixed(2));
    }
  }

  void _navigateToAdditionalInfo2() {
    // Your existing code to save data to Firestore
    calculateSavingsAmount();
    saveToFirestore();

    // Now, navigate to additional_info2.dart
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdditionalInfo2Page()),
    );
  }

  // Replace this with your actual monthly income source

  Future<void> saveToFirestore() async {
    if (userId != null) {
      final userData = {
        'savingsAmount': monthlySavingsAmount,
        'savingsPercentage': savingsPercentage,
      };

      // Use the "update" method to add data without clearing existing data
      await firestore.collection('users').doc(userId).update(userData);
    } else {
      // Handle the case where no user is logged in
      print('Cannot save to Firestore: No user is logged in.');
    }
  }

  @override
  void dispose() {
    savingsController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Input Your Monthly Savings Goal',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.number,
              controller: savingsController,
              decoration: InputDecoration(
                labelText: 'Enter Savings Amount (\$)',
                hintText: '0',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  monthlySavingsAmount = double.tryParse(value) ?? 0.0;
                  savingsPercentage = (monthlySavingsAmount / monthlyIncome) * 100;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Monthly Savings Amount: \$${monthlySavingsAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8.0),
            Text(
              'Savings Percentage: ${savingsPercentage.toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                calculateSavingsAmount();
                saveToFirestore();
                _navigateToAdditionalInfo2();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 0),
                primary: Colors.black,
              ),
              child: Text(
                'Add',
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

void main() {
  runApp(MaterialApp(
    home: SavingsInputPage(),
  ));
}
