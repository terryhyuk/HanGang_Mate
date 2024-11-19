import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/Model/parking.dart';

class LocationHandler extends GetxController {
  var parkingInfo = <Parking>[].obs;
  final RxDouble currentlat = 0.0.obs;
  final RxDouble currentlng = 0.0.obs;
  var hnameList = [].obs;
  var selectHname = ''.obs;
  final parkingMarker = <Marker>[].obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);

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
}
