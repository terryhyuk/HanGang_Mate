import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:RiverPark_Mate/Model/custom.dart';
import 'package:RiverPark_Mate/constants/theme.dart';
import 'package:RiverPark_Mate/vm/location_handler.dart';
import 'package:RiverPark_Mate/view/detail.dart';

class Info extends StatelessWidget {
  Info({super.key});
  final LocationHandler controller = Get.put(LocationHandler());
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>(); // google map 출력을 위한 controller
  final RxBool isExpanded = false.obs; // 드랍다운 상태 관리

  // 시간대별 메시지와 색상 반환 함수
  Map<String, dynamic> getTimeBasedStyle() {
    final currentTime = DateTime.now().hour;

    if (currentTime >= 6 && currentTime < 12) {
      return {
        "message": "Good morning",
        "color": morningClr,
      };
    } else if (currentTime >= 12 && currentTime < 17) {
      return {
        "message": "Good afternoon",
        "color": afternoonClr,
      };
    } else if (currentTime >= 17 && currentTime < 24) {
      return {
        "message": "Good evening",
        "color": eveningClr,
      };
    } else {
      return {
        "message": "Good night",
        "color": nightClr,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = getTimeBasedStyle(); // 시간대별 스타일 가져오기
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backClr, // 시간대별 색상 적용
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                style["message"], // 시간대별 메시지 적용
                style: TextStyle(
                  color: style["color"],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Image.asset(
              //   'images/clear-cloudy.png',
              //   width: MediaQuery.of(context).size.width * 0.12,
              //   height: MediaQuery.of(context).size.width * 0.12,
              // )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetBuilder<LocationHandler>(builder: (_) {
                    return Obx(() {
                      if (controller.parkingMarker.isEmpty) {
                        return const Center(
                          
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            children: [
                              _currentlyAtSection(context),
                              _card(context),
                              const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Text(
                                      '  주차장 위치',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              _googleMap(context),
                            ],
                          ),
                        );
                      }
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: backClr,
    );
  }

// "Currently at" 섹션
  Widget _currentlyAtSection(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.01,
            vertical: MediaQuery.of(context).size.height * 0.01),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게
            side: const BorderSide(color: Colors.black),
          ),
          elevation: 0,
          color: Colors.white, // 카드 배경을 흰색으로 설정
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // "Currently at:"와 선택된 공원명 텍스트
                    Row(
                      children: [
                        const Text(
                          "Currently at:  ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: infoTextClr, // 색상은 constants에 정의된 값 사용
                          ),
                        ),
                        Text(
                          controller.selectHname.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: infoTextClr, // 공원명 색상
                          ),
                        ),
                      ],
                    ),
                    // 드롭다운 버튼
                    IconButton(
                      icon: Icon(
                        isExpanded.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      onPressed: () {
                        isExpanded.value = !isExpanded.value; // 드롭다운 상태 변경
                      },
                    ),
                  ],
                ),
                if (isExpanded.value)
                  const Divider(
                    color: infoLineClr, // 선 색상
                    thickness: 1, // 선 두께
                  ),
                // 드롭다운 확장 애니메이션
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  // 최대 높이를 화면 크기의 20%로 제한
                  height: isExpanded.value
                      ? MediaQuery.of(context).size.height * 0.20
                      : 0,
                  child: isExpanded.value
                      ? SingleChildScrollView(
                          child: Column(
                            children: controller.hnameList.map((item) {
                              return GestureDetector(
                                onTap: () async {
                                  controller.selectHname.value = item; // 공원 선택
                                  // 드롭다운 유지
                                  await controller.getParkingLoc();
                                  await controller.createMarker();
                                  await controller.changeCameraPosition();
                                  await controller.fetchParkingData();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          fontWeight: FontWeight.bold,
                                          color: infoTextClr,
                                        ),
                                      ),
                                      if (item == controller.selectHname.value)
                                        Icon(
                                          Icons.check,
                                          color: Colors.grey,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _card(context) {
    return GestureDetector(
      onTap: () async {
        if (controller.apivalue.value == true) {
          await controller.resetTime();
          await controller.predict();
          Get.to(Detail());
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01,
        ),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게
            side: const BorderSide(color: Colors.black),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '주차장 현황',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        await controller.fetchParkingData(); // 데이터 새로고침
                      },
                    ),
                  ],
                ),
                _colorSlider(context),
                const SizedBox(height: 10),
                Obx(
                  () => RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "현재 ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 일반 텍스트 색상
                          ),
                        ),
                        TextSpan(
                          text:
                              "${controller.totalAvailableParking}대", // 컨트롤러 부분
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // 원하는 색상
                          ),
                        ),
                        const TextSpan(
                          text: " 주차 가능",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 일반 텍스트 색상
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleMap(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.01,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16), // Card와 동일한 반경
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.3,
            child: GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: CameraPosition(
                zoom: 13,
                target: LatLng(controller.parkingInfo[0].lat,
                    controller.parkingInfo[0].lng),
              ),
              onMapCreated: (GoogleMapController mapController) {
                controller.mapController.value = mapController;
              },
              markers: controller.parkingMarker.toSet(),
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
            ),
          ),
        ),
      ),
    );
  }

//  주차장 현황 slider
  Widget _colorSlider(context) {
    // double sliderValue = 40; // 테스트용 임의 값 지정
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '여유',
              style: TextStyle(color: infoTextClr, fontWeight: FontWeight.bold),
            ),
            Text(
              '보통',
              style: TextStyle(color: infoTextClr, fontWeight: FontWeight.bold),
            ),
            Text(
              '혼잡',
              style: TextStyle(color: infoTextClr, fontWeight: FontWeight.bold),
            ),
            Text(
              '만차',
              style: TextStyle(color: infoTextClr, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: HollowCircleThumbShape(), // 커스텀 슬라이더 ThumbShape
            trackHeight: 20, // 트랙 높이
            activeTrackColor:
                Colors.transparent, // 활성 트랙 색상 (투명, Gradient 사용 예정)
            inactiveTrackColor: Colors.transparent, // 비활성 트랙 색상
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 0), // 오버레이 제거
          ),
          child: Stack(
            children: [
              // Gradient Track (배경)
              Container(
                height: 15,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7.5)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.red,
                    ],
                  ),
                ),
              ),
              // 실제 Slider
              Slider(
                value: controller.capacity.value.toDouble() -
                    controller.totalAvailableParking.value.toDouble(),
                min: 0,
                max: controller.capacity.value.toDouble(),
                onChanged: (value) {
                  // 슬라이더 값 변경
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
