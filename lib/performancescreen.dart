// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kt_app/quarterly_performance%20%20%20.dart';
import 'package:kt_app/attendance/attendancecreen.dart';
import 'package:kt_app/awardsscreen.dart';

class PerformanceScreen extends StatefulWidget {
  final String title;

  const PerformanceScreen({super.key, required this.title});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  // --- DYNAMIC KPI DATA (Initialized with Fallback Dummy Data) ---
  String _avgRating = "4.8";
  String _attendancePct = "98%";
  String _awardsCount = "3";

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  // ==========================================
  // API CALL: FETCH PERFORMANCE SUMMARY
  // ==========================================
  Future<void> _fetchPerformanceData() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Performance Summary
      final response = await http.get(
        Uri.parse('$baseUrl/performance/summary'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          setState(() {
            // Update the KPI metrics with live data, keeping fallbacks if null
            _avgRating = data['data']['avg_rating']?.toString() ?? _avgRating;
            _attendancePct =
                data['data']['attendance_percentage']?.toString() ??
                _attendancePct;
            _awardsCount =
                data['data']['awards_count']?.toString() ?? _awardsCount;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch performance data: $e");
      // Silently falls back to dummy data if API fails!
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        title: const Text(
          "Performance",
          style: TextStyle(
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
                  // --- THE 3 KPI CARDS ---
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1, // Adjusts height/width ratio
                    children: [
                      // 1. RATING CARD
                      _buildKPICard(
                        icon: Icons.star_border_rounded,
                        iconBg: const Color(0xFFFFF9E6),
                        iconColor: const Color(0xFFF0A500),
                        value: _avgRating, // Dynamic Value
                        label: "AVG RATING",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RatingDetailScreen(),
                            ),
                          );
                        },
                      ),

                      // 2. ATTENDANCE CARD
                      _buildKPICard(
                        icon: Icons.calendar_today_outlined,
                        iconBg: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF2E7D32),
                        value: _attendancePct.contains('%')
                            ? _attendancePct
                            : "$_attendancePct%", // Ensures % is shown
                        label: "ATTENDANCE",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AttendanceScreen(title: ''),
                            ),
                          );
                        },
                      ),

                      // 3. AWARDS CARD
                      _buildKPICard(
                        icon: Icons.emoji_events_outlined,
                        iconBg: const Color(0xFFF3E5F5), // Light purple
                        iconColor: const Color(0xFF8E24AA), // Purple
                        value: _awardsCount, // Dynamic Value
                        label: "AWARDS",
                        onTap: () {
                          // Navigate to the Awards Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AwardsScreen(
                                title: "Awards & Recognition",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Helper for KPI Grid Cards
  Widget _buildKPICard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
