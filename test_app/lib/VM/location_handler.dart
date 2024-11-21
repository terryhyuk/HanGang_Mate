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
  var parkingInfo = <Parking>[].obs; // 주차장 정보
  final RxDouble currentlat = 0.0.obs; // 내위치
  final RxDouble currentlng = 0.0.obs; // 내위치
  var hnameList = [].obs; //한강공원 이름
  var selectHname = ''.obs; // 드랍다운 선택 이름
  final parkingMarker = <Marker>[].obs; // 드랍다운 맵 마커
  final Rx<GoogleMapController?> mapController =
      Rx<GoogleMapController?>(null); // info 페이지 구글맵
  final Rx<GoogleMapController?> routesController =
      Rx<GoogleMapController?>(null); // routes 페이지 구글맵
  final Private private = Private(); // 구글 맵 api 보관 파일
  PolylinePoints polylinePoints = PolylinePoints();
  List<PointLatLng> polyline = []; // api로 polyline decoding후 변수 저장
  List<LatLng> route = []; // 길 찾기에 필요한 체크포인트 latlong
  var lines = <Polyline>[].obs; // 길 찾기 그림
  RxString selectParking = ''.obs;
  var totalAvailableParking = 0.obs; // 주차장 실시간 이용가능 대수
  // String currentPlaceID = '';  //임시, 경로 api에 필요 할 수도 있음

  @override
  void onInit() async {
    super.onInit();
    initializeAsync();
  }

  initializeAsync() async {
    await checkLocationPermission();
    await getAllHname();
    await getParkingLoc();
    await createMarker();
    await fetchParkingData();
  }

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

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentlat.value = position.latitude;
    currentlng.value = position.longitude;
    update();
  }

  getAllHname() async {
    var url = Uri.parse('http://127.0.0.1:8000/parking/hanriver');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      hnameList.value = dataConvertedJSON['results'];
      selectHname.value = hnameList[0];
    }
  }

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

  createMarker() {
    parkingMarker.value = parkingInfo
        .map(
          (park) => Marker(
              markerId: MarkerId(park.pname),
              infoWindow: InfoWindow(title: park.pname, snippet: park.pname),
              position: LatLng(park.lat, park.lng)),
        )
        .toList();
  }

  changeCameraPosition() {
    if (mapController.value != null && parkingInfo.isNotEmpty) {
      mapController.value!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(parkingInfo[0].lat, parkingInfo[0].lng),
              zoom: 13)));
    }
  }

  // 경로 그리기
  createRoute(int index) async {
    lines.clear();
    var url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${currentlat},${currentlng}&destination=${parkingInfo[index].lat},${parkingInfo[index].lng}&mode=transit&language=ko&key=${private.mapAPIkey}");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    polyline = polylinePoints.decodePolyline(
        dataConvertedJSON['routes'][0]['overview_polyline']['points']);
    // var distance =dataConvertedJSON['routes'][0]['legs'][0]['distance']['text']; // 거리

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

  selectParkingname(index) {
    selectParking.value = parkingInfo[index].pname;
    update();
  }

// API 데이터 가져오기
  Future<void> fetchParkingData() async {
    final encodedPname =
        Uri.encodeComponent(selectHname.value); // 선택된 공원 이름 인코딩
    final url =
        Uri.parse("http://127.0.0.1:8000/hanriver/citydata/$encodedPname");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      print("Response Data: $data"); // 디버깅용

      final List<dynamic> parkingList = data['주차장 현황'];

      int total = 0;
      for (var parking in parkingList) {
        int capacity = int.parse(parking['CPCTY']);
        int currentParking = int.parse(parking['CUR_PRK_CNT']);
        total += (capacity - currentParking);
      }

      totalAvailableParking.value = total;
      // print("Total Available Parking: $total");
    } else {
      // print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  }
}
