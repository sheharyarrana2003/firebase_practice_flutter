import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_practice/Screens/add_task.dart';
import 'package:firebase_practice/Screens/profile_screen.dart';
import 'package:firebase_practice/modules/cutom_text_field.dart';
import 'package:firebase_practice/modules/firebase_variables.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _deleteNote(docID) {
    FirebaseVariables.notesCollection.doc(docID).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Note Deleted Successfully")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete note: $error")),
      );
    });
  }

  Stream<QuerySnapshot> _showNotes() {
    String? uid = FirebaseVariables.currentUser?.uid;
    return FirebaseVariables.notesCollection.where("uid", isEqualTo: uid).snapshots();
  }

  String _getFormattedTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return "No Time";
    }
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  void updateNote(String docId, String title, String des) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _noteController = TextEditingController(text: title);
    final TextEditingController _desController = TextEditingController(text: des);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Update Note", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: "Note",
                  hint: "Enter Note",
                  controller: _noteController,
                  isPass: false,
                  validator: (value) => value!.isEmpty ? "Please add note" : null,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  label: "Description",
                  hint: "Enter Description",
                  controller: _desController,
                  isPass: false,
                  validator: (value) => value!.isEmpty ? "Please add description" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseVariables.notesCollection.doc(docId).update({
                    "note": _noteController.text.trim(),
                    "description": _desController.text.trim(),
                    "time": FieldValue.serverTimestamp(),
                  }).then((_) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Note Updated Successfully")),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update note: $error")),
                    );
                  });
                }
              },
              child: Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: Text("Home Screen", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
            icon: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade600,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask())),
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _showNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("No Notes found"));
          if (snapshot.hasError) return Center(child: Text("Error getting Notes"));

          var notes = snapshot.data!.docs;

          return Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: GridView.builder(
              itemCount: notes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 2 : 1,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                var note = notes[index].data() as Map<String, dynamic>;
                String formatTime = _getFormattedTime(notes[index]["time"]);

                return GestureDetector(
                  onLongPress: () => updateNote(notes[index].id, note["note"], note["description"]),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade600, width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 3, blurRadius: 6, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note["note"] ?? "No Title",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Expanded(
                          child: Text(
                            note["description"] ?? "No Description",
                            style: TextStyle(color: Colors.grey.shade700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatTime, style: TextStyle(color: Colors.blue.shade600, fontSize: 12)),
                            IconButton(
                              onPressed: () => _deleteNote(notes[index].id),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
