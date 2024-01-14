import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:g14/screens/onboding/components/animated_btn.dart';
import 'package:g14/screens/onboding/components/custom_sign_in.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  bool isSignInDialogShown = false;
  late RiveAnimationController _btnAnimationController;
  late RiveAnimationController _baLoaderController;
  late RiveAnimationController _chefController;
  late RiveAnimationController _bounceController;

  late AnimationController _chefAnimationController;
  bool _chefAnimationCompleted = false;

  @override
  void initState() {
    super.initState();
    _btnAnimationController = OneShotAnimation("active", autoplay: false);
    _baLoaderController = SimpleAnimation('main', autoplay: true);
    _bounceController = SimpleAnimation('bounce', autoplay: false);

    _chefController = OneShotAnimation('chef', autoplay: true);
    _chefAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _chefAnimationCompleted = true;
        });
      }
    });

    _baLoaderController.isActiveChanged.addListener(() {
      if (!_baLoaderController.isActive) {
        _bounceController.isActive = true;
      }
    });

    _chefAnimationController.forward();
  }

  @override
  void dispose() {
    _chefAnimationController.dispose();
    _baLoaderController.dispose();
    _bounceController.dispose();
    _btnAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA8E6F5),
      body: Stack(
        children: [
          if (!_chefAnimationCompleted)
            Positioned.fill(
              child: RiveAnimation.asset(
                'assets/RiveAssets/chef.riv',
                controllers: [_chefController],
                fit: BoxFit.fill,
              ),
            ),
          Column(
            children: [
              Expanded(
                flex: 11,
                child: RiveAnimation.asset(
                  'assets/RiveAssets/ba_loader (13).riv',
                  controllers: [_baLoaderController],
                  fit: BoxFit.cover,
                ),
              ),
              Spacer(),
              const SizedBox(
                width: 380,
                child: Column(
                  children: [
                    Text("Cook'n'roll", style: TextStyle(fontSize: 60, fontFamily: "Poppins", height: 2.0)),
                    SizedBox(height: 20),
                    Text("今日も楽しく料理をしよう"),
                  ],
                ),
              ),
              Spacer(flex: 2),
              AnimatedBtn(
                btnAnimationController: _btnAnimationController,
                press: () {
                  _btnAnimationController.isActive = true;
                  Future.delayed(Duration(milliseconds: 800), () {
                    customSigninDialog(context, onClosed: (_) {
                      if (mounted) {
                        setState(() {
                          isSignInDialogShown = false;
                        });
                      }
                    });
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text("iniad team 14 Group1", style: TextStyle()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
