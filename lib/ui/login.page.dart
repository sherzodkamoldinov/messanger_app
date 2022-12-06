import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _HomePageState();
}

class _HomePageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      
      case Status.authenticateError:
        Fluttertoast.showToast(msg: 'Sign in fail');
        break;
        
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: 'Sign in canceled');
        break;

      case Status.authenticated:
        Fluttertoast.showToast(msg: 'Sign in success');
        break;

      default:
        break;

    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset('assets/images/back.png'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () async {
                bool isSuccess = await authProvider.handleSignIn();
                if (isSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              },
              child: Image.asset('assets/images/google_login.jpg'),
            ),
          ),
          Positioned(
            child: authProvider.status == Status.authenticating ? const LoadingView() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
