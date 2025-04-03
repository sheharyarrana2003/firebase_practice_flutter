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

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  Future<void> _navigateUser() async {
    await Future.delayed(const Duration(seconds: 3));

    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isLogIn = pref.getBool("isLogIn");
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null || isLogIn == false) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginscreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _opacityAnimation = Tween<double>(begin: 0, end: 2).animate(_controller);

    _controller.forward();
    _navigateUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double logoSize = constraints.maxWidth * 0.3;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                AnimatedContainer(
                  duration: const Duration(seconds: 4),
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade200,
                    boxShadow: [
                      BoxShadow(color: Colors.blue.shade600, blurRadius: 15, spreadRadius: 3),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.note_alt_rounded, // Note-taking icon
                      size: logoSize * 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Fading Animated Text
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    "Notely",
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 600 ? 50 : 30, // Adaptive text size
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Loading Indicator
                SizedBox(
                  width: constraints.maxWidth * 0.2,
                  child: LinearProgressIndicator(
                    color: Colors.blue.shade700,
                    backgroundColor: Colors.blue.shade100,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
