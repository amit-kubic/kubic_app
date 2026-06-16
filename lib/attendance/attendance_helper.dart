//import 'package:attandance_app/view/attendance_log/attendance_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kt_app/attendance_detail_screen.dart';

class DynamicFaceGuidePainter extends CustomPainter {
  final Color color;
  final bool isDashed;
  final bool showIdentifiedUI;

  DynamicFaceGuidePainter({
    required this.color,
    required this.isDashed,
    required this.showIdentifiedUI,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const double cornerLength = 30.0;
    const double padding = 24.0;

    canvas.drawPath(
      Path()
        ..moveTo(padding, padding + cornerLength)
        ..lineTo(padding, padding)
        ..lineTo(padding + cornerLength, padding),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding - cornerLength, padding)
        ..lineTo(size.width - padding, padding)
        ..lineTo(size.width - padding, padding + cornerLength),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(padding, size.height - padding - cornerLength)
        ..lineTo(padding, size.height - padding)
        ..lineTo(padding + cornerLength, size.height - padding),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding - cornerLength, size.height - padding)
        ..lineTo(size.width - padding, size.height - padding)
        ..lineTo(size.width - padding, size.height - padding - cornerLength),
      paint,
    );

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + 10),
      width: 150,
      height: 220,
    );

    if (isDashed) {
      Path dashedPath = Path();
      for (var measurePath in (Path()..addOval(ovalRect)).computeMetrics()) {
        double distance = 0.0;
        while (distance < measurePath.length) {
          dashedPath.addPath(
            measurePath.extractPath(distance, distance + 8.0),
            Offset.zero,
          );
          distance += 14.0;
        }
      }
      canvas.drawPath(dashedPath, paint);
    } else {
      canvas.drawOval(ovalRect, paint);
    }

    if (showIdentifiedUI) {
      canvas.drawCircle(
        Offset(size.width - padding - 10, padding + 10),
        14,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.width - padding - 15, padding + 10)
          ..lineTo(size.width - padding - 11, padding + 15)
          ..lineTo(size.width - padding - 4, padding + 5),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawLine(
        Offset(size.width / 2 - 100, size.height / 2 + 135),
        Offset(size.width / 2 + 100, size.height / 2 + 135),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DynamicFaceGuidePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.isDashed != isDashed ||
      oldDelegate.showIdentifiedUI != showIdentifiedUI;
}

class SuccessBottomSheet extends StatelessWidget {
  final String userName;
  final String location;
  final String time;
  final String date;

  const SuccessBottomSheet({
    super.key,
    required this.userName,
    required this.location,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE6F9EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF33CC66), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Attendance Marked!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$userName\n📍 $location • $time\n$date',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555566),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AttendanceDetailScreen(data: {}),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Log',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ADD THIS IMPORT AT THE TOP OF THE FILE IF IT'S NOT THERE:
              // import 'package:intl/intl.dart';
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Grab the exact time they clicked Done
                    String punchTime = DateFormat(
                      'hh:mm a',
                    ).format(DateTime.now());

                    Navigator.pop(context); // 1. Closes the bottom sheet
                    Navigator.pop(
                      context,
                      punchTime,
                    ); // 2. Closes camera and sends time to dashboard!
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
