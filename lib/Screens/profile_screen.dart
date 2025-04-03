import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/Screens/image_screen.dart';
import 'package:firebase_practice/Screens/login_screen.dart';
import 'package:firebase_practice/modules/firebase_variables.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;

  Future<void> logOut() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', false);
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() {
      isLoading = false;
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Loginscreen()));
  }

  Stream<DocumentSnapshot> _getUserData() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseVariables.userCollection.doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImageScreen()));
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ))
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ));
            }
            if (!snapshot.hasData ||
                snapshot.data == null ||
                !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  "No User Data Found",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              );
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade700, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(height: 20),

                      // User Name
                      Text(
                        userData["user_name"] ?? "No Name",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // User Email
                      Text(
                        userData["email"] ?? "No Email",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),

                      // Editable Name
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(
                          userData["user_name"] ?? "No Name",
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing:
                        const Icon(Icons.edit, color: Colors.blueAccent),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),

                      // Editable Email
                      ListTile(
                        leading:
                        const Icon(Icons.email, color: Colors.blueAccent),
                        title: Text(
                          userData["email"] ?? "No Email",
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing:
                        const Icon(Icons.edit, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 30),

                      // Logout Button
                      InkWell(
                        onTap: logOut,
                        child: Container(
                          width: 140,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.blueAccent]),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Log Out",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
