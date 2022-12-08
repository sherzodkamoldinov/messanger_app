import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/ui/home_page.dart';
import 'package:chat_app/utils/my_utils.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                CustomButton(
                  title: 'Sign in with Google',
                  icon: FontAwesomeIcons.google,
                  iconColor: const Color.fromARGB(255, 249, 17, 0),
                  backgroundColor: const Color.fromARGB(255, 255, 111, 111),
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
