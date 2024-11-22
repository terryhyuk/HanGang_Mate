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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
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
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '길찾기',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        _parkingWidget(context),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '예상혼잡도',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
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
                Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: SizedBox(
                      width: 120,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 53, 53, 53),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            controller.parkingInfo[index].pname,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 44, 109, 45),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )),
                AnimatedRadialGauge(
                  duration: const Duration(seconds: 1),
                  curve: Curves.linear,
                  radius: 50,
                  value: controller.parkingCapacity[index],
                  axis: GaugeAxis(
                    min: 0,
                    max: 100,
                    degrees: 180,
                    progressBar: GaugeBasicProgressBar(
                      color: controller.parkingCapacity[index] <= 40
                          ? const Color.fromARGB(255, 253, 136, 106)
                          : const Color.fromARGB(255, 136, 202, 255),
                    ),
                    segments: const [
                      GaugeSegment(
                        from: 0,
                        to: 100,
                        border: GaugeBorder(color: Colors.black),
                      ),
                    ],
                    style: const GaugeAxisStyle(
                      background: Colors.transparent,
                    ),
                  ),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      '${controller.parkingCapacity[index].toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ),
                const Text(
                  'Parking available',
                  style: TextStyle(
                      color: Color.fromARGB(255, 58, 59, 59),
                      fontWeight: FontWeight.w500),
                ),
              ],
            );
          },
        ),
        const Divider(
          thickness: 2.5,
          color: Color.fromARGB(208, 0, 0, 0),
        )
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      controller.parkingInfo[index].pname,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: IconButton(
                        onPressed: () async {
                          await controller.createRoute(index);
                          Get.to(Routes(), arguments: index);
                        },
                        icon: const Icon(Icons.directions_car),
                        style: IconButton.styleFrom(
                          backgroundColor: mapButtonClr,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), //
                          ),
                        )),
                  )
                ],
              ),
            );
          },
        ),
        const Divider(
          thickness: 2.5,
          color: Color.fromARGB(208, 0, 0, 0),
        )
      ],
    );
  }

// 주차장 혼잡도 예측값
  Widget _predictWidget(context) {
    List<Color> color = [pred1Clr, pred2Clr, pred3Clr, pred4Clr];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '예상 혼잡도이므로 실제와 다를 수 있습니다.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: DropdownButton<int>(
            //Map형태(dictionary)
            dropdownColor: dropDownBackgroundClr,
            iconEnabledColor: const Color.fromARGB(255, 0, 0, 0),
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
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      controller.parkingInfo[index].pname,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black)),
                    child: DotsIndicator(
                      dotsCount: 4,
                      position: controller.dotsPosition(index),
                      decorator: DotsDecorator(
                          size: const Size(25, 25),
                          activeSize: const Size(25, 25),
                          color: const Color.fromARGB(120, 0, 0, 0),
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
