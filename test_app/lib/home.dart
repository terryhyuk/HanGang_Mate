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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: TabBarView(
            controller: controller.tabController,
            children: [
              Info(),
              Obx(() => loginController.isLoggedIn
                  ? const Post()
                  : const LoginCheck()),
              Obx(() => loginController.isLoggedIn
                  ? const Chat()
                  : const LoginCheck()),
              const Findmap()
            ],
          ),
          bottomNavigationBar: Obx(() => _buildBottomNavigationBar(context)),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.06; // 화면 너비의 6%로 아이콘 크기 설정
    final barHeight = screenHeight * 0.08; // 화면 높이의 8%로 네비게이션 바 높이 설정

    return SizedBox(
      height: barHeight,
      child: BottomNavigationBar(
        onTap: (index) {
          controller.tabController.index = index;
        },
        type: BottomNavigationBarType.fixed,
        iconSize: iconSize,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        currentIndex: controller.currentIndex.value,
        items: [
          _buildBottomNavigationBarItem(Icons.home_outlined),
          _buildBottomNavigationBarItem(Icons.post_add_outlined),
          _buildBottomNavigationBarItem(Icons.chat_outlined),
          _buildBottomNavigationBarItem(Icons.person_outline_outlined),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(IconData icon) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Icon(icon),
      ),
      label: '',
    );
  }
}
