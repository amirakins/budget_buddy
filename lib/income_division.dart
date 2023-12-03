import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'home.dart';
import 'login.dart';

class IncomeDivisionPage extends StatefulWidget {
  final double totalIncome;

  IncomeDivisionPage({required this.totalIncome});

  @override
  _IncomeDivisionPageState createState() => _IncomeDivisionPageState();
}

class _IncomeDivisionPageState extends State<IncomeDivisionPage> {
  String paymentAmount = "";
  String paymentFrequency = "";
  double monthlyIncome = 0.00;
  double savings = 0;

  @override
  void initState() {
    super.initState();
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

    PaymentData.streamTotalIncome().listen((value) {
      setState(() {
        monthlyIncome = value - savings ?? 0;
      });
    });
  }

  String? selectedOption = '25/25/25/25';
  List<String> presetOptions = ['25/25/25/25', '20/30/30/20', 'Custom'];
  Map<String, Map<String, double>> categoryData = {
    '25/25/25/25': {
      'Transportation': 25.0,
      'Food': 25.0,
      'Housing': 25.0,
      'Personal': 25.0,
    },
    '20/30/30/20': {
      'Transportation': 30.0,
      'Food': 30.0,
      'Housing': 20.0,
      'Personal': 20.0,
    },
    'Custom': {
      'Transportation': 0.0,
      'Food': 0.0,
      'Housing': 0.0,
      'Personal': 0.0,
    },
  };

  void _handleOptionChange(String? newValue) {
    setState(() {
      selectedOption = newValue;
    });
  }

  void _handlePercentageChange(String category, double percentage) {
    setState(() {
      categoryData[selectedOption!]![category] = percentage;
    });
  }

  void _navigateToHomePage() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      DocumentReference userDoc = users.doc(user.uid);

      if (selectedOption == 'Custom') {
        double totalPercentage = 0.0;

        // Calculate the total percentage entered by the user
        categoryData[selectedOption!]!.forEach((key, value) {
          totalPercentage += value;
        });

        // Check if the total percentage is equal to 100%
        if (totalPercentage != 100.0) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Validation Error'),
              content: Text('The total percentage must equal 100%. Please adjust your entries.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return; // Stop the execution if validation fails
        }
      }

      Map<String, dynamic> divisionData = {
        'incomeDivision': categoryData[selectedOption!],
      };

      userDoc.set(divisionData, SetOptions(merge: true)).then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
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
    final totalIncome = monthlyIncome;

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
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 32.0),
            const Text(
              'Income Division',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedOption,
              items: presetOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: _handleOptionChange,
              decoration: InputDecoration(
                labelText: 'Select Option',
                labelStyle: TextStyle(
                  fontSize: 22.0, // Set the desired label font size
                ),
              ),
            ),
            SizedBox(height: 24.0),
            if (selectedOption == 'Custom')
              for (final category in categoryData['25/25/25/25']!.keys)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(category),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        onChanged: (value) {
                          final percentage = double.tryParse(value) ?? 0.0;
                          _handlePercentageChange(category, percentage);
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        decoration: InputDecoration(
                          labelText: '%',
                          labelStyle: TextStyle(
                            fontSize: 22.0, // Set the desired label font size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            if (selectedOption != null && categoryData[selectedOption!] != null)
              DataTable(
                columns: <DataColumn>[
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Percentage')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: categoryData[selectedOption!]!.entries.map((entry) {
                  final percentage = entry.value;
                  final amount = (percentage / 100) * totalIncome;
                  return DataRow(
                    cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text('${percentage.toStringAsFixed(2)}%')),
                      DataCell(Text('\$${amount.toStringAsFixed(2)}')),
                    ],
                  );
                }).toList(),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _navigateToHomePage,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 0),
                primary: Colors.black,
              ),
              child: Text(
                'Complete',
                style: TextStyle(
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
