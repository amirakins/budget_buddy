import 'package:budget_buddy/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data.dart';
import 'home.dart';
import 'login.dart';

class EditIncomeDivisionPage extends StatefulWidget {
  @override
  _EditIncomeDivisionPageState createState() => _EditIncomeDivisionPageState();
}


class _EditIncomeDivisionPageState extends State<EditIncomeDivisionPage> {

  // Variable declarations, etc.
  String paymentAmount = "";
  String paymentFrequency = "";
  double monthlyIncome = 0.00;
  double savings = 0;

  @override
  void initState() {
    super.initState();
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

      Map<String, dynamic> divisionData = {
        'incomeDivision': categoryData[selectedOption!],
      };

      userDoc.set(divisionData, SetOptions(merge: true)).then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
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
    final totalIncome = monthlyIncome; // Access totalIncome from the widget

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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Edit Income Division',
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
              ),
            ),
            SizedBox(height: 24.0),
            if (selectedOption == 'Custom')
              Text(
                'Enter Percentage for Each Category:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
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
                        decoration: InputDecoration(
                          labelText: '%',
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
                'Save',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
