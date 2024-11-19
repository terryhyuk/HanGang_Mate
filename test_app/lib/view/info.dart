import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_app/VM/location_handler.dart';

class Info extends StatelessWidget {
  Info({super.key});
  final LocationHandler controller =
      Get.put(LocationHandler()); // 임시 Location handler 추후에 기능 분리 필요해보임
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
                              _card(),
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

// Widget
  Widget _dropDown() {
    return DropdownButton<String>(
      value: controller.selectHname.value,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: controller.hnameLsit.map((dynamic item) {
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
          await controller.changeCameraPosition(
              mapController); // mapcontroller의 type 변환이 필요해서 파라미터로 설정함
        }
      },
    );
  }

  Widget _card() {
    return Card(
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
          target: LatLng(controller.parkingInfo[0].lat,
              controller.parkingInfo[0].lng), // 지도 중심점은 임의로 첫번째 주차장 값으로 설정함
        ),
        onMapCreated: (GoogleMapController controller) {
          if (!mapController.isCompleted) {
            mapController.complete(controller);
          }
        },
        markers: controller.parkingMarker
            .toSet(), // 변수가 List 형태이기 때문에 Set으로 type 맞춰줘야함
        myLocationButtonEnabled: false, // 내 위치로 카메라 이동하는 버튼
        myLocationEnabled: false, // 내 위치 표시
        zoomControlsEnabled: false, // 지도 확대 하기
        zoomGesturesEnabled: false, // 지도 확대하기
        rotateGesturesEnabled: false, // 지도 카메라 이동하기
        scrollGesturesEnabled: false, // 지도 카메라 이동하기
      ),
    );
  }
}
