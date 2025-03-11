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
  bool isLoading=false;

Future<void> signInFacebook() async {
  try {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.status == LoginStatus.success) {
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(
        "${loginResult.accessToken?.tokenString}",
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      if (userCredential.additionalUserInfo!.isNewUser) {
      
      await FirebaseAuth.instance.signOut();
      await FacebookAuth.instance.logOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No account found with this email. Please sign up first.")),
      );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Facebook Sign-In Failed")),
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
    await googleSignIn.signOut(); // Ensure fresh sign-in

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; // User canceled sign-in

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
        SnackBar(content: Text("No account found with this email. Please sign up first.")),
      );
    } else {
    
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
        isLoading=true;
      });
      try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.toString().trim(),
      password: _passController.text.toString().trim()
      );
      SharedPreferences pref=await SharedPreferences.getInstance();
      await pref.setBool("isLogIn", true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
      
      }
      on FirebaseAuthException catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("LogIn Failed ${e.message}"))
        );
      }
      setState(() {
        isLoading=false;
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
                      "LOG IN",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    SizedBox(height: 30),
                    CustomTextField(
                        label: "Email",
                        hint: "Enter your email",
                        controller: _emailController,
                        isPass: false),
                    SizedBox(height: 20),
                    CustomTextField(
                        label: "Password",
                        hint: "Enter your password",
                        controller: _passController,
                        isPass: true),
                    SizedBox(height: 40),
                    InkWell(
                      onTap: (){
                        logIn();
                      },
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
                          child: isLoading ? CircularProgressIndicator() : Text(
                            "Log In",
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
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",style: TextStyle(fontSize: 16,color: Colors.grey),),
                        TextButton(onPressed: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                        }, child: Text("Sign Up",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.blue.shade600),))
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
