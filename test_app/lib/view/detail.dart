import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:get/get.dart';
import 'package:test_app/view/routes.dart';
import 'package:test_app/vm/location_handler.dart';
import 'package:test_app/constants/theme.dart';

class Detail extends StatelessWidget {
  Detail({super.key});
  final LocationHandler controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(controller.selectHname.value),
        ),
        body: SingleChildScrollView(
          child: GetBuilder<LocationHandler>(
            builder: (_) {
              return Obx(
                () {
                  if (controller.predvalue.value == false) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator(), Text('예측중')],
                      ),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _gaugeWidget(context),
                        const Text(
                          '길찾기',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        _parkingWidget(context),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '      예상혼잡도',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        _predictWidget(context)
                      ],
                    );
                  }
                },
              );
              // else{
              //   return Center(
              //     child: Column(
              //       children: [
              //         CircularProgressIndicator(),
              //         Text('.....예측하는중.....')
              //       ],
              //     ),
              //   );
              // }
            },
          ),
        ));
  }

// 주차장 현황 게이지
  Widget _gaugeWidget(context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.parkingInfo.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, //한줄에 출력될 개수
          ),
          itemBuilder: (context, index) {
            return Column(
              children: [
                Text(controller.parkingInfo[index].pname),
                AnimatedRadialGauge(
                  duration: const Duration(seconds: 1),
                  curve: Curves.linear,
                  radius: 50,
                  value: controller.parkingCapacity[index],
                  axis: const GaugeAxis(
                    min: 0,
                    max: 100,
                    degrees: 180,
                    progressBar: GaugeBasicProgressBar(
                      color: percentClr,
                    ),
                    segments: [
                      GaugeSegment(
                        from: 0,
                        to: 100,
                        border: GaugeBorder(color: Colors.black),
                      )
                    ],
                    style: GaugeAxisStyle(
                      background: Colors.transparent,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                      '${controller.parkingCapacity[index].toStringAsFixed(1)}%'),
                )
              ],
            );
          },
        ),
        const Divider()
      ],
    );
  }

// 주차장 길찾기 목록
  Widget _parkingWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.parkingInfo.length,
          itemBuilder: (context, index) {
            return Center(
              child: Row(
                children: [
                  Text(controller.parkingInfo[index].pname),
                  IconButton(
                    onPressed: () async {
                      await controller.createRoute(index);
                      Get.to(Routes(), arguments: index);
                    },
                    icon: const Icon(Icons.directions_car),
                    style: IconButton.styleFrom(backgroundColor: mapButtonClr),
                  )
                ],
              ),
            );
          },
        ),
        const Divider()
      ],
    );
  }

// 주차장 혼잡도 예측값
  Widget _predictWidget(context) {
    List<Color> color = [pred1Clr, pred2Clr, pred3Clr, pred4Clr];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          //Map형태(dictionary)
          dropdownColor: dropDownBackgroundClr,
          iconEnabledColor: dropDownBackgroundClr,
          value: controller.selectedTime.value, //선택한 이름
          icon: const Icon(Icons.keyboard_arrow_down),
          items: controller.timeList
              .asMap()
              .entries
              .map<DropdownMenuItem<int>>((item) {
            return DropdownMenuItem<int>(
              value: item.key,
              child: Text(item.value),
            );
          }).toList(),
          onChanged: (int? value) {
            controller.selectedTime.value = value!;
            controller.predict();
          },
        ),
        const Text(
          '에상 혼잡도이므로 실제와 다를 수 있습니다',
          style: TextStyle(color: Colors.red),
        ),
        GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.parkingInfo.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //한줄에 출력될 개수
            ),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      controller.parkingInfo[index].pname,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black)),
                    child: DotsIndicator(
                      dotsCount: 4,
                      position: controller.dotsPosition(index),
                      decorator: DotsDecorator(
                          size: const Size(20, 20),
                          activeSize: const Size(20, 20),
                          color: Colors.black,
                          activeColor: color[controller.dotsPosition(index)]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      controller.parkingInfo[index].predictMessage!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  // )
                ],
              );
            })
      ],
    );
  }
}
