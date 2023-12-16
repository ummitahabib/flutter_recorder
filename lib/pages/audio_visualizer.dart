import 'package:flutter/material.dart';
import 'package:flutter_recorder/core/colors.dart';
import 'package:flutter_recorder/core/constants.dart';

class AudioVisualizer extends StatelessWidget {
  AudioVisualizer({super.key, required this.amplitude}) {
    double db = amplitude ?? RecorderConstants.decibleLimit;
    if (db == double.infinity || db < RecorderConstants.decibleLimit) {
      db = RecorderConstants.decibleLimit;
    }
    if (db > 0) {
      db = 0;
    }
    range = 1 - (db * (1 / RecorderConstants.decibleLimit));
    print(range);
  }
  final double? amplitude;
  final double maxHeight = 8;

  late final double range;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        children: [
          buildBar(0.15),
          buildBar(0.5),
          buildBar(0.75),
          buildBar(0.5),
          buildBar(1),
          buildBar(0.5),
          buildBar(0.15),
          buildBar(0.5),
          buildBar(0.25),
          buildBar(0.75),
          buildBar(0.5),
          buildBar(1),
          buildBar(0.75),
          buildBar(0.5),
          buildBar(0.25),
        ],
      ),
    );
  }

  buildBar(double intensity) {
    double barHeight = (amplitude ?? 0) * 1 * intensity;

    if (barHeight < 3) {
      barHeight = 3;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: RecorderConstants.amplitudeCaptureRateInMilliSeconds,
        ),
        height: barHeight,
        width: 2,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          color: AppColors.recordGrey,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              spreadRadius: 1,
              offset: Offset(1, 1),
            ),
            BoxShadow(
              color: AppColors.recorderWhite,
              spreadRadius: 1,
              offset: Offset(-1, -1),
            ),
          ],
        ),
      ),
    );
  }
}
