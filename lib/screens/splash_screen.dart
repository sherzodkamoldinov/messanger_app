import 'package:flutter/material.dart';
import 'package:messanger_app/screens/auth/login_screen.dart';
import 'package:messanger_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // logo
          Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('assets/icons/app_icon.png'),
          ),

          Positioned(
              bottom: mq.height * .1,
              width: mq.width,
              child: const Text(
                'POWERED BY UCHAR ❤️',
                style: TextStyle(fontSize: 16, color: Colors.black87, letterSpacing: .5),
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }
}
