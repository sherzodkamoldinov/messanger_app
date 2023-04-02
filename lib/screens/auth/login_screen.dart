import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messanger_app/api/apis.dart';
import 'package:messanger_app/helper/dialogs.dart';
import 'package:messanger_app/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() async {
    // for showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      // for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        debugPrint('\nUser: ${user.user}');
        debugPrint('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if (await APIs.userExists()) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // check host
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Messenger App'),
      ),
      body: Stack(
        children: [
          // logo
          AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/icons/app_icon.png'),
          ),

          // login wiht google button
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .1,
            right: mq.width * .1,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                ),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset(
                  'assets/icons/google.png',
                  width: 40,
                ),
                label: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(text: 'Login with '),
                      TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
