
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:kt_app/attendance/attendance_helper.dart';
import 'attendance_controller.dart';

class AttendanceCameraScreen extends StatefulWidget {
  const AttendanceCameraScreen({super.key});

  @override
  State<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

class _AttendanceCameraScreenState extends State<AttendanceCameraScreen>
    with SingleTickerProviderStateMixin {
  final AttendanceController _controller = AttendanceController();
  late AnimationController _progressController;
  bool _hasShownBottomSheet = false;

  @override
  void initState() {
    super.initState();
    _controller.initialize();

    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() => setState(() {}));

    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    if (_controller.currentState == ScanState.matching) {
      if (!_progressController.isAnimating && _progressController.value < 1.0) {
        _progressController.forward();
      }
    } else if (_controller.currentState == ScanState.error ||
        _controller.currentState == ScanState.searching) {
      if (_progressController.isAnimating || _progressController.value > 0) {
        _progressController.stop();
        _progressController.reset();
      }
    } else if (_controller.currentState == ScanState.identified &&
        !_hasShownBottomSheet) {
      _hasShownBottomSheet = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          builder: (context) => SuccessBottomSheet(
            userName: _controller.identifiedUserName,
            location: _controller.currentAddress,
            time: _controller.liveTime,
            date: _controller.liveDate,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // The guide line color still changes so the user knows it's working
  Color get _activeColor {
    switch (_controller.currentState) {
      case ScanState.searching:
        return const Color(0xFF555566);
      case ScanState.matching:
        return const Color(0xFFFFB000);
      case ScanState.identified:
        return const Color(0xFF33CC66);
      case ScanState.error:
        return const Color(0xFFFF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF141414),
          body: SafeArea(
            child: Column(
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Location and Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _controller.currentAddress == 'Fetching location...'
                                ? 'Fetching...'
                                : 'Location active',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('h:mm a').format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // NEW: Reload / Reset Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                          // Only allow reset if there is an error
                          onPressed: _controller.currentState == ScanState.error 
                              ? () => _controller.resetScanner()
                              : null, 
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Camera Frame ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_controller.isCameraInitialized &&
                              _controller.cameraController != null)
                            CameraPreview(_controller.cameraController!)
                          else
                            Container(color: Colors.black),

                          CustomPaint(
                            painter: DynamicFaceGuidePainter(
                              color: _activeColor,
                              isDashed:
                                  _controller.currentState ==
                                          ScanState.searching ||
                                      _controller.currentState == ScanState.error,
                              showIdentifiedUI:
                                  _controller.currentState ==
                                  ScanState.identified,
                            ),
                          ),

                          if (_controller.currentState == ScanState.identified)
                            Positioned(
                              bottom: 24,
                              left: 24,
                              right: 24,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _controller.identifiedUserName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '📍 ${_controller.currentAddress}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Positioned(
                              bottom: 30,
                              left: 0,
                              right: 0,
                              child: Text(
                                _controller.currentState == ScanState.error
                                    ? _controller.currentErrorMsg
                                    : 'Hold still...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      _controller.currentState ==
                                              ScanState.error
                                          ? const Color(0xFFFF4444)
                                          : Colors.white70,
                                  fontSize: 14,
                                  fontWeight:
                                      _controller.currentState ==
                                              ScanState.error
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Bottom Progress Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              (_controller.currentState ==
                                          ScanState.searching ||
                                      _controller.currentState == ScanState.error)
                                  ? 0.0
                                  : (_controller.currentState ==
                                          ScanState.identified
                                      ? 1.0
                                      : _progressController.value),
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _activeColor,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // _statusText removed from here
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}