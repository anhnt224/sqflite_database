import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite_database/database/user_database.dart';
import 'package:sqflite_database/model/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Sqflite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> users = [];

  @override
  void initState() {
    refreshUsers();
    super.initState();
  }

  @override
  void dispose() {
    UserDatabase.instance.close();
    super.dispose();
  }

  void _onUpdated(User newUser) {
    addNewUser(newUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InputForm(
              onUpdated: _onUpdated,
            ),
            Expanded(
              child: ListView(
                children: List.generate(users.length, (index) {
                  final user = users[index];
                  return buildListTile(user);
                }),
              ),
            ),
          ],
        ));
  }

  ListTile buildListTile(User user) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text('id: ${user.id}'),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(user.name[0]),
        ),
      ),
      trailing: TextButton(
        child: const Icon(
          Icons.clear,
          color: Colors.red,
        ),
        onPressed: () {
          deleteUser(user.id);
        },
      ),
    );
  }

  Future addNewUser(User user) async {
    await UserDatabase.instance.create(user);
    refreshUsers();
  }

  Future refreshUsers() async {
    var userList = await UserDatabase.instance.getAllUsers();
    setState(() {
      users = userList;
    });
  }

  Future deleteUser(int id) async {
    await UserDatabase.instance.deleteUser(id);
    refreshUsers();
  }
}

class InputForm extends StatefulWidget {
  const InputForm({Key? key, required this.onUpdated}) : super(key: key);
  final ValueChanged<User> onUpdated;

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name invalid!';
                  }
                  return null;
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'age'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Age invalid!';
                  }
                  return null;
                },
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                addNewUser();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addNewUser() {
    var name = nameController.value.text;
    var age = ageController.value.text;

    nameController.clear();
    ageController.clear();
    int id = Random().nextInt(1000);
    var user = User(id, name, int.tryParse(age) ?? 0);
    widget.onUpdated(user);
  }
}
