import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginHandler extends GetxController {
  final box = GetStorage();
  final RxBool _isLoggedIn = false.obs;
  final RxString userEmail = ''.obs;
  final RxString userName = ''.obs;
  final RxBool _isObserver = false.obs;
  List data = [];

  bool get isLoggedIn => _isLoggedIn.value;
  bool get isObserver => _isObserver.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // 로그인 상태 확인
  checkLoginStatus() {
    _isLoggedIn.value = FirebaseAuth.instance.currentUser != null &&
        getStoredEmail().isNotEmpty;
    userEmail.value = getStoredEmail();
    userName.value = box.read('userName') ?? '';
    _isObserver.value = box.read('isObserver') ?? false; // observer 상태 읽기
  }

  // GetStorage에서 저장된 이메일 가져오기
  getStoredEmail() {
    return box.read('userEmail') ?? '';
  }

  // Google로그인
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await gUser.authentication;

    userEmail.value = gUser.email;
    userName.value = gUser.displayName!;
    box.write('userEmail', userEmail.value);
    box.write('userName', userName.value);

    bool isUserRegistered = await userloginCheckDatabase(userEmail.value);

    if (!isUserRegistered) {
      await userloginInsertData(userEmail.value, userName.value);
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    _isLoggedIn.value = true;
    update();
    return userCredential;
  }

  // 등록된 계정인지 확인
  userloginCheckDatabase(String email) async {
    userloginCheckJSONData(email);
    if (data.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  userloginCheckJSONData(email) async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/user/selectuser?email=$email');
      var response = await http.get(url);
      data.clear();
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> result = (dataConvertedJSON['results'] as List?) ?? [];
      data.addAll(result);

      if (result.isNotEmpty) {
        String observerValue = result[0]['observer'] ?? 'false';

        _isObserver.value = observerValue.toLowerCase() == 'true';
        box.write('isObserver', _isObserver.value);
      }
    } catch (e) {
      return 'Error fetching user data: $e';
    }
  }

  // DB에 계정 등록
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

  // 로그아웃
  signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    box.write('userEmail', "");
    box.write('userName', "");
    _isLoggedIn.value = false;
    userEmail.value = '';
    userName.value = '';
    update();
  }
}
