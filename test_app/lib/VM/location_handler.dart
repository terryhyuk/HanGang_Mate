import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/Model/parking.dart';
import 'package:test_app/private.dart';

class LocationHandler extends GetxController {
  // Variables
  var parkingInfo = <Parking>[].obs; // 주차장 정보
  final RxDouble currentlat = 0.0.obs; // 현재 위치 위도
  final RxDouble currentlng = 0.0.obs; // 현재 위치 경도
  var hnameList = [].obs; // 한강공원 이름 목록
  var selectHname = ''.obs; // 드롭다운 선택된 공원 이름
  final parkingMarker = <Marker>[].obs; // 구글 맵 마커
  final Rx<GoogleMapController?> mapController =
      Rx<GoogleMapController?>(null); // 구글 맵 컨트롤러
  final Rx<GoogleMapController?> routesController =
      Rx<GoogleMapController?>(null); // 경로 페이지 구글 맵 컨트롤러
  final Private private = Private(); // 구글 맵 API 키 보관
  PolylinePoints polylinePoints = PolylinePoints();
  List<PointLatLng> polyline = []; // 디코딩된 경로 포인트
  List<LatLng> route = []; // 길찾기 체크포인트
  var lines = <Polyline>[].obs; // 길찾기 라인
  RxString selectParking = ''.obs; // 선택된 주차장 이름
  var totalAvailableParking = 0.obs; // 주차장 실시간 이용 가능 대수
  var capacity = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    initializeAsync();
  }

  // Initialization
  initializeAsync() async {
    await checkLocationPermission();
    await getAllHname();
    await getParkingLoc();
    await createMarker();
    await fetchParkingData();
  }

  // 위치 제공 동의 체크
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
      await getCurrentLocation();
    }
  }

  // 현재 위치 가져오기
  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentlat.value = position.latitude;
    currentlng.value = position.longitude;
    update();
  }

  // 한강공원 목록 가져오기
  getAllHname() async {
    var url = Uri.parse('http://127.0.0.1:8000/parking/hanriver');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      hnameList.value = dataConvertedJSON['results'];
      selectHname.value = hnameList[0];
    }
  }

  // 선택한 한강공원의 주차장 정보 가져오기
  getParkingLoc() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/parking/hanriver?hname=${selectHname.value}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      List<Parking> returnData = [];
      parkingInfo.clear();

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

  // 구글 맵 마커 생성
  createMarker() {
    parkingMarker.value = parkingInfo
        .map(
          (park) => Marker(
            markerId: MarkerId(park.pname),
            infoWindow: InfoWindow(title: park.pname, snippet: park.pname),
            position: LatLng(park.lat, park.lng),
          ),
        )
        .toList();
  }

  // 드롭다운 선택 시 지도 카메라 이동
  changeCameraPosition() {
    if (mapController.value != null && parkingInfo.isNotEmpty) {
      mapController.value!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(parkingInfo[0].lat, parkingInfo[0].lng),
              zoom: 13)));
    }
  }

  // 길찾기 라인 생성
  createRoute(int index) async {
    lines.clear();
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${currentlat},${currentlng}&destination=${parkingInfo[index].lat},${parkingInfo[index].lng}&mode=transit&language=ko&key=${private.mapAPIkey}");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    polyline = polylinePoints.decodePolyline(
        dataConvertedJSON['routes'][0]['overview_polyline']['points']);
    route = polyline
        .map(
          (point) => LatLng(point.latitude, point.longitude),
        )
        .toList();
    lines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: route,
        color: Colors.red));
  }

  // 선택된 주차장 이름 업데이트
  selectParkingname(index) {
    selectParking.value = parkingInfo[index].pname;
    update();
  }

  // 주차장 데이터 가져오기
  Future<void> fetchParkingData() async {
    final encodedPname = Uri.encodeComponent(selectHname.value);
    final url =
        Uri.parse("http://127.0.0.1:8000/hanriver/citydata/$encodedPname");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      print("Response Data: $data");

      final List<dynamic> parkingList = data['주차장 현황'];
      int total = 0;
      int totalCapacity = 0;
      for (var parking in parkingList) {
        int capacity = int.parse(parking['CPCTY']?.toString() ?? '0');
        int currentParking =
            int.parse(parking['CUR_PRK_CNT']?.toString() ?? '0');
        total += (capacity - currentParking);
        totalCapacity += capacity;
      }
      capacity.value = totalCapacity;
      totalAvailableParking.value = total;
    } else {
      print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  }
}
