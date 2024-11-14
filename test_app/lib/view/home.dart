import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:test_app/view/chat.dart';
import 'package:test_app/view/feed.dart';
import 'package:test_app/view/mypage.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  // 드랍다운 버튼 테스트 데이터
  final List<String> parks = ['망원한강공원', '강서한강공원', '난지한강공원', '이촌한강공원', '뚝섬한강공원'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens(),
        items: _items(),
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardAppears: true,
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.none,
        padding: const EdgeInsets.only(top: 10),
        // backgroundColor: Colors.grey.shade50,
        isVisible: true,
        onItemSelected: (index) {
          // 비로그인 상태일시 로그인이 필요한 기능은 로그인 화면으로 이동
        },
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            duration: Duration(milliseconds: 400),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            animateTabTransition: false,
          ),
        ),
        confineToSafeArea: true,
        navBarHeight: 30,
        navBarStyle: NavBarStyle.style8,
      ),
    );
  }

  List<Widget> _screens() {
    String selectedPark = parks[0];

    return [
      Scaffold(
        appBar: AppBar(
          title: const Text(
            '앱 이름',
            style: TextStyle(
                // fontWeight: FontWeight.bold,
                ),
          ),
          // backgroundColor: Colors.green.shade400,
          // foregroundColor: Colors.white,
          elevation: 0,
          actions: const [],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 현재 선택된 공원 표시 및 선택 드롭다운
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '선택된 공원 :',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedPark,
                          onChanged: (String? newValue) {
                            // 선택된 공원이 변경되면 처리
                          },
                          items: parks
                              .map<DropdownMenuItem<String>>((String park) {
                            return DropdownMenuItem<String>(
                              value: park,
                              child: Text(park),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 주차장 현황 카드
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'oo공원 주차장 현황',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            Slider(
                              value: 50,
                              min: 0,
                              max: 100,
                              // divisions: 4, // 여유, 보통, 혼잡 구분
                              onChanged: (double value) {
                                // 슬라이더 값 변경 시 처리
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '현재 혼잡도 n%',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const Feed(),
      const Chat(),
      const Mypage(),
    ];
  }

  List<PersistentBottomNavBarItem> _items() {
    return [
      _buildNavBarItem(
        "",
        Icons.home_filled,
      ),
      _buildNavBarItem(
        "",
        Icons.web_asset,
      ),
      _buildNavBarItem(
        "",
        Icons.chat,
      ),
      _buildNavBarItem(
        "",
        Icons.person,
      ),
    ];
  }

  PersistentBottomNavBarItem _buildNavBarItem(String title, IconData icon) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      activeColorPrimary: Colors.deepPurple,
      inactiveColorPrimary: Colors.grey,
    );
  }
}
