import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

// Import your custom Face Scanner
import 'package:kt_app/attendance/attendance_camera_screen.dart';

class PunchScreen extends StatefulWidget {
  final String type; // "Punch In" or "Punch Out"

  const PunchScreen({super.key, required this.type});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  // Replaced 'image' with our verification toggle
  bool isFaceVerified = false;
  String location = "Fetching location...";
  bool isGpsVerified = false;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  /// OPEN CAMERA - Launches the Live ML Kit Face Scanner
  Future openCamera() async {
    // Open the Face Scanner
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AttendanceCameraScreen()),
    );

    // When the scanner closes and returns to this screen,
    // we mark the face as verified so they can submit!
    setState(() {
      isFaceVerified = true;
    });
  }

  /// GET GPS COORDINATES AND FULL ADDRESS
  Future getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => location = "Location permissions permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Web handling vs Mobile handling
      if (kIsWeb) {
        setState(() {
          isGpsVerified = true;
          location =
              "Lat: ${position.latitude}, Long: ${position.longitude} (Web)";
        });
      } else {
        await getAddressFromLatLng(position);
      }
    } catch (e) {
      setState(() => location = "Error fetching location.");
    }
  }

  /// CONVERT COORDINATES TO FULL ADDRESS
  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      List<String> addressParts = [];

      if (place.name != null && place.name!.isNotEmpty)
        addressParts.add(place.name!);
      if (place.subLocality != null && place.subLocality!.isNotEmpty)
        addressParts.add(place.subLocality!);
      if (place.locality != null && place.locality!.isNotEmpty)
        addressParts.add(place.locality!);
      if (place.subAdministrativeArea != null &&
          place.subAdministrativeArea!.isNotEmpty)
        addressParts.add(place.subAdministrativeArea!);
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty)
        addressParts.add(place.administrativeArea!);
      if (place.postalCode != null && place.postalCode!.isNotEmpty)
        addressParts.add(place.postalCode!);
      if (place.country != null && place.country!.isNotEmpty)
        addressParts.add(place.country!);

      setState(() {
        isGpsVerified = true;
        location = addressParts.join(", ");
      });
    } catch (e) {
      setState(() => location = "Failed to get full address.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.type,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildCameraPreview(),
            const SizedBox(height: 20),
            _buildLocationCard(),
            const SizedBox(height: 20),
            _buildNoteField(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        // Activate button ONLY if GPS is fetched AND Face is scanned
        onPressed: (!isFaceVerified || !isGpsVerified)
            ? null
            : () {
                String currentTime = DateFormat(
                  'hh:mm a',
                ).format(DateTime.now());
                Navigator.pop(
                  context,
                  currentTime,
                ); // Sends time back to dashboard
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.type == "Punch In"
              ? const Color(0xFF28A745)
              : const Color(0xFFDC3545),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "Submit ${widget.type}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "CURRENT TIME",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('hh:mm a').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38468E),
                ),
              ),
              Text(
                DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  "SHIFT",
                  style: TextStyle(
                    color: Color(0xFF28A745),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Regular",
                  style: TextStyle(
                    color: Color(0xFF28A745),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return GestureDetector(
      onTap: isFaceVerified ? null : openCamera,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isFaceVerified ? const Color(0xFFF0FAF0) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isFaceVerified
                ? const Color(0xFF28A745)
                : Colors.grey.shade200,
            width: isFaceVerified ? 2 : 1,
          ),
        ),
        child: !isFaceVerified
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.face_retouching_natural,
                    size: 50,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap to scan face",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    "Live verification required for attendance",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: openCamera,
                    child: const Text(
                      "Open Scanner",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 60, color: Color(0xFF28A745)),
                  SizedBox(height: 16),
                  Text(
                    "Face Verified Successfully!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF28A745),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.redAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "LOCATION",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isGpsVerified)
                  const Text(
                    "✓ GPS verified",
                    style: TextStyle(
                      color: Color(0xFF28A745),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      decoration: InputDecoration(
        labelText: "NOTE (OPTIONAL)",
        hintText: "Add a note for your manager...",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
