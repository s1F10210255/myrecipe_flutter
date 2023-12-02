import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:g14/servise/token.dart';

class AuthService {
  static const clientId = '359218122786-je7hm483f6befsavqu5d0q1l5mkchenh.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: clientId,
    scopes: [
      'openid',
      'profile',
      'email',
      'https://www.googleapis.com/auth/youtubepartner',
      'https://www.googleapis.com/auth/youtube.force-ssl',

    ],
  );

  Future<String?> getAccessToken() async {
    final googleSignInAccount = await _googleSignIn.signIn();

    final authn = await googleSignInAccount?.authentication;
    if (authn?.accessToken != null) {
      // トークンを保存
      await saveToken(authn!.accessToken!);
    }
    return authn?.accessToken;
  }

  Future<bool> isTokenValid(String? accessToken) async {
    if (accessToken == null) {
      return false;
    }
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$accessToken'),
    );
    return response.statusCode == 200;
  }

  Future<String?> ensureValidToken() async {
    String? accessToken = await getToken();

    // トークンが存在しないか、無効な場合は新しいトークンを取得
    if (accessToken == null || !(await isTokenValid(accessToken))) {
      accessToken = await getAccessToken();
    }

    return accessToken;
  }

  Future<void> signIn() async {
    try {
      final accessToken = await ensureValidToken();

      // GoogleSignInからIDトークンを取得
      final googleSignInAccount = await _googleSignIn.signIn();
      final authn = await googleSignInAccount?.authentication;
      final idToken = authn?.idToken;

      if (accessToken != null && idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      print("Error during sign-in: $e");
      // 必要に応じてエラーメッセージを表示する処理を追加
    }
  }


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}