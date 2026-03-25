// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RatingDetailScreen extends StatefulWidget {
  const RatingDetailScreen({super.key});

  @override
  State<RatingDetailScreen> createState() => _RatingDetailScreenState();
}

class _RatingDetailScreenState extends State<RatingDetailScreen> {
  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = false;

  // Cache for fetched API scores to prevent redundant network calls
  // Key format: "Year-QuarterIndex" e.g., "2026-0"
  final Map<String, List<double>> _apiScoresCache = {};

  // Quarter Data Logic
  int currentQuarterIndex = 0; // 0 = Q1, 1 = Q2, 2 = Q3, 3 = Q4
  int currentYear = 2026;

  late int maxQuarterIndex;
  late int maxYear;

  final List<String> quarterNames = [
    "Jan - March",
    "April - June",
    "July - Sept",
    "Oct - Dec",
  ];

  final List<String> quarterEndDates = [
    "31 March",
    "30 June",
    "30 Sept",
    "31 Dec",
  ];

  // --- FALLBACK DUMMY DATA FOR 2026 ---
  final Map<int, List<double>> fallbackScores2026 = {
    0: [4.5, 4.0, 4.8], // Q1: HR, Performance, Attendance
    1: [4.8, 4.5, 5.0], // Q2
    2: [3.5, 3.2, 3.8], // Q3
    3: [4.2, 4.0, 4.5], // Q4
  };

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    maxYear = now.year; // Dynamic based on current year

    if (now.month >= 1 && now.month <= 3) {
      maxQuarterIndex = 0;
    } else if (now.month >= 4 && now.month <= 6) {
      maxQuarterIndex = 1;
    } else if (now.month >= 7 && now.month <= 9) {
      maxQuarterIndex = 2;
    } else {
      maxQuarterIndex = 3;
    }

    currentQuarterIndex = maxQuarterIndex;
    currentYear = maxYear;

    _fetchQuarterData();
  }

  // ==========================================
  // API CALL: FETCH QUARTERLY SCORES
  // ==========================================
  Future<void> _fetchQuarterData() async {
    // If we are looking at the current active quarter, no need to fetch scores (Evaluation in progress)
    if (currentYear == maxYear && currentQuarterIndex == maxQuarterIndex)
      return;

    String cacheKey = "$currentYear-$currentQuarterIndex";

    // If we already fetched this quarter's data, load it instantly from cache
    if (_apiScoresCache.containsKey(cacheKey)) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Replace with your exact Swagger endpoint for GET Quarterly Performance
      // We pass the year and quarter (1-4) as query parameters
      final response = await http.get(
        Uri.parse(
          '$baseUrl/performance/quarterly?year=$currentYear&quarter=${currentQuarterIndex + 1}',
        ),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          // Expecting the API to return something like: { "hr_score": 4.5, "perf_score": 4.0, "att_score": 4.8 }
          double hr = (data['data']['hr_score'] ?? 0.0).toDouble();
          double perf = (data['data']['perf_score'] ?? 0.0).toDouble();
          double att = (data['data']['att_score'] ?? 0.0).toDouble();

          if (mounted) {
            setState(() {
              _apiScoresCache[cacheKey] = [hr, perf, att];
            });
          }
        }
      }
    } catch (e) {
      print("Failed to fetch quarter data: $e");
      // Silently fall back to dummy data if API fails
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper to get scores (prefers API Cache -> then 2026 Fallback -> then Zeros)
  List<double> _getCurrentScores() {
    String cacheKey = "$currentYear-$currentQuarterIndex";
    if (_apiScoresCache.containsKey(cacheKey)) {
      return _apiScoresCache[cacheKey]!;
    }
    if (currentYear == 2026 &&
        fallbackScores2026.containsKey(currentQuarterIndex)) {
      return fallbackScores2026[currentQuarterIndex]!;
    }
    return [
      0.0,
      0.0,
      0.0,
    ]; // Default empty state if no data exists for past years
  }

  void _nextQuarter() {
    if (currentYear == maxYear && currentQuarterIndex >= maxQuarterIndex)
      return;
    setState(() {
      if (currentQuarterIndex < 3) {
        currentQuarterIndex++;
      } else {
        currentQuarterIndex = 0;
        currentYear++;
      }
    });
    _fetchQuarterData(); // Fetch data for the new quarter
  }

  void _prevQuarter() {
    setState(() {
      if (currentQuarterIndex > 0) {
        currentQuarterIndex--;
      } else {
        currentQuarterIndex = 3;
        currentYear--;
      }
    });
    _fetchQuarterData(); // Fetch data for the new quarter
  }

  @override
  Widget build(BuildContext context) {
    String currentQtrName = quarterNames[currentQuarterIndex];
    bool isCurrentOrFutureQuarter =
        (currentYear == maxYear && currentQuarterIndex == maxQuarterIndex);
    bool canGoNext =
        !(currentYear == maxYear && currentQuarterIndex >= maxQuarterIndex);

    List<double> currentScores = _getCurrentScores();

    // --- CALCULATIONS ---
    double sum = currentScores[0] + currentScores[1] + currentScores[2];
    double overallRating = double.parse(
      (sum / 3).toStringAsFixed(1),
    ); // Average out of 5.0
    int overallPercentage = ((overallRating / 5) * 100)
        .round(); // For Circular bar

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
          "Quarterly Performance",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- QUARTER SWITCHER ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : _prevQuarter,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: Color(0xFF38468E),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "$currentQtrName $currentYear",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCurrentOrFutureQuarter
                            ? "Currently Active"
                            : "Completed",
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentOrFutureQuarter
                              ? Colors.green.shade600
                              : Colors.grey.shade500,
                          fontWeight: isCurrentOrFutureQuarter
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _nextQuarter,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: canGoNext
                            ? const Color(0xFF38468E)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- COMBINED DASHBOARD CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: isCurrentOrFutureQuarter
                  ? _buildEvaluationInProgress()
                  : _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF38468E),
                        ),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // LEFT SIDE: OVERALL CIRCLE + RATING BELOW
                        _buildOverallSection(overallPercentage, overallRating),

                        const SizedBox(width: 24),

                        // RIGHT SIDE: METRIC STAR ROWS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetricRow(
                                "HR Evaluation",
                                currentScores[0],
                              ),
                              const SizedBox(height: 20),
                              _buildMetricRow("Performance", currentScores[1]),
                              const SizedBox(height: 20),
                              _buildMetricRow("Attendance", currentScores[2]),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSection(int percentage, double rating) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: percentage.isNaN ? 0 : percentage / 100,
                strokeWidth: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF38468E),
                ),
              ),
            ),
            Text(
              percentage.isNaN ? "0%" : "$percentage%",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "OVERALL",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => _buildSingleStar(rating, index, size: 14),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          rating.isNaN ? "0.0 / 5.0" : "$rating / 5.0",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF38468E),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => _buildSingleStar(score, index, size: 22),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$score / 5.0",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Helper widget to handle Full, Half, and Empty stars
  Widget _buildSingleStar(double score, int index, {double size = 20}) {
    if (score.isNaN) score = 0.0;
    double difference = score - index;
    IconData icon;
    Color color;

    if (difference >= 1) {
      icon = Icons.star_rounded;
      color = const Color(0xFFF0A500);
    } else if (difference >= 0.5) {
      icon = Icons.star_half_rounded;
      color = const Color(0xFFF0A500);
    } else {
      icon = Icons.star_outline_rounded;
      color = Colors.grey.shade300;
    }

    return Icon(icon, color: color, size: size);
  }

  Widget _buildEvaluationInProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.hourglass_empty, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Evaluation in progress",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Detailed scores will be available soon.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
