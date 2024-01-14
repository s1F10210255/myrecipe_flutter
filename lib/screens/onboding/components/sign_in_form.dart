import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:g14/servise/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';


class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isShowLoading = false;
  bool isShowConfetti = false;

  String email = '';
  String password = '';

  late SMITrigger check;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  StateMachineController getRiveController(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      return controller;
    }
    throw Exception('Failed to find the state machine controller.');
  }

  void signIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isShowLoading = true;
      });

      try {
        final UserCredential userCredential = await AuthService().signInWithEmailPassword(email, password);

        GoRouter.of(context).go('/home');
        check.fire();
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isShowLoading = false;
            isShowConfetti = true;
          });
          confetti.fire();
        });
      } on FirebaseAuthException catch (e) {
        error.fire();
        setState(() {
          isShowLoading = false;
        });
      }
    } else {
      error.fire();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRiveFile('assets/RiveAssets/check.riv');
    _loadRiveFile('assets/RiveAssets/confetti.riv');
  }

  void _loadRiveFile(String riveFileName) async {
    final data = await rootBundle.load(riveFileName);
    final file = RiveFile.import(data);

    final artboard = file.mainArtboard;
    var controller = getRiveController(artboard);

    if (riveFileName.endsWith('check.riv')) {
      var input = controller.findInput('check');
      if (input is SMITrigger) {
        check = input;
      }
    } else if (riveFileName.endsWith('confetti.riv')) {
      var input = controller.findInput('confetti');
      if (input is SMITrigger) {
        confetti = input;
      }
    }

    artboard.addController(controller);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Email",
                  style: TextStyle(color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your email.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                const Text(
                  "Password",
                  style: TextStyle(color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your password.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      signIn(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF45FF00),
                      minimumSize: const Size(double.infinity, 56),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                      ),
                    ),
                    icon: const Icon(
                      CupertinoIcons.arrow_right,
                      color: Color(0xFFFE0037),
                    ),
                    label: const Text("Sign In"),
                  ),
                )
              ],
            ),
          ),
          if (isShowLoading)
            CustomPositioned(
              child: RiveAnimation.asset(
                "assets/RiveAssets/check.riv",
                fit: BoxFit.contain,
              ),
            ),
          if (isShowConfetti)
            CustomPositioned(
              child: Transform.scale(
                scale: 6,
                child: RiveAnimation.asset(
                  "assets/RiveAssets/confetti.riv",
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, required this.child, this.size = 100});
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          Spacer(),
          SizedBox(
            height: size,
            width: size,
            child: child,
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}