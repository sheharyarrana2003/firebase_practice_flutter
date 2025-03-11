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

  // Future<UserCredential> signInFacebook() async {
  //  final LoginResult loginResult=await FacebookAuth.instance.login();
  //   final OAuthCredential facebookAuthCredential=FacebookAuthProvider.credential("${loginResult.accessToken?.tokenString}");
  //   return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  // }
 Future<void> signInFacebook() async {
  try {
    await FacebookAuth.instance.logOut();  // Ensure previous session is cleared

    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: ['email'], 
      loginBehavior: LoginBehavior.dialogOnly, // Forces account selection
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
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Facebook Sign-In Failed")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}



  Future<void> signInGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return;
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseVariables.userCollection.doc(userId).get();

      if (!userDoc.exists) {
        await FirebaseVariables.userCollection.doc(userId).set({
          "uid": userId,
          "user_name": user.displayName ?? "No Name",
          "email": user.email ?? "No Email",
        });
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Sign-In Failed: $e")),
    );
  }
}

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.toString().trim(),
                password: _passController.text.toString().trim());
        String userId = userCredential.user!.uid;
        await FirebaseVariables.userCollection.doc(userId).set({
          "uid": userId,
          "user_name": _userController.text.toString().trim(),
          "email": _emailController.text.toString().trim(),
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign Up Failed: $e")),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    SizedBox(height: 30),
                    CustomTextField(
                        label: "User Name",
                        hint: "Enter your user name",
                        controller: _userController,
                        isPass: false,
                        validator: (value){
                          if(value==null || value.isEmpty){
                            return "User name is empty";
                          }
                          return null;
                        },),
                    SizedBox(height: 20),
                    CustomTextField(
                        label: "Email",
                        hint: "Enter your email",
                        controller: _emailController,
                        isPass: false,
                        validator: (value) {
                          if(value==null || value.isEmpty){
                            return "Email is required";
                          }
                           if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                        },),
                    SizedBox(height: 20),
                    CustomTextField(
                        label: "Password",
                        hint: "Enter your password",
                        controller: _passController,
                        isPass: true,
                        validator: (value) {
                          if(value==null || value.isEmpty){
                            return "Password is required";
                          }
                          if(value.length<6){
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },),
                    SizedBox(height: 20),
                    CustomTextField(
                        label: "Confirm Password",
                        hint: "Confirm your password",
                        controller: _confirmPassController,
                        isPass: true,
                        validator: (value) {
                          if(value==null || value.isEmpty){
                            return "Please confirm your password";
                          }
                          if(value!=_passController.text){
                            return "Password mis match";
                          }
                          return null;
                        },),
                    SizedBox(height: 40),
                    InkWell(
                      onTap: isLoading ? null : _signUp,
                      child: Container(
                        width: 130,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.white.withOpacity(0.5),
                                  color: Colors.white,
                                  strokeWidth: 4.0,
                                  strokeAlign: 0.0,
                                  semanticsLabel: "Signing Up...",
                                  semanticsValue: "Loading",
                                  strokeCap: StrokeCap.round,
                                  trackGap: 2.0,
                                )
                              : Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
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
                         InkWell(
                               onTap: signInGoogle, 
                               borderRadius: BorderRadius.circular(50), 
                               child: CircleAvatar(
                                 radius: 25, 
                                 backgroundColor: Colors.white,
                                 backgroundImage: AssetImage("assets/images/google.png"),
                               ),
                             ),
                              SizedBox(width: 10),
                         InkWell(
                               onTap: signInFacebook, 
                               borderRadius: BorderRadius.circular(50), 
                               child: CircleAvatar(
                                 radius: 25, 
                                 backgroundColor: Colors.white,
                                 backgroundImage: AssetImage("assets/images/fb.png"),
                               ),
                             ),
                       ],
                     ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Loginscreen()));
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
