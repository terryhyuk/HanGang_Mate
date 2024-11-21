import 'package:flutter/material.dart';

class HollowCircleThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24); // Thumb 크기
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // 바깥쪽 원 테두리
    final Paint outerCircle = Paint()
      ..color = Colors.white // 테두리 색상
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 안쪽 채우기 (구멍)
    final Paint innerCircle = Paint()
      ..color = Colors.transparent // 배경과 동일한 색상
      ..style = PaintingStyle.fill;

    // 위치 조정을 위해 center의 y좌표를 트랙 높이만큼 올림
    final adjustedCenter = Offset(center.dx, center.dy - 4);

    // 바깥쪽 원 그리기
    canvas.drawCircle(adjustedCenter, 12, outerCircle);
    // 안쪽 구멍 그리기
    canvas.drawCircle(adjustedCenter, 8, innerCircle);
  }
}
