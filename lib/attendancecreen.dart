// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'attendance_detail_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required String title});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedMonth = DateTime.now();

  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";

  // --- STATE VARIABLES ---
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _currentMonthAttendance = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData(); // Fetch data when screen loads
  }

  // ==========================================
  // API CALL: FETCH ATTENDANCE DATA
  // ==========================================
  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format the month as YYYY-MM to send to the API
      String monthParam = DateFormat("yyyy-MM").format(selectedMonth);

      // TODO: Replace '/get-attendance' with your exact Swagger endpoint
      // Assuming your API accepts a query parameter for the month
      final response = await http.get(
        Uri.parse('$baseUrl/get-attendance?month=$monthParam'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // TODO: Ensure 'status' and 'data' match your Swagger response structure
        if (data['status'] == true) {
          setState(() {
            // Convert the dynamic list to a List<Map<String, dynamic>>
            _currentMonthAttendance = List<Map<String, dynamic>>.from(
              data['data'] ?? [],
            );
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? "Failed to fetch attendance.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Please check your connection.";
      });
      print("API Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = 0;
    int lateCount = 0;
    int absentCount = 0;
    int weeklyOffCount = 0;

    // Calculate stats from the live API data
    for (var day in _currentMonthAttendance) {
      if (day['status'] == 'Present')
        presentCount++;
      else if (day['status'] == 'Late')
        lateCount++;
      else if (day['status'] == 'Absent')
        absentCount++;
      else if (day['status'] == 'Weekly Off')
        weeklyOffCount++;
    }

    // Calculation logic for Progress Bar
    int totalDaysInList = _currentMonthAttendance.length;
    int actualWorkingDays = totalDaysInList - weeklyOffCount;
    int totalAttended = presentCount + lateCount;
    double rate = actualWorkingDays == 0
        ? 0.0
        : totalAttended / actualWorkingDays;
    int ratePercent = (rate * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Attendance",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildMonthSelector(_currentMonthAttendance.length),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38468E)),
                  )
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStatsRow(
                          presentCount,
                          absentCount,
                          lateCount,
                          weeklyOffCount,
                        ),
                        _buildMonthlyProgressBar(
                          rate,
                          ratePercent,
                          actualWorkingDays,
                          totalAttended,
                        ),
                        const SizedBox(height: 8),
                        if (_currentMonthAttendance.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              "No records found",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: _currentMonthAttendance.length,
                            itemBuilder: (context, index) =>
                                _buildAttendanceCard(
                                  _currentMonthAttendance[index],
                                ),
                          ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int present, int absent, int late, int weekOff) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildStatBox(
            present.toString(),
            "PRESENT",
            const Color(0xFFE8F5E9),
            const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 8),
          _buildStatBox(
            absent.toString(),
            "ABSENT",
            const Color(0xFFFFEBEE),
            const Color(0xFFC62828),
          ),
          const SizedBox(width: 8),
          _buildStatBox(
            late.toString(),
            "LATE",
            const Color(0xFFFFF8E1),
            const Color(0xFFF57F17),
          ),
          const SizedBox(width: 8),
          _buildStatBox(
            weekOff.toString(),
            "WEEK OFF",
            const Color(0xFFF5F5F5),
            const Color.fromARGB(255, 103, 138, 156),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgressBar(
    double rateVal,
    int ratePercent,
    int totalWorking,
    int attended,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monthly Attendance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38468E),
                ),
              ),
              Text(
                "$ratePercent%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: rateVal.isNaN || rateVal.isInfinite ? 0 : rateVal,
              backgroundColor: Colors.grey.shade100,
              color: const Color(0xFF38468E),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$attended of $totalWorking working days",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                "${totalWorking - attended} missed",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(int recordCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF38468E)),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        selectedMonth.month - 1,
                      );
                    });
                    _fetchAttendanceData(); // Fetch new month data
                  },
          ),
          Column(
            children: [
              Text(
                DateFormat("MMMM yyyy").format(selectedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                _isLoading ? "Loading..." : "$recordCount records",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF38468E)),
            onPressed: _isLoading
                ? null
                : () {
                    DateTime next = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    );
                    // Prevent navigating to future months beyond the current month
                    if (next.isBefore(
                      DateTime.now().add(const Duration(days: 1)),
                    )) {
                      setState(() {
                        selectedMonth = next;
                      });
                      _fetchAttendanceData(); // Fetch new month data
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> data) {
    bool isOff = data['status'] == 'Weekly Off';

    Color themeColor;
    Color bgColor;

    switch (data['theme']) {
      case 'present':
        themeColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'late':
        themeColor = const Color(0xFFF57F17);
        bgColor = const Color(0xFFFFF8E1);
        break;
      case 'absent':
        themeColor = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        break;
      case 'off':
      default:
        themeColor = Colors.grey.shade600;
        bgColor = Colors.grey.shade200;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LEFT: DATE BOX ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isOff ? Colors.grey.shade100 : const Color(0xFFF7FBF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOff ? Colors.grey.shade300 : const Color(0xFFC8E6C9),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  data['dateNum']?.toString() ?? "--",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isOff
                        ? Colors.grey.shade700
                        : const Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  data['monthStr']?.toString() ?? "---",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOff
                        ? Colors.grey.shade500
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // --- MIDDLE: DETAILS ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['day']?.toString() ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                if (isOff)
                  Text(
                    "No shift assigned",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  )
                else
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "In: ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        data['inTime']?.toString() ?? "--:--",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Out: ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        data['outTime']?.toString() ?? "--:--",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // --- RIGHT: STATUS & ACTIONS ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data['status']?.toString() ?? "Unknown",
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!isOff && data['status'] != 'Absent') ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data['duration']?.toString() ?? "--",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AttendanceDetailScreen(data: data),
                      ),
                    );
                  },
                  child: const Text(
                    "Details >",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF38468E),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
