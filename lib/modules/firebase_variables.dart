import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseVariables {
  static final userCollection=FirebaseFirestore.instance.collection("Users");
  static final notesCollection=FirebaseFirestore.instance.collection("Notes");
  static User? get currentUser=>FirebaseAuth.instance.currentUser;
}
