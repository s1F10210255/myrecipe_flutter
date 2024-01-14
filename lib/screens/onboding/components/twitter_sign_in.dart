import 'package:flutter/material.dart';
import 'package:twitter_login/twitter_login.dart';

class TwitterSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Sign in with Twitter'),
      onPressed: () async {
        // TwitterLogin インスタンスの作成
        final twitterLogin = TwitterLogin(
          apiKey: 'NTV5aUg5RmFRdFBqUi1sYlBUR2s6MTpjaQ',
          apiSecretKey: '-j9knYXoz0qlzLEOOGjjvn-SeTdQ6cbtJQlftgnFNpcSAcekHj',
          redirectURI: 'https://chatgptrecipegenerator.firebaseapp.com/__/auth/handler',
        );

        // ログインプロセスの開始
        final authResult = await twitterLogin.login();

        // 認証結果に基づいたアクション
        switch (authResult.status) {
          case TwitterLoginStatus.loggedIn:
          // ユーザーが正常にログインした場合
            break;
          case TwitterLoginStatus.cancelledByUser:
          // ユーザーがログインをキャンセルした場合
            break;
          case TwitterLoginStatus.error:
          // エラーが発生した場合
            print('Login error: ${authResult.errorMessage}');
            break;
          default:
          // その他のケース（例えば null など）
            break;
        }
      },
    );
  }
}
