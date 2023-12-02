import 'package:budget_buddy/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'additional_info2.dart';
import 'data.dart';
import 'login.dart';

class EditSavingsPage extends StatefulWidget {
  @override
  _EditSavingsPageState createState() => _EditSavingsPageState();
}

class _EditSavingsPageState extends State<EditSavingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  TextEditingController savingsController = TextEditingController();
  double monthlySavingsAmount = 0.0;
  double savingsPercentage = 0.0;
  bool isPercentage = true;
  double monthlyIncome = 1000.0;
  var paymentAmount;
  String paymentFrequency = "";

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userId = user?.uid;
    } else {
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

  void _navigateToProfile() {
    calculateSavingsAmount();
    saveToFirestore();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  Future<void> saveToFirestore() async {
    if (userId != null) {
      final userData = {
        'savingsAmount': monthlySavingsAmount,
        'savingsPercentage': savingsPercentage,
      };

      await firestore.collection('users').doc(userId).update(userData);
    } else {
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
            color: Colors.white,
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
              'Edit Your Monthly Savings Goal',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              controller: savingsController,
              decoration: InputDecoration(
                labelText: 'Enter Savings Amount (\$)',
                hintText: '0.00',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(
                  fontSize: 22.0, // Set the desired label font size
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  monthlySavingsAmount = double.tryParse(value) ?? 0.0;
                  savingsPercentage = (monthlySavingsAmount / monthlyIncome) * 100;
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
                _navigateToProfile();
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
                'Save',
                style: const TextStyle(color: Colors.white,
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
    home: EditSavingsPage(),
  ));
}
