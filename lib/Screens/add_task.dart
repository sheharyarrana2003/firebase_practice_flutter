import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_practice/Screens/home_screen.dart';
import 'package:firebase_practice/modules/cutom_text_field.dart';
import 'package:firebase_practice/modules/firebase_variables.dart';
import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _desController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> addTask() async {
    if (_formKey.currentState!.validate()) {
      String uid = FirebaseVariables.currentUser!.uid;
      try {
        await FirebaseVariables.notesCollection.add({
          "uid": uid,
          "note": _noteController.text.toString().trim(),
          "description": _desController.text.toString().trim(),
          "time": FieldValue.serverTimestamp()
        }).then((onValue) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Note Added")),
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Add Note due to $e")),
        );
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade600,
          title: Text("Add Note", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white)),
          elevation: 4,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: Text(
                    "Create a New Note",
                    style: TextStyle(
                        color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: "Note",
                  hint: "Note",
                  controller: _noteController,
                  isPass: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please add a note";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: "Description",
                  hint: "Description",
                  controller: _desController,
                  isPass: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please add a description";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    addTask();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Add Note",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
