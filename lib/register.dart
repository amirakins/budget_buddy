import 'package:flutter/material.dart';
import 'additional_info.dart'; // Import the AdditionalInfoPage.
import 'package:firebase_auth/firebase_auth.dart'; // Import the Firebase Authentication package.

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _handleRegistration() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      _showAlertDialog('Registration Failed', 'Password and Confirm Password do not match.');
      return; // Prevent registration if passwords don't match.
    }

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Registration successful, navigate to AdditionalInfoPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdditionalInfoPage()),
        );
      } else {
        // Handle registration failure, e.g., show an error message.
        _showAlertDialog('Registration Failed', 'An error occurred. Please try again.');
      }
    } catch (e) {
      // Handle registration failure, e.g., show an error message.
      _showAlertDialog('Registration Failed', e.toString());
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 32.0),
            const Text(
              'Create Account,',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Sign up to get started!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0),
            InputField(
              controller: nameController,
              labelText: 'Name',
            ),
            SizedBox(height: 16.0),
            InputField(
              controller: emailController,
              labelText: 'Email',
            ),
            SizedBox(height: 16.0),
            InputField(
              controller: passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            InputField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            FormButton(
              text: 'Register',
              onPressed: _handleRegistration,
            ),
          ],
        ),
      ),
    );
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;

  const FormButton({this.text = '', this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onPressed as void Function()?,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}


class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final bool obscureText;
  final double labelFontSize; // Font size for the label text

  const InputField({
    required this.controller,
    this.labelText,
    this.obscureText = false,
    this.labelFontSize = 22.0, // Default label font size is 14.0
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: labelFontSize, // Set the label font size
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

