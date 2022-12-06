import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/utils/my_utils.dart';
import 'package:chat_app/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _HomePageState();
}

class _HomePageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // MAIN
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IMAGE
                Image.asset('assets/images/back.png'),
                const SizedBox(height: 20),

                // SIGN IN BUTTON
                GestureDetector(
                  onTap: () async {
                    await context.read<AuthProvider>().handleSignIn();

                    if (!mounted) return;
                    switch (context.read<AuthProvider>().status) {
                      case Status.authenticateError:
                        CustomSnackbar.showSnackbar(context, 'Sign in fail', SnackbarType.error);
                        break;

                      case Status.authenticateCanceled:
                        CustomSnackbar.showSnackbar(context, 'Sign in canceled', SnackbarType.warning);
                        break;

                      case Status.authenticated:
                        CustomSnackbar.showSnackbar(context, 'Sign in success', SnackbarType.success);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                        break;

                      default:
                        break;
                    }
                  },
                  child: Image.asset('assets/images/google_login.jpg'),
                ),
              ],
            ),

            // LOADING VIEW
            Align(
              alignment: Alignment.center,
              child: context.watch<AuthProvider>().status == Status.authenticating ? const LoadingView() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
