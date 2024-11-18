import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/view/chat.dart';

class LoginHandler {
  final box = GetStorage();
  String userEmail = '';
  String userName = '';
  List data = [];

  // 로그인 상태 확인
  isLoggeIn() {
    return FirebaseAuth.instance.currentUser != null &&
        getStoredEmail().isNotEmpty;
  }

  // GetStorage에서 저장된 이메일 가져오기
  getStoredEmail() {
    return box.read('userEmail') ?? '';
  }

  // Google로그인
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // to prevent the error whitch when user return to the login page without signing in
    if (gUser == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth = await gUser.authentication;

    userEmail = gUser.email;
    userName = gUser.displayName!;
    box.write('userEmail', userEmail);
    box.write('userName', userName);

    // check whether the account is registered
    bool isUserRegistered = await userloginCheckDatabase(userEmail);

    // if the account is trying to login on the first time add the google account information to the mySQL DB
    if (!isUserRegistered) {
      userloginInsertData(userEmail, userName);
    }

    // firbase Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credentials
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // 로그인 후 채팅패이지로
    Get.to(() => const Chat());
    return userCredential;
  }

  // check whether the account is registered
  userloginCheckDatabase(String email) async {
    userloginCheckJSONData(email);
    if (data.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

// query inserted google email from db to differentiate whether email is registered or not
  userloginCheckJSONData(email) async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/user/selectuser?email=$email');
      var response = await http.get(url);
      data.clear();
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));

      // null 체크와 타입 캐스팅을 함께 처리
      List<dynamic> result = (dataConvertedJSON['results'] as List?) ?? [];
      data.addAll(result);
    } catch (e) {
      print('Error fetching user data: $e');
      // 에러 처리
    }
  }

  // insert the account information to mysql
  userloginInsertData(String userEmail, String userName) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/user/insertuser?email=$userEmail&name=$userName&observer=false');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];

    if (result == 'OK') {
      // 성공 처리
    } else {
      // 실패 처리
    }
  }

  // 로그아웃 및 비우기
  signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    box.write('userEmail', "");
    // update();
  }
}
