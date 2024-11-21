
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:get/get.dart';
import 'package:test_app/view/routes.dart';
import 'package:test_app/vm/location_handler.dart';

class Detail extends StatelessWidget {
  Detail({super.key});
  final LocationHandler controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.selectHname.value),
      ),
      body: GetBuilder<LocationHandler>(
        builder: (_) {
          return Obx(
            () {
              if(controller.parkingInfo.isEmpty){
                return const Text('ERROR');
              }else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _gauge(context),
                      ),
                      const Divider(),
                      _parking_list(context)
                    ],
                  ),
                );
              }
            },
          );
      },)
    );
  }


// 주차장 현황 게이지 
Widget _gauge (context) {
  return GridView.builder(
    itemCount: controller.parkingInfo.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //한줄에 출력될 개수
            ),
            itemBuilder: (context, index) {
    return  Column(
      children: [
        Text(controller.parkingInfo[index].pname),
        AnimatedRadialGauge(
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
        radius: 50,
        value: controller.parkingInfo[index].lat,
        axis:  const GaugeAxis(
          min: 0,
          max: 100,
          degrees: 180,
          segments: [
            GaugeSegment(from: 0, to: 100, border: GaugeBorder(color: Colors.black),)
          ],
          style: GaugeAxisStyle(
            background: Colors.transparent,
          ),
        ),
        ),
      ],
    );
            }
  );
}

Widget _parking_list(context){
        return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: ListView.builder(
                          itemCount: controller.parkingInfo.length,
                          itemBuilder: (context, index) {
                          return Center(
                            child: Row(
                              children: [
                                Text(controller.parkingInfo[index].pname),
                                IconButton(
                                  onPressed: () async{
                                    await controller.createRoute(index);
                                    Get.to(Routes(), arguments: index);
                                },
                                icon: const Icon(Icons.directions_car))
                              ],
                            ),
                          );
                        },),
                      );

}
}