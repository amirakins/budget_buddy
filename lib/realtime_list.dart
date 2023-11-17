import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data.dart';

class RealTimeDataPage extends StatefulWidget {
  @override
  _RealTimeDataPageState createState() => _RealTimeDataPageState();
}

class _RealTimeDataPageState extends State<RealTimeDataPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class PersonalExpensesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return CircularProgressIndicator();
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return CircularProgressIndicator();
              }

              final expenses = (snapshot.data!['expenses'] as List) ?? [];
              final personalExpenses = expenses
                  .where((expense) => expense['category'] == 'Personal')
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  children: personalExpenses.map((expense) {
                    return ListTile(
                      title: Text(
                        expense['name'] ?? '',
                        style: TextStyle(fontSize: 25),
                      ),
                      subtitle: Text(
                        '\$${expense['amount'] ?? ''}',
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _showDeleteExpenseDialog(context, 'Personal', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black, // Set the background color to black
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white), // Set text color to white
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );

        },
      );
    } else {
      return Container(); // Handle the case where the user is not logged in.
    }
  }
  void _deleteExpense(String category, Map<String, dynamic> expense) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users').doc(user.uid);

      // Fetch the user's document
      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          // Get the current expenses array
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ?? [];

          // Find the index of the expense to be deleted
          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          // Remove the selected expense
          if (index != -1) {
            currentExpenses.removeAt(index);

            // Update the expenses array in the user's document
            userDocRef.update({'expenses': currentExpenses});

            // Optionally, you can update the UI or perform additional operations.
            print('Expense deleted');
          } else {
            print('Expense not found');
          }
        } else {
          print('User document not found.');
        }
      });
    }
  }
  void _showDeleteExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(category, expense);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class HousingExpensesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return CircularProgressIndicator();
          }

          //final expenses = (snapshot.data!['expenses'] as List) ?? [];

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return CircularProgressIndicator();
              }

              final expenses = (snapshot.data!['expenses'] as List) ?? [];
              final housingExpenses = expenses
                  .where((expense) => expense['category'] == 'Housing')
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  children: housingExpenses.map((expense) {
                    return ListTile(
                      title: Text(
                        expense['name'] ?? '',
                        style: TextStyle(fontSize: 25),
                      ),
                      subtitle: Text(
                        '\$${expense['amount'] ?? ''}',
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _showDeleteExpenseDialog(context, 'Housing', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black, // Set the background color to black
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white), // Set text color to white
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );

        },
      );
    } else {
      return Container(); // Handle the case where the user is not logged in.
    }
  }
  void _deleteExpense(String category, Map<String, dynamic> expense) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users').doc(user.uid);

      // Fetch the user's document
      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          // Get the current expenses array
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ?? [];

          // Find the index of the expense to be deleted
          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          // Remove the selected expense
          if (index != -1) {
            currentExpenses.removeAt(index);

            // Update the expenses array in the user's document
            userDocRef.update({'expenses': currentExpenses});

            // Optionally, you can update the UI or perform additional operations.
            print('Expense deleted');
          } else {
            print('Expense not found');
          }
        } else {
          print('User document not found.');
        }
      });
    }
  }
  void _showDeleteExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(category, expense);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class FoodExpensesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return CircularProgressIndicator();
          }
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return CircularProgressIndicator();
              }

              final expenses = (snapshot.data!['expenses'] as List) ?? [];
              final foodExpenses = expenses
                  .where((expense) => expense['category'] == 'Food')
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  children: foodExpenses.map((expense) {
                    return ListTile(
                      title: Text(
                        expense['name'] ?? '',
                        style: TextStyle(fontSize: 25),
                      ),
                      subtitle: Text(
                        '\$${expense['amount'] ?? ''}',
                        style: TextStyle(fontSize: 20),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _showDeleteExpenseDialog(context, 'Food', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black, // Set the background color to black
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white), // Set text color to white
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );

        },
      );
    } else {
      return Container(); // Handle the case where the user is not logged in.
    }
  }
  void _deleteExpense(String category, Map<String, dynamic> expense) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users').doc(user.uid);

      // Fetch the user's document
      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          // Get the current expenses array
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ?? [];

          // Find the index of the expense to be deleted
          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          // Remove the selected expense
          if (index != -1) {
            currentExpenses.removeAt(index);

            // Update the expenses array in the user's document
            userDocRef.update({'expenses': currentExpenses});

            // Optionally, you can update the UI or perform additional operations.
            print('Expense deleted');
          } else {
            print('Expense not found');
          }
        } else {
          print('User document not found.');
        }
      });
    }
  }
  void _showDeleteExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(category, expense);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
class TransportationExpensesList extends StatefulWidget {
  @override
  _TransportationExpensesListState createState() => _TransportationExpensesListState();
}

class _TransportationExpensesListState extends State<TransportationExpensesList> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return CircularProgressIndicator();
          }

          final expenses = (snapshot.data!['expenses'] as List) ?? [];

          return SingleChildScrollView(
            child: Column(
              children: expenses.map((expense) {
                if (expense['category'] == 'Transportation') {
                  return ListTile(
                    title: Text(
                      expense['name'] ?? '',
                      style: TextStyle(fontSize: 25),
                    ),
                    subtitle: Text(
                        '\$${expense['amount'] ?? ''}',
                      style: TextStyle(fontSize: 20),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _showDeleteExpenseDialog(context, 'Transportation', expense);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black, // Set the background color to black
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white), // Set text color to white
                      ),
                    ),
                  );
                } else {
                  return Container(); // Return an empty container for non-Transportation expenses
                }
              }).toList(),
            ),
          );
        },
      );
    } else {
      return Container(); // Handle the case where the user is not logged in.
    }
  }

  void _showDeleteExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Expense'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(category, expense);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(String category, Map<String, dynamic> expense) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users').doc(user.uid);

      // Fetch the user's document
      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          // Get the current expenses array
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ?? [];

          // Find the index of the expense to be deleted
          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          // Remove the selected expense
          if (index != -1) {
            currentExpenses.removeAt(index);

            // Update the expenses array in the user's document
            userDocRef.update({'expenses': currentExpenses});

            // Optionally, you can update the UI or perform additional operations.
            print('Expense deleted');
          } else {
            print('Expense not found');
          }
        } else {
          print('User document not found.');
        }
      });
    }
  }
}