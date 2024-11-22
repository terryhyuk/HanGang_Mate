import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RiverPark_Mate/constants/theme.dart';
import 'package:RiverPark_Mate/vm/login_handler.dart';

class LoginCheck extends GetView<LoginHandler> {
  final String message;

  const LoginCheck({
    super.key,
    this.message = '이 기능을 사용하려면 로그인이 필요합니다.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backClr,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/hanriver.png'),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            GestureDetector(
              onTap: () => controller.signInWithGoogle(),
              child: Image.asset('images/goggle.png'),
            ),
          ],
        ),
      ),
      backgroundColor: backClr,
    );
  }
}
