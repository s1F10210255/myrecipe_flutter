import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:g14/screens/onboding/components/sign_in_form.dart';
import 'package:g14/servise/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:g14/screens/onboding/components/twitter_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';


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


Future<void> signInWithTwitter(BuildContext context) async {
  final twitterLogin = TwitterLogin(
    apiKey: 'C0I0iyFdxAR59FXxKQGUKPIkC',
    apiSecretKey: 'G5chGLxkt4wv8kbPC4HonMMx51A9FUlwwOfe7YnzhD7mqCCMNU',
    redirectURI: 'https://chatgptrecipegenerator.firebaseapp.com/__/auth/handler',
  );

  final authResult = await twitterLogin.login();

  switch (authResult.status) {
    case TwitterLoginStatus.loggedIn:
    // ユーザーが正常にログインした場合の処理
      print('Logged in! Username: ${authResult.user!.email}');
      break;
    case TwitterLoginStatus.cancelledByUser:
    // ユーザーがログインをキャンセルした場合の処理
      print('Login cancelled by user.');
      break;
    case TwitterLoginStatus.error:
    // エラーが発生した場合の処理
      print('Login error: ${authResult.errorMessage}');
      break;
    default:
    // その他のケース
      break;

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
          height: 620,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.all(Radius.circular(40))),
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
                    style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
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
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("Sign up with Email, X or Google",
                        style: TextStyle(color: Colors.black54)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            GoRouter.of(context).go('/sign-up');
                          },
                          icon: SvgPicture.asset(
                            "assets/icons/email_box.svg",
                            height: 64,
                            width: 64,
                          )),
                      IconButton(
                          padding: EdgeInsets.zero,

                          onPressed: () {
                            print('Twitter login button tapped'); // ボタンタップのデバッグ情報
                            signInWithTwitter(context);
                          },

                          icon: SvgPicture.asset(
                            "assets/icons/X_logo_2023.svg",
                            height: 40,
                            width: 40,
                          )),
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => signInWithGoogle(context),
                          icon: SvgPicture.asset(
                            "assets/icons/google_box.svg",
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