import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/view/chat.dart';
import 'package:test_app/view/findmap.dart';
import 'package:test_app/view/info.dart';
import 'package:test_app/view/post.dart';
import 'package:test_app/vm/tab_vm.dart';

class Home extends StatelessWidget {
  final TabVM controller = Get.put(TabVM());

  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: controller.tabController,
        children: const [Info(), Post(), Chat(), Findmap()],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            onTap: (index) {
              controller.tabController.index = index;
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color.fromARGB(255, 245, 245, 245),
            //showSelectedLabels: F,
            //showUnselectedLabels: F,
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
