import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/vm/location_handler.dart';

class LoginHandler extends LocationHandler {
  List data = [];
  String userEmail = '';
  String userName = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google 로그인 오류: $e');
      return null;
    }
  }

  userloginCheckJSONData(email) async {
    var url = Uri.parse('http://127.0.0.1:8000/user/selectuser?id=$email');
    var response = await http.get(url);
    data.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    data.addAll(result);
  }

  userloginInsertData(String userEmail, String userName) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/user/insertuser?email=$userEmail');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    if (result == 'OK') {
    } else {}
  }

  signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
