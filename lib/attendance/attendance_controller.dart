import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';

enum ScanState { searching, matching, identified, error }

class AttendanceController extends ChangeNotifier {
  CameraController? _cameraController;
  CameraDescription? _frontCamera;
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;

  ScanState _currentState = ScanState.searching;
  String _currentErrorMsg = 'Align face to center.';
  String _currentAddress = 'Fetching location...';

  String _liveTime = '';
  String _liveDate = '';

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableTracking: false,
      enableClassification: true, // Keep true if you want eye-blink detection
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  // Getters for the View
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  ScanState get currentState => _currentState;
  String get currentErrorMsg => _currentErrorMsg;
  String get currentAddress => _currentAddress;
  String get liveTime => _liveTime;
  String get liveDate => _liveDate;

  String _identifiedUserName = '';
  String get identifiedUserName => _identifiedUserName;

  Future<void> initialize() async {
    _fetchLiveLocation();
    await _initializeFrontCamera();
  }

  Future<void> _fetchLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _currentAddress = 'Location services disabled.';
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _currentAddress = 'Location permissions denied';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _currentAddress = 'Location permissions permanently denied';
      notifyListeners();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high, // Fixed for your Geolocator version
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        List<String> addressParts = [];

        // 1. Building Name / Street / Premise (e.g., "Lotus Business Park" or "6th Floor")
        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        } else if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }

        // 2. Neighborhood (e.g., "Malad West")
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        // 3. City (e.g., "Mumbai")
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        // 4. District / Division (e.g., "Konkan Division")
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }

        // 5. State (e.g., "Maharashtra")
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // 6. Postal Code (e.g., "400064")
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        // 7. Country (e.g., "India")
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        // Combine everything with a comma and space
        _currentAddress = addressParts.join(", ");

        notifyListeners();
      }
    } catch (e) {
      _currentAddress = 'Failed to get location';
      notifyListeners();
    }
  }

  Future<void> _initializeFrontCamera() async {
    try {
      final cameras = await availableCameras();
      _frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        _frontCamera!,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;
      notifyListeners();

      _cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessingFrame && _currentState != ScanState.identified) {
          _processCameraFrame(image);
        }
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_frontCamera == null) return null;
    final sensorOrientation = _frontCamera!.sensorOrientation;
    final InputImageRotation? rotation = InputImageRotationValue.fromRawValue(
      sensorOrientation,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.isEmpty) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    _isProcessingFrame = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final List<Face> faces = await _faceDetector.processImage(inputImage);
      bool isFaceAligned = false;
      bool multipleFaces = faces.length > 1;

      if (faces.length == 1) {
        final Face detectedFace = faces.first;
        final Rect faceBox = detectedFace.boundingBox;

        final double frameWidth = Platform.isIOS
            ? image.width.toDouble()
            : image.height.toDouble();
        final double frameHeight = Platform.isIOS
            ? image.height.toDouble()
            : image.width.toDouble();

        final double screenCenterX = frameWidth / 2;
        final double screenCenterY = frameHeight / 2;

        final double faceCenterX = faceBox.left + (faceBox.width / 2);
        final double faceCenterY = faceBox.top + (faceBox.height / 2);

        final double distance = sqrt(
          pow(screenCenterX - faceCenterX, 2) +
              pow(screenCenterY - faceCenterY, 2),
        );

        final double maxAllowedDistance = frameWidth * 0.15;
        bool isInsideCircle = distance <= maxAllowedDistance;
        bool isCloseEnough = faceBox.width > (frameWidth * 0.65);

        if (isInsideCircle && isCloseEnough) {
          isFaceAligned = true;
        } else if (!isCloseEnough && isInsideCircle) {
          _currentState = ScanState.error;
          _currentErrorMsg = 'Move closer to the camera.';
          notifyListeners();
        }
      }

      if (multipleFaces) {
        if (_currentState != ScanState.error ||
            _currentErrorMsg != 'Multiple faces detected.') {
          _currentState = ScanState.error;
          _currentErrorMsg = 'Multiple faces detected.';
          notifyListeners();
        }
      } else if (isFaceAligned) {
        if (_currentState == ScanState.searching ||
            _currentState == ScanState.error) {
          _currentState = ScanState.matching;
          notifyListeners();

          _cameraController?.stopImageStream();

          // --- NO API: Process Locally ---
          _captureFaceLocally();
        }
      } else {
        if (_currentState == ScanState.matching ||
            (_currentState == ScanState.error &&
                faces.isEmpty &&
                _currentErrorMsg != 'Keep face inside the circle.')) {
          if (_currentErrorMsg != 'Move closer to the camera.') {
            _currentState = ScanState.error;
            _currentErrorMsg = 'Keep face inside the circle.';
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error processing frame: $e");
    } finally {
      _isProcessingFrame = false;
    }
    }

  // ==========================================
  // OFFLINE FACE CAPTURE (NO API NEEDED)
  // ==========================================
  Future<void> _captureFaceLocally() async {
    try {
      // 1. Capture the image from the camera
      XFile? capturedFile = await _cameraController?.takePicture();

      if (capturedFile == null) throw Exception("Failed to capture image");

      // 2. Save the image to the phone's gallery
      await Gal.putImage(capturedFile.path);
      debugPrint("Image saved to gallery: ${capturedFile.path}");

      // 3. Since there's no backend, we just assume success!
      // You can replace "Current User" with a variable if your app stores the logged-in user's name locally.
      triggerIdentifiedState("Current User");
    } catch (e) {
      _handleDetectionError("Failed to save image. Check gallery permissions.");
    }
  }

  void _handleDetectionError(String message) {
    _currentState = ScanState.error;
    _currentErrorMsg = message;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      if (_currentState != ScanState.identified) {
        _currentState = ScanState.searching;
        _startStreaming();
      }
    });
  }

  void _startStreaming() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessingFrame && _currentState != ScanState.identified) {
          _processCameraFrame(image);
        }
      });
    }
  }

  void triggerIdentifiedState([String? name]) {
    _cameraController?.stopImageStream();
    _currentState = ScanState.identified;

    if (name != null && name.trim().isNotEmpty) {
      _identifiedUserName = name;
    } else if (_identifiedUserName.isEmpty) {
      _identifiedUserName = "User Not Named";
    }

    final now = DateTime.now();
    _liveTime = DateFormat('h:mm a').format(now);
    _liveDate = DateFormat('EEE, d MMM yyyy').format(now);

    notifyListeners();
  }

  void resetScanner() {
    _cameraController?.stopImageStream();
    _currentState = ScanState.searching;
    _currentErrorMsg = 'Align face to center.';
    _isProcessingFrame = false;
    notifyListeners();
    _startStreaming();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}
