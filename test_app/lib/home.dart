import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RiverPark_Mate/view/chat/chat.dart';
import 'package:RiverPark_Mate/view/findmap.dart';
import 'package:RiverPark_Mate/view/info.dart';
import 'package:RiverPark_Mate/view/post.dart';
import 'package:RiverPark_Mate/view/widgets/login_check.dart';
import 'package:RiverPark_Mate/vm/tab_vm.dart';

import 'vm/location_handler.dart';
import 'vm/login_handler.dart';

class Home extends GetView<TabVM> {
  Home({super.key});

  final LoginHandler loginController = Get.find<LoginHandler>();
  final LocationHandler locationController = Get.find<LocationHandler>();
  final Color selectedColor = const Color(0xFFFF8D62);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (kIsWeb) {
          // 웹 버전 레이아웃
          return Scaffold(
            backgroundColor: Colors.white,
            body: Row(
              children: [
                // 웹용 사이드 네비게이션
                _buildWebSideNavigation(context),
                // 메인 콘텐츠
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: [
                      Info(),
                      Obx(() => loginController.isLoggedIn
                          ? const Post()
                          : const LoginCheck()),
                      Obx(() => loginController.isLoggedIn 
                          ? Chat() 
                          : const LoginCheck()),
                      const Findmap()
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // 모바일 기존
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
                    ? Chat() 
                    : const LoginCheck()),
                const Findmap()
              ],
            ),
            bottomNavigationBar: Obx(() => _buildBottomNavigationBar(context)),
          );
        }
      },
    );
  }

  // 웹용 사이드 네비게이션 위젯
  Widget _buildWebSideNavigation(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 웹용 네비게이션 아이템들
          _buildWebNavigationItem('images/homeimage.png', 0, '홈'),
          _buildWebNavigationItem('images/postpage.png', 1, '게시물'),
          _buildWebNavigationItem('images/Chat.png', 2, '채팅'),
          _buildWebNavigationItem('images/userpage.png', 3, '로그아웃'),
        ],
      ),
    );
  }

  // 웹용 네비게이션 아이템 위젯
  Widget _buildWebNavigationItem(String imagePath, int index, String label) {
    return Obx(() {
      final bool isSelected = controller.currentIndex.value == index;
      return InkWell(
        onTap: () => controller.tabController.index = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }


  Widget _buildBottomNavigationBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.08; // 화면 너비의 6%로 아이콘 크기 설정
    final barHeight = screenHeight * 0.1; // 화면 높이의 8%로 네비게이션 바 높이 설정

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
          _buildBottomNavigationBarItem('images/homeimage.png', 0, context),
          _buildBottomNavigationBarItem('images/postpage.png', 1, context),
          _buildBottomNavigationBarItem('images/Chat.png', 2, context),
          _buildBottomNavigationBarItem('images/userpage.png', 3, context),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      String imagePath, int index, BuildContext context) {
    final bool isSelected = controller.currentIndex.value == index;

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: selectedColor, // 선택된 상태일 때 배경색
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            width: 35, // 이미지 크기
            height: 25,
          ),
        ),
      ),
      label: '',
    );
  }
}
