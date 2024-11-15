// main.dart

import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SQLite Example',
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _addItem,
                  child: Text('Add Item'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dbHelper.getAllItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(item['description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editItem(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteItem(item['id']),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Add a new item to the database
  void _addItem() async {
    final name = _nameController.text;
    final description = _descriptionController.text;

    if (name.isNotEmpty && description.isNotEmpty) {
      await _dbHelper.insertItem({
        'name': name,
        'description': description,
      });

      _nameController.clear();
      _descriptionController.clear();
      setState(() {});
    }
  }

  // Edit an existing item in the database
  void _editItem(Map<String, dynamic> item) {
    _nameController.text = item['name'];
    _descriptionController.text = item['description'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _dbHelper.updateItem({
                  'id': item['id'],
                  'name': _nameController.text,
                  'description': _descriptionController.text,
                });

                _nameController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete an item from the database
  void _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    setState(() {});
  }
}
