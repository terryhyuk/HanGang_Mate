import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/vm/login_handler.dart';
import 'package:test_app/constants/theme.dart';

class Findmap extends GetView<LoginHandler> {
  const Findmap({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await controller.signOut();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

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
              onTap: () async {
                await _showLogoutDialog(context);
              },
              child: Image.asset('images/logout.png'),
            ),
          ],
        ),
      ),
      backgroundColor: backClr,
    );
  }
}
