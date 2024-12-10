import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RiverPark_Mate/view/routes.dart';
import 'package:RiverPark_Mate/vm/location_handler.dart';
import 'package:RiverPark_Mate/constants/theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
                        testGaugeWidget(context),
                        // _gaugeWidget(context),
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
                    padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
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
            dropdownColor: dropDownBackgroundClr,
            iconEnabledColor: const Color.fromARGB(255, 0, 0, 0),
            value: controller.selectedTime.value, //선택한 시간
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

// TEST
  // TEST
  Widget testGaugeWidget(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.parkingInfo.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth < 600 ? 2 : 3, // 화면 크기에 따라 열 수 변경
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final double capacity = controller.parkingCapacity[index];

            // 퍼센트 값에 따른 색상 결정
            Color getCapacityColor(double value) {
              if (value >= 80) {
                return Colors.blueAccent; // 80% 이상: 초록색
              } else if (value >= 50) {
                return Colors.orangeAccent; // 50% 이상: 주황색
              } else if (value > 0) {
                return Colors.redAccent; // 0% 초과 50% 미만: 빨간색
              } else {
                return Colors.grey; // 0% 또는 없음: 회색
              }
            }

            final Color capacityColor = getCapacityColor(capacity);

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                color: Colors.white, // 단색 배경으로 차분하게 변경
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 상단 아이콘과 텍스트
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.local_parking,
                          size: 30,
                          color: capacityColor, // 아이콘 색상 설정
                        ),
                        Expanded(
                          child: Text(
                            controller.parkingInfo[index].pname,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis, // 텍스트가 넘칠 경우 처리
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 게이지
                    SizedBox(
                      height: screenWidth < 600 ? 100 : 120, // 화면 크기에 따라 크기 조정
                      width: screenWidth < 600 ? 100 : 120,
                      child: SfRadialGauge(
                        axes: <RadialAxis>[
                          RadialAxis(
                            minimum: 0,
                            maximum: 100,
                            startAngle: 180,
                            endAngle: 0,
                            showLabels: false,
                            showTicks: false,
                            radiusFactor: 0.8,
                            axisLineStyle: const AxisLineStyle(
                              thickness: 0.2,
                              thicknessUnit: GaugeSizeUnit.factor,
                            ),
                            pointers: <GaugePointer>[
                              RangePointer(
                                value: capacity,
                                width: 0.2,
                                sizeUnit: GaugeSizeUnit.factor,
                                enableAnimation: true,
                                animationType: AnimationType.easeOutBack,
                                color: capacityColor, // 게이지 색상 설정
                              ),
                              NeedlePointer(
                                value: capacity,
                                needleColor: Colors.black87,
                                knobStyle: const KnobStyle(
                                  color: Colors.black87,
                                  sizeUnit: GaugeSizeUnit.factor,
                                  knobRadius: 0.06,
                                ),
                                enableAnimation: true,
                                animationType: AnimationType.ease,
                              ),
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                widget: Text(
                                  '${capacity.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                angle: 90,
                                positionFactor: 0.5,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 상태 메시지
                    Text(
                      capacity >= 80
                          ? 'High Availability'
                          : capacity >= 50
                              ? 'Moderate Availability'
                              : capacity > 0
                                  ? 'Low Availability'
                                  : 'No Parking Available',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const Divider(
          thickness: 2.5,
          color: Colors.black54,
        ),
      ],
    );
  }
}
