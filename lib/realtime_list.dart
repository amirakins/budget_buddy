import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RealTimeDataPage extends StatefulWidget {
  @override
  _RealTimeDataPageState createState() => _RealTimeDataPageState();
}

class _RealTimeDataPageState extends State<RealTimeDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: PersonalExpensesList(),
    );
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

          final expenses = (snapshot.data!['expenses'] as List) ?? [];
          final personalExpenses = expenses
              .where((expense) => expense['category'] == 'Personal')
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: personalExpenses.map((expense) {
                return ListTile(
                  title: Text(
                    expense['name'].toUpperCase() ?? '',
                    style: TextStyle(fontSize: 25),
                  ),
                  subtitle: Text(
                    '\$${double.parse(expense['amount'].toUpperCase() ?? '0.0').toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showEditExpenseDialog(context, 'Personal', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteExpenseDialog(
                              context, 'Personal', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ??
              [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses.removeAt(index);
            userDocRef.update({'expenses': currentExpenses});
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

  void _showEditExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    nameController.text = expense['name'] ?? '';
    amountController.text = expense['amount']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: 'Amount (\$)',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _updateExpense(
                    category,
                    expense,
                    nameController.text,
                    amountController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateExpense(String category,
      Map<String, dynamic> expense,
      String updatedName,
      String updatedAmount,) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

          List<dynamic> currentExpenses =
              (userData?['expenses'] as List<dynamic>?) ?? [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses[index]['name'] = updatedName;
            currentExpenses[index]['amount'] = updatedAmount;
            userDocRef.update({'expenses': currentExpenses});
            print('Expense updated');
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

          final expenses = (snapshot.data!['expenses'] as List) ?? [];
          final housingExpenses = expenses
              .where((expense) => expense['category'] == 'Housing')
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: housingExpenses.map((expense) {
                return ListTile(
                  title: Text(
                    expense['name'].toUpperCase() ?? '',
                    style: TextStyle(fontSize: 25),
                  ),
                  subtitle: Text(
                    '\$${double.parse(expense['amount'] ?? '0.0').toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showEditExpenseDialog(context, 'Housing', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteExpenseDialog(
                              context, 'Housing', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ??
              [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses.removeAt(index);
            userDocRef.update({'expenses': currentExpenses});
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

  void _showEditExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    nameController.text = expense['name'] ?? '';
    amountController.text = expense['amount']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: 'Amount (\$)',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _updateExpense(
                    category,
                    expense,
                    nameController.text,
                    amountController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateExpense(String category,
      Map<String, dynamic> expense,
      String updatedName,
      String updatedAmount,) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

          List<dynamic> currentExpenses =
              (userData?['expenses'] as List<dynamic>?) ?? [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses[index]['name'] = updatedName;
            currentExpenses[index]['amount'] = updatedAmount;
            userDocRef.update({'expenses': currentExpenses});
            print('Expense updated');
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

          final expenses = (snapshot.data!['expenses'] as List) ?? [];
          final foodExpenses = expenses
              .where((expense) => expense['category'] == 'Food')
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: foodExpenses.map((expense) {
                return ListTile(
                  title: Text(
                    expense['name'].toUpperCase() ?? '',
                    style: TextStyle(fontSize: 25),
                  ),
                  subtitle: Text(
                    '\$${double.parse(expense['amount'] ?? '0.0').toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showEditExpenseDialog(context, 'Food', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteExpenseDialog(
                              context, 'Food', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ??
              [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses.removeAt(index);
            userDocRef.update({'expenses': currentExpenses});
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

  void _showEditExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    nameController.text = expense['name'] ?? '';
    amountController.text = expense['amount']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: 'Amount (\$)',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _updateExpense(
                    category,
                    expense,
                    nameController.text,
                    amountController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateExpense(String category,
      Map<String, dynamic> expense,
      String updatedName,
      String updatedAmount,) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

          List<dynamic> currentExpenses =
              (userData?['expenses'] as List<dynamic>?) ?? [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses[index]['name'] = updatedName;
            currentExpenses[index]['amount'] = updatedAmount;
            userDocRef.update({'expenses': currentExpenses});
            print('Expense updated');
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
class TransportationExpensesList extends StatelessWidget {
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
          final transportationExpenses = expenses
              .where((expense) => expense['category'] == 'Transportation')
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: transportationExpenses.map((expense) {
                return ListTile(
                  title: Text(
                    expense['name'].toUpperCase() ?? '',
                    style: TextStyle(fontSize: 25),
                  ),
                  subtitle: Text(
                    '\$${double.parse(expense['amount'] ?? '0.0').toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showEditExpenseDialog(context, 'Transportation', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteExpenseDialog(
                              context, 'Transportation', expense);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData = userDoc.data() as Map<
              String,
              dynamic>?;

          final List<dynamic> currentExpenses = (userData?['expenses'] as List<
              dynamic>?) ??
              [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses.removeAt(index);
            userDocRef.update({'expenses': currentExpenses});
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

  void _showEditExpenseDialog(BuildContext context, String category,
      Map<String, dynamic> expense) {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    nameController.text = expense['name'] ?? '';
    amountController.text = expense['amount']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Expense',
            textAlign: TextAlign.center,
          ),
          content: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: 'Amount (\$)',
                    labelStyle: TextStyle(fontSize: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _updateExpense(
                    category,
                    expense,
                    nameController.text,
                    amountController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateExpense(String category,
      Map<String, dynamic> expense,
      String updatedName,
      String updatedAmount,) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

          List<dynamic> currentExpenses =
              (userData?['expenses'] as List<dynamic>?) ?? [];

          int index = currentExpenses.indexWhere((exp) =>
          exp['category'] == category &&
              exp['name'] == expense['name'] &&
              exp['amount'] == expense['amount']);

          if (index != -1) {
            currentExpenses[index]['name'] = updatedName;
            currentExpenses[index]['amount'] = updatedAmount;
            userDocRef.update({'expenses': currentExpenses});
            print('Expense updated');
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