import 'package:flutter/material.dart';
import 'package:lencho/widgets/BushCloudPainter.dart';
import 'dart:math' as math;

class BushCloudRotated extends StatelessWidget {
  const BushCloudRotated({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      // Rotate 180 degrees.
      angle: math.pi,
      // Set the alignment to topCenter so the rotation is anchored at the top.
      alignment: Alignment.topCenter,
      child: CustomPaint(
        painter: BushCloudPainter(heightShift: -0.45),
        child: Container(), // The Container takes the size from the parent.
      ),
    );
  }
}
