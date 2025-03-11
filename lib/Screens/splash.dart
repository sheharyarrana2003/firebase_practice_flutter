import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_practice/Screens/home_screen.dart';
import 'package:firebase_practice/Screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  Future<void> _navigateUser() async {
    await Future.delayed(Duration(seconds: 5));
    SharedPreferences pref=await SharedPreferences.getInstance();
    bool? isLogIn=pref.getBool("isLogIn");
    User? user=await FirebaseAuth.instance.currentUser;
    if (user == null || isLogIn==false) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginscreen()));
  }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => HomeScreen(),
        requestFocus: true,
        maintainState: false,
        allowSnapshotting: false,
        barrierDismissible: true
        ));
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Notely",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.blue.shade600),),
      ),
    );
  }
}