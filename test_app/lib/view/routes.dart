import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_app/vm/location_handler.dart';

class Routes extends StatelessWidget {
  Routes({super.key});
final LocationHandler controller = Get.find();
  @override
  Widget build(BuildContext context) {
    final index = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
      ),
      body: _googleMap(context,index),
    );
  }



  Widget _googleMap(context,index) {
    return GoogleMap(
      mapType: MapType.terrain,
      initialCameraPosition: CameraPosition(
        zoom: 13,
        target: LatLng(
            controller.currentlat.value, controller.currentlng.value),
      ),
      onMapCreated: (GoogleMapController mapController) {
        controller.routesController.value = mapController;
      },
      markers:{
        Marker(
          markerId: MarkerId(controller.selectParking.value),
          position: LatLng(controller.parkingInfo[index].lat, controller.parkingInfo[index].lng)
        )
      },
      polylines: controller.lines.toSet(),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
    );
  }

}