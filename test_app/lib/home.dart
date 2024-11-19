import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/view/chat.dart';
import 'package:test_app/view/findmap.dart';
import 'package:test_app/view/info.dart';
import 'package:test_app/view/post.dart';
import 'package:test_app/view/widgets/login_check.dart';
import 'package:test_app/vm/location_handler.dart';
import 'package:test_app/vm/login_handler.dart';
import 'package:test_app/vm/tab_vm.dart';

class Home extends GetView<TabVM> {
  Home({super.key});

  final LoginHandler loginController = Get.find<LoginHandler>();
  final LocationHandler locationController = Get.find<LocationHandler>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: controller.tabController,
        children: [
          Info(),
          Obx(() =>
              loginController.isLoggedIn ? const Post() : const LoginCheck()),
          Obx(() =>
              loginController.isLoggedIn ? const Chat() : const LoginCheck()),
          const Findmap()
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            onTap: (index) {
              controller.tabController.index = index;
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color.fromARGB(255, 245, 245, 245),
            iconSize: 25,
            selectedFontSize: 14,
            selectedItemColor: const Color.fromARGB(255, 101, 186, 255),
            currentIndex: controller.currentIndex.value,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.post_add), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
            ],
          )),
    );
  }
}
