import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  String? _passwordMatchError; // Make sure this line is present

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final credentials = EmailAuthProvider.credential(
            email: user.email ?? '',
            password: _currentPasswordController.text,
          );

          await user.reauthenticateWithCredential(credentials);

          await user.updatePassword(_newPasswordController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password changed successfully.'),
            ),
          );

          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();

          setState(() {
            _passwordMatchError = null;
          });
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
          ),
        );
      }
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
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              InputField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              InputField(
                controller: _newPasswordController,
                labelText: 'New Password',
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              InputField(
                controller: _confirmNewPasswordController,
                labelText: 'Confirm New Password',
                obscureText: true,
                //errorText: _passwordMatchError,
              ),
              SizedBox(height: 24.0),
              FormButton(
                text: 'Change Password',
                onPressed: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
