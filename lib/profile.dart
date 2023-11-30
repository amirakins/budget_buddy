import 'package:flutter/material.dart';
import 'change_password.dart';
import 'edit_savings.dart';
import 'home.dart';
import 'login.dart';
import 'notification.dart';
import 'edit_recurring_income.dart';
import 'edit_recurring_expenses.dart';
import 'edit_income_division.dart';
import 'test.dart';
import 'test2.dart';
import 'test3.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(color: Colors.white)),
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
          icon: Icon(Icons.home),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(

        padding: EdgeInsets.all(16.0),
        children: [
          _buildButton(context, 'Edit Savings Goal', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditSavingsPage()),
            );
            // Handle button tap for Recurring Income
          }),
          SizedBox(height: 16.0),
          _buildButton(context, 'Edit Recurring Income', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditRecurringIncomePage()),
            );
            // Handle button tap for Recurring Income
          }),
          SizedBox(height: 16.0),
          _buildButton(context, 'Edit Expenses', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditRecurringExpensesPage()),
            );
            // Handle button tap for Recurring Expenses
          }),
          SizedBox(height: 16.0),
          _buildButton(context, 'Edit Income Division', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditIncomeDivisionPage()),
            );
            // Handle button tap for Income Division
          }),
          SizedBox(height: 16.0),
          _buildButton(context, 'Change Password', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangePasswordPage()),
            );
            // Handle button tap for Profile
          }),
          SizedBox(height: 16.0),
          _buildButton(context, 'Notifications', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          }),
          /*SizedBox(height: 16.0),
          _buildButton(context, 'Test', () {
            Navigator.push(
              context,
              //MaterialPageRoute(builder: (context) => TestPage2()),
              MaterialPageRoute(builder: (context) => TestPage3()),
            );
          }),*/
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.black,
        onPrimary: Colors.white,
        padding: EdgeInsets.all(16.0),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}
