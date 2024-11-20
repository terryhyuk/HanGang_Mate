import 'package:flutter/material.dart';
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: ListView.builder(
                          itemCount: controller.parkingInfo.length,
                          itemBuilder: (context, index) {
                            var result = controller.parkingInfo[index];
                          return Center(
                            child: Row(
                              children: [
                                Text(result.pname),
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
                      )
                    ],
                  ),
                );
              }
            },
          );
      },)
    );
  }
}