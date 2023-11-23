import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g14/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:g14/screens/onboding/onboding_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:g14/servise/state.dart';
import 'package:g14/screens/onboding/components/sign_up_form.dart';
part 'router.g.dart';

/// ---------------------------------------------------------
/// ページごとのパス    >> router/page_path.dart
/// ---------------------------------------------------------
class PagePath {
  // サインイン画面のパス
  static const signIn = '/sign-in';
  //サインアップ画面のパス
  static const signUp = '/sign-up';
  // ホーム画面のパス
  static const home = '/home';
  //カレンダー画面のパス
  static const calendar = '/calendar';
  //youtubeで調べるページ
  static const youtubeSearch = '/youtubeSearch';
  //料理サポート画面
  static const cook = '/cook';


}

/// ---------------------------------------------------------
/// GoRouter    >> router/router.dart
/// ---------------------------------------------------------
@riverpod
GoRouter router(RouterRef ref) {
  // パスと画面の組み合わせ
  final routes = [

    // ユーザーIDスコープで囲むためのシェル
    ShellRoute(
      builder: (_, __, child) => UserIdScope(child: child),
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


        // xxx画面
        // yyy画面
        // zzz画面
      ],
    ),
  ];

  // リダイレクト - 強制的に画面を変更する
  String? redirect(BuildContext context, GoRouterState state) {
    // 表示しようとしている画面
    final page = state.uri.toString();
    // サインインしているかどうか
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && page == PagePath.signIn) {
      // もうサインインしているのに サインイン画面を表示しようとしている --> ホーム画面へ
      return PagePath.home;
    } else if (user == null) {
      // まだサインインしていない --> サインイン画面へ
      return PagePath.signIn;
    } else {
      return null;
    }
  }


  // リフレッシュリスナブル - Riverpod と GoRouter を連動させるコード
  // サインイン状態が切り替わったときに GoRouter が反応する
  final listenable = ValueNotifier<Object?>(null);
  ref.listen<Object?>(signedInProvider, (_, newState) {
    listenable.value = newState;
  });
  ref.onDispose(listenable.dispose);

  // GoRouterを作成
  return GoRouter(
    initialLocation: PagePath.signIn,
    routes: routes,
    redirect: redirect,
    refreshListenable: listenable,
  );
}

/// ---------------------------------------------------------
/// アプリ本体    >> router/app.dart
/// ---------------------------------------------------------
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}