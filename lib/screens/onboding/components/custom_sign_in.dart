import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:g14/screens/onboding/components/sign_in_form.dart';
import 'package:g14/servise/service.dart';


void signInWithGoogle(BuildContext context) async {
  print("Attempting to sign in with Google...");
  try {
    await AuthService().signIn();
    print("Signed in successfully. Navigating to home...");
    GoRouter.of(context).go('/home');
  } catch (error) {
    print("Error signing in with Google: $error");
  }
}


Future<Object?> customSigninDialog(BuildContext context,
    {required ValueChanged onClosed}) {
  return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Sign up",
      context: context,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        Tween<Offset> tween = Tween(begin: Offset(0, -1), end: Offset.zero);
        return SlideTransition(
            position: tween.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child);
      },
      pageBuilder: (context, _, __) => Center(
        child: Container(
          height: 650,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset:
            false, // avoid overflow error when keyboard shows up
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(children: [
                  const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 34,fontFamily: "Poppins", ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      "Access to 240+ hours of content. Learn design and code, by builder real apps with Flutter and Swift.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SignInForm(),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(color: Colors.black26),
                        ),
                      ),
                      Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Text("Sign up with Email, Apple or Google",
                        style: TextStyle(color: Colors.black54)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            "assets/icons/email_box.svg",
                            height: 64,
                            width: 64,
                          )),
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => signInWithGoogle(context),
                          icon: SvgPicture.asset(
                            "assets/icons/apple_box.svg",
                            height: 64,
                            width: 64,
                          )),
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => signInWithGoogle(context),
                          icon: SvgPicture.asset(
                            "assets/icons/2google_box.svg",
                            height: 64,
                            width: 64,
                          )
                      )

                    ],
                  )
                ]),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: -48,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
      )).then(onClosed);
}