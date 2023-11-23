import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:g14/screens/onboding/onboding_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:g14/screens/home.dart';
import 'package:g14/screens/onboding/components/sign_up_form.dart';


final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage(child: OnboardingScreen()),  // MaterialPageを追加
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => MaterialPage(child: HomeScreen()),  // MaterialPageを追加
    ),
    GoRoute(
      path: '/sign-up',
      pageBuilder: (context, state) => MaterialPage(child: SignUpForm()), // SignUpForm はサインアップフォームウィジェット
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const app = MyApp();
  const scope = ProviderScope(child: app);
  runApp(scope);
}
