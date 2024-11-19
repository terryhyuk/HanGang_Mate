import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/Model/parking.dart';

class LocationHandler extends GetxController {
  var parkingInfo = <Parking>[].obs; // 공원별 주차장 정보(주차장명, 위도, 경도)
  final RxDouble currentlat = 0.0.obs; // 현재 내 위도 (경로 만들때 필요)
  final RxDouble currentlng = 0.0.obs; // 현재 내 경도 (경로 만들때 필요)
  var hnameLsit = [].obs; // 드랍다운용 한강 공원 이름
  var selectHname = ''.obs; // 드랍다운 선택된 한강공원 관리
  final parkingMarker = <Marker>[].obs; // 공원별 주차장 마커

  @override
  void onInit() async {
    super.onInit();
    await checkLocationPermission();
    await getAllHname();
    await getParkingLoc();
    await createMarker();
  }

// 위치 제공 동의
  checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await getCurrentLocation(); //현재 위치
    }
  }

// 내위치 가져오는 함수 (추후에 길찾기 기능을 위함)
  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentlat.value = position.latitude;
    currentlng.value = position.longitude;
    update();
  }

// 로딩시에 한강 공원 정보 모두 불러오기
  getAllHname() async {
    var url = Uri.parse('http://127.0.0.1:8000/parking/select_hanriver?');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      hnameLsit.value = dataConvertedJSON['results'];
      selectHname.value = hnameLsit[0];
    }
    // print(selectHname);
  }

//---------- 필요없는 함수 -------------
// 드랍다운 선택시 value(화면에 보이는 값) 변경,
  // changeValue()async{
  // selectHname.value = newValue;
  // await getParkingLoc();
  // print(selectHname);
  // update();
  // }

  // 주차장 정보 가져오기(주차장이름, 위도, 경도)
  getParkingLoc() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/parking/selectlatlng?hname=$selectHname');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      List<Parking> returnData = []; // obs 리스트 대입용
      parkingInfo.clear(); // 중복 방지 초기화 기능
      for (int i = 0; i < dataConvertedJSON['pname'].length; i++) {
        String pname = dataConvertedJSON['pname'][i];
        double lat = dataConvertedJSON['lat'][i];
        double lng = dataConvertedJSON['lng'][i];

        returnData.add(Parking(pname: pname, lat: lat, lng: lng));
      }
      parkingInfo.value = returnData;
      update();
    }
  }

  // 공원별 주차장 마커 만드는 함수
  createMarker() {
    parkingMarker.value = parkingInfo
        .map(
          (park) => Marker(
              markerId: MarkerId(park.pname), //
              infoWindow: InfoWindow(title: park.pname, snippet: park.pname),
              position: LatLng(park.lat, park.lng)),
        )
        .toList();
// print(marker);
  }

  // dropdown으로 공원 변경시 카메라 포지션 변경,
  changeCameraPosition(Completer<GoogleMapController> controller) async {
    final GoogleMapController mapController =
        await controller.future; // mapController의 type 변환 필요

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(parkingInfo[0].lat, parkingInfo[0].lng), zoom: 13)));
    //zoom 과 카메라 위치는 임의로 첫번째 주차장 위치로 지정
  }
}
