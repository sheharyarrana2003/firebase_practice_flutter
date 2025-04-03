import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/Screens/home_screen.dart';
import 'package:firebase_practice/Screens/login_screen.dart';
import 'package:firebase_practice/modules/cutom_text_field.dart';
import 'package:firebase_practice/modules/firebase_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  bool isLoading = false;

  Future<void> signInFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email'],
      );
      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential("${loginResult.accessToken?.tokenString}");
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        User? user = userCredential.user;

        if (user != null) {
          String userId = user.uid;
          DocumentSnapshot userDoc =
          await FirebaseVariables.userCollection.doc(userId).get();

          if (!userDoc.exists) {
            await FirebaseVariables.userCollection.doc(userId).set({
              "uid": userId,
              "user_name": user.displayName ?? "No Name",
              "email": user.email ?? "No Email",
            });
          }
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> signInGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot userDoc =
        await FirebaseVariables.userCollection.doc(userId).get();

        if (!userDoc.exists) {
          await FirebaseVariables.userCollection.doc(userId).set({
            "uid": userId,
            "user_name": user.displayName ?? "No Name",
            "email": user.email ?? "No Email",
          });
        }
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Google Sign-In Failed: $e")));
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim());
        String userId = userCredential.user!.uid;
        await FirebaseVariables.userCollection.doc(userId).set({
          "uid": userId,
          "user_name": _userController.text.trim(),
          "email": _emailController.text.trim(),
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Sign Up Failed: $e")));
        print("Sign Up Failed: $e");
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: LayoutBuilder(

        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 100 : 14,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("SIGN UP", style: TextStyle(
                      fontSize: isWideScreen ? 40 : 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),),
                    SizedBox(height: 30),
                    CustomTextField(label: "User Name", hint: "Enter your user name", controller: _userController, isPass: false),
                    SizedBox(height: 20),
                    CustomTextField(label: "Email", hint: "Enter your email", controller: _emailController, isPass: false),
                    SizedBox(height: 20),
                    CustomTextField(label: "Password", hint: "Enter your password", controller: _passController, isPass: true),
                    SizedBox(height: 20),
                    CustomTextField(label: "Confirm Password", hint: "Confirm your password", controller: _confirmPassController, isPass: true),
                    SizedBox(height: 40),
                    InkWell(
                      onTap: _signUp,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: isWideScreen ? 180 : 130,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade900.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWideScreen ? 22 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(onTap: signInGoogle, child: Image.asset("assets/images/google.png", height: 50)),
                        SizedBox(width: 20),
                        GestureDetector(onTap: signInFacebook, child: Image.asset("assets/images/fb.png", height: 50)),
                      ],
                    ),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context, MaterialPageRoute(builder: (context) => Loginscreen()));
                          },
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        )
                      ],
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
