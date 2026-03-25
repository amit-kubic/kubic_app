// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AwardsScreen extends StatefulWidget {
  final String title;

  const AwardsScreen({super.key, required this.title});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  // --- DYNAMIC AWARD DATA (Initialized with Fallback Dummy Data) ---
  Map<String, dynamic> awardData = {
    "award_title": "Employee of the Month",
    "image_url": "", // Empty means it will use your local asset fallback
    "recipient_name": "Jatin Dixit",
    "recipient_role": "Software Developer • Engineering",
    "remark_title": "Excellence in Performance",
    "remark_desc":
        "Jatin has consistently demonstrated outstanding technical skills and a proactive attitude throughout the quarter. His contribution to the 'Field Forces' application architecture significantly improved the app's performance by 40%.",
    "awarded_date": "14 March 2026",
  };

  @override
  void initState() {
    super.initState();
    _fetchAwardDetails();
  }

  // ==========================================
  // API CALL: FETCH AWARD DETAILS
  // ==========================================
  Future<void> _fetchAwardDetails() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Awards
      final response = await http.get(
        Uri.parse('$baseUrl/awards/latest'), // Example endpoint
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          setState(() {
            // Overwrite fallback data with live API data
            // Make sure the keys here match exactly what your backend sends!
            awardData = {
              "award_title":
                  data['data']['award_title'] ?? awardData['award_title'],
              "image_url": data['data']['image_url'] ?? "",
              "recipient_name":
                  data['data']['recipient_name'] ?? awardData['recipient_name'],
              "recipient_role":
                  data['data']['recipient_role'] ?? awardData['recipient_role'],
              "remark_title":
                  data['data']['remark_title'] ?? awardData['remark_title'],
              "remark_desc":
                  data['data']['remark_desc'] ?? awardData['remark_desc'],
              "awarded_date":
                  data['data']['awarded_date'] ?? awardData['awarded_date'],
            };
          });
        }
      }
    } catch (e) {
      print("Failed to fetch award details: $e");
      // If API fails, it safely falls back to the dummy data
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to extract initials from the dynamic name
  String _getInitials(String name) {
    List<String> names = name.trim().split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (int i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0].toUpperCase();
      }
    }
    return initials.isEmpty ? "E" : initials; // "E" for Employee if empty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.black54,
              size: 20,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF38468E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- AWARD IMAGE SECTION ---
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Dynamic Image Handling (Network vs Local Asset)
                          awardData['image_url'].toString().isNotEmpty
                              ? Image.network(
                                  awardData['image_url'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackImage(),
                                )
                              : Image.asset(
                                  "assets/images/award_banner.png",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackImage(),
                                ),

                          // Gradient Overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Dynamic Award Title
                          Positioned(
                            bottom: 15,
                            left: 20,
                            child: Text(
                              awardData['award_title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- EMPLOYEE INFO SECTION ---
                  const Text(
                    "RECIPIENT INFO",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Text(
                            _getInitials(awardData['recipient_name']),
                            style: const TextStyle(
                              color: Color(0xFF38468E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                awardData['recipient_name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                awardData['recipient_role'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- REMARKS / INFO SECTION ---
                  const Text(
                    "ACHIEVEMENT REMARK",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_quote,
                              color: Color(0xFF38468E),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                awardData['remark_title'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF38468E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          awardData['remark_desc'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Awarded on:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              awardData['awarded_date'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // Reusable fallback widget if image fails to load
  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFF38468E).withOpacity(0.1),
      child: const Icon(
        Icons.emoji_events_outlined,
        size: 80,
        color: Color(0xFF38468E),
      ),
    );
  }
}
