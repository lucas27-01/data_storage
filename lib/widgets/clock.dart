import 'dart:math';

import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key, required this.time, this.greater = false});
  final TimeOfDay time;
  final bool greater;

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: ClockPainter(time: widget.time, greater: widget.greater),
        size: widget.greater ? const Size(300, 300) : const Size(24, 24),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final TimeOfDay time;
  final bool greater;

  ClockPainter({required this.time, this.greater = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Draw clock border
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = greater ? 6 : 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Angle for clock hands
    final hourAngle = (time.hour % 12 + time.minute / 60) * 30 * pi / 180;
    final minuteAngle = (time.minute) * 6 * pi / 180;

    // Draw the hour clock hands
    final hourHandLength = radius * (greater ? .7 : .3);
    final hourHandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = greater ? 10 : 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      center +
          Offset(
              cos(hourAngle) * hourHandLength, sin(hourAngle) * hourHandLength),
      hourHandPaint,
    );

    // Draw the minute clock hands
    final minuteHandLength = radius * (greater ? .9 : .5);
    final minuteHandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = greater ? 8 : 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      center +
          Offset(cos(minuteAngle) * minuteHandLength,
              sin(minuteAngle) * minuteHandLength),
      minuteHandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
