import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_bottomNAVbar.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/customDoctor_bottomNAVbar.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/customNurse_bottomNAVbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart'; // Import page transition package if not already imported

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Define animation
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start the animation
    _controller.forward();

    // Check for the token and userId after animation ends
    Timer(const Duration(seconds: 6), () {
      _checkUserSession();
    });
  }

  // Check for existing token and navigate accordingly
  Future<void> _checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    final userId = prefs.getInt('userId');
    final userType = prefs.getString('user_type');

    // If token and userId exist, navigate to the appropriate screen
    if (token != null && userId != null && userType != null) {
      if (userType == 'doctor') {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const StaffMainScreen(),
          ),
        );
      } else if (userType == 'patient') {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const MainScreen(),
          ),
        );
      } else if (userType == 'nurse') {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const StaffNurseMainScreen(),
          ),
        );
      }
    } else {
      // If no token exists, navigate to the on_boarding screen
      Navigator.pushNamed(context, '/on_boarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/Enayatak.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}