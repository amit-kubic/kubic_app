import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class PunchScreen extends StatefulWidget {
  final String type; // "Punch In" or "Punch Out"

  const PunchScreen({super.key, required this.type});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  XFile? image;
  String location = "Fetching location...";
  bool isGpsVerified = false;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  /// OPEN CAMERA - Forced to Front Camera
  Future openCamera() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front, // 👈 FORCES FRONT CAMERA
      );
      if (pickedFile != null) {
        setState(() {
          image = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
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

  /// CONVERT COORDINATES TO FULL ADDRESS (Fixed the Error in your screenshot)
  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      // Safe way to build the address string without ternary errors
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
        location = addressParts.join(
          ", ",
        ); // Joins all parts with a comma automatically
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
        onPressed: image == null
            ? null
            : () {
                String currentTime = DateFormat(
                  'hh:mm a',
                ).format(DateTime.now());
                Navigator.pop(context, currentTime);
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
      onTap: openCamera,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap to capture photo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    "Your selfie is required to verify attendance",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: openCamera,
                    child: const Text(
                      "Open Camera",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: kIsWeb
                        ? Image.network(
                            image!.path,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(image!.path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF28A745),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 14),
                          Text(
                            " Photo captured",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
