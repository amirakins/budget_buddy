import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentData {
  static Stream<Map<String, dynamic>?> streamIncomeDivision() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserUID = user.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUID);

      return userDocRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return (snapshot.data() as Map<String, dynamic>?)?['incomeDivision'];
        } else {
          return null;
        }
      });
    } else {
      return Stream.value(null);
    }
  }

  static Stream<String> streamPaymentAmount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserUID = user.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUID);

      return userDocRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return (snapshot.data() as Map<String, dynamic>)?['paymentAmount'] ?? "Default Value";
        } else {
          return "User document not found";
        }
      });
    } else {
      return Stream.value("User not authenticated");
    }
  }

  static Stream<double> streamTotalIncome() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserUID = user.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUID);

      return userDocRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return (snapshot.data() as Map<String, dynamic>)?['totalIncome'] ?? 0.0;
        } else {
          return 0.0;
        }
      });
    } else {
      return Stream.value(0.0);
    }
  }

  static Stream<double> streamSavings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserUID = user.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUID);

      return userDocRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return (snapshot.data() as Map<String, dynamic>)?['savingsAmount'] ?? 0.0;
        } else {
          return 0.0;
        }
      });
    } else {
      return Stream.value(0.0);
    }
  }

  static Stream<List<Map<String, dynamic>>> streamExpenses() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserUID = user.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUID);

      return userDocRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          List<dynamic> expensesData = (snapshot.data() as Map<String, dynamic>)?['expenses'] ?? [];

          List<Map<String, dynamic>> expenses = expensesData.map((expense) {
            return {
              'amount': expense['amount'] ?? "Default Amount",
              'category': expense['category'] ?? "Default Category",
              'name': expense['name'] ?? "Default Name",
              'occurrence': expense['occurrence'] ?? "Default Occurrence",
            };
          }).toList();

          return expenses;
        } else {
          return [];
        }
      });
    } else {
      return Stream.value([]);
    }
  }

  static Stream<String> streamPaymentFrequency() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserUID = user.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUID);

      return userDocRef.snapshots().map((snapshot) {
        if (snapshot.exists) {
          return (snapshot.data() as Map<String, dynamic>)?['paymentFrequency'] ?? "Default Value";
        } else {
          return "User document not found";
        }
      });
    } else {
      return Stream.value("User not authenticated");
    }
  }
}
