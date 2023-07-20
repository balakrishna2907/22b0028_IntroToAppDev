import 'package:flutter/material.dart';

void main() {
  runApp(BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[300],
      ),
      home: BudgetHomePage(),
    );
  }
}

class BudgetHomePage extends StatefulWidget {
  @override
  _BudgetHomePageState createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  String? userName;
  double totalAmount = 0.0;
  List<Entry> entries = [];

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  void _getUserName() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _askUserName();
    });
  }

  void _askUserName() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: Text('Enter your name'),
          content: TextField(
            controller: nameController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                String name = nameController.text;
                if (name.isNotEmpty) {
                  setState(() {
                    userName = name;
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEntryConfirmation(int index) async {
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed) {
      _deleteEntry(index);
    }
  }

  void _deleteEntry(int index) {
    setState(() {
      totalAmount -= entries[index].amount;
      entries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
        centerTitle: true,
      ),
      body: Container(
        color: theme.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              if (userName != null && userName!.isNotEmpty)
                Text(
                  'Hello, $userName!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              SizedBox(height: 10),
              if (userName != null && userName!.isNotEmpty)
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                ),
              SizedBox(height: 20),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryListPage(entries: entries),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ₹${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEntryDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                double amount = double.tryParse(amountController.text) ?? 0.0;

                if (name.isNotEmpty && amount != 0.0) {
                  setState(() {
                    entries.add(Entry(name: name, amount: amount));
                    totalAmount += amount;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class Entry {
  String name;
  double amount;

  Entry({required this.name, required this.amount});
}

class EntryListPage extends StatelessWidget {
  final List<Entry> entries;

  EntryListPage({required this.entries});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('List of Entries'),
        centerTitle: true,
      ),
      body: Container(
        color: theme.primaryColor,
        child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _deleteEntryConfirmation(context, index);
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${entries[index].name}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      '₹${entries[index].amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteEntryConfirmation(BuildContext context, int index) async {
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed) {
      _deleteEntry(context, index);
    }
  }

  void _deleteEntry(BuildContext context, int index) {
    Entry deletedEntry = entries.removeAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedEntry.name} deleted.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
