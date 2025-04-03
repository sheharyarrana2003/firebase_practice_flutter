import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/Screens/home_screen.dart';
import 'package:firebase_practice/Screens/singup_screen.dart';
import 'package:firebase_practice/modules/cutom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool isLoading = false;

  Future<void> signInFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(
          "${loginResult.accessToken?.tokenString}",
        );

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        if (userCredential.additionalUserInfo!.isNewUser) {
          await FirebaseAuth.instance.signOut();
          await FacebookAuth.instance.logOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No account found. Please sign up first.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Facebook Sign-In Failed")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> signInGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.additionalUserInfo!.isNewUser) {
        await FirebaseAuth.instance.signOut();
        await googleSignIn.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No account found. Please sign up first.")),
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign In Failed: $e")),
      );
    }
  }

  Future<void> logIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setBool("isLogIn", true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: ${e.message}")),
        );
      }
      setState(() {
        isLoading = false;
      });
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 80 : 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "LOG IN",
                        style: TextStyle(
                          fontSize: isWideScreen ? 40 : 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: "Email",
                        hint: "Enter your email",
                        controller: _emailController,
                        isPass: false,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: "Password",
                        hint: "Enter your password",
                        controller: _passController,
                        isPass: true,
                      ),
                      const SizedBox(height: 30),

                      InkWell(
                        onTap: logIn,
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
                              "Log In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWideScreen ? 22 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: signInGoogle,
                            borderRadius: BorderRadius.circular(50),
                            child: CircleAvatar(
                              radius: isWideScreen ? 30 : 25,
                              backgroundColor: Colors.white,
                              backgroundImage: const AssetImage("assets/images/google.png"),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blueGrey.withOpacity(0.5)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          InkWell(
                            onTap: signInFacebook,
                            borderRadius: BorderRadius.circular(50),
                            child: CircleAvatar(
                              radius: isWideScreen ? 30 : 25,
                              backgroundColor: Colors.white,
                              backgroundImage: const AssetImage("assets/images/fb.png"),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blueGrey.withOpacity(0.5)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                            },
                            child: Text(
                              "Sign Up",
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
            ),
          );
        },
      ),
    );
  }
}
