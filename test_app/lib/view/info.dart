import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gradient_slider/gradient_slider.dart';
import 'package:test_app/vm/location_handler.dart';
import 'package:test_app/view/detail.dart';

class Info extends StatelessWidget {
  Info({super.key});
  final LocationHandler controller = Get.put(LocationHandler());
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>(); // google map 출력을 위한 controller
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GetBuilder<LocationHandler>(builder: (_) {
                    return Obx(() {
                      if (controller.parkingMarker.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Center(
                          child: Column(
                            children: [
                              _dropDown(),
                              _card(context),
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
        ));
  }

  Widget _dropDown() {
    return DropdownButton<String>(
      value: controller.selectHname.value,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: controller.hnameList.map((dynamic item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? value) async {
        if (value != null) {
          controller.selectHname.value =
              value; // vm 변수 변경해주기 (==> 다른 함수 만들때 별도의 parameter 필요없음)
          await controller.getParkingLoc(); // 선택한 공원에 맞는 주차장 이름, 위도, 경도 받아오는 함수
          await controller.createMarker(); // google map 주차장 marker 생성
          await controller
              .changeCameraPosition(); // mapcontroller의 type 변환이 필요해서 파라미터로 설정함
        }
      },
    );
  }

  Widget _card(context) {
    return GestureDetector(
      onTap: () {
        Get.to(Detail());
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.selectHname.value,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {},
                  ),
                ],
              ),
              // Slider(
              //   value: 50,
              //   min: 0,
              //   max: 100,
              //   // divisions: 4, // 여유, 보통, 혼잡 구분
              //   onChanged: (double value) {
              //     // 슬라이더 값 변경 시 처리
              //   },
              // ),
              _colorSlider(context),
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
      ),
    );
  }

  Widget _googleMap(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.3,
      child: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: CameraPosition(
          zoom: 13,
          target: LatLng(
              controller.parkingInfo[0].lat, controller.parkingInfo[0].lng),
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
    );
  }

//  주차장 현황 slider
  Widget _colorSlider(context) {
    double sliderValue = 50; // 테스트용 임의 값 지정,
    return GradientSlider(
      thumbAsset: 'images/slider_icon.jpg', // slider 값 표시 이미지, 임시
      thumbHeight: 30,
      thumbWidth: 30,
      trackHeight: 10,
      trackBorder: 1,
      activeTrackGradient: const LinearGradient(
        colors: [
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
        ],
      ),
      inactiveTrackGradient: const LinearGradient(
        colors: [
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
        ],
      ),
      slider: Slider(
        value: sliderValue,
        min: 0,
        max: 100,
        onChanged: (value) {
          //
        },
      ),
    );
  }
}
