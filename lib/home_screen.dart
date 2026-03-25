// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:kt_app/Alert_screen.dart';
import 'package:kt_app/attendancecreen.dart';
import 'package:kt_app/documentsscreen.dart';
import 'package:kt_app/holidayscreen.dart';
import 'package:kt_app/leavescreen.dart';
import 'package:kt_app/performancescreen.dart';
import 'package:kt_app/policiesscreen.dart';
import 'package:kt_app/profile_screen.dart';
import 'package:kt_app/reimbursementscreen.dart';
import 'package:kt_app/teamscreen.dart';
import 'package:kt_app/punch_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";

  // --- DASHBOARD DATA STATE ---
  bool _isLoadingDashboard = true;
  String userName = "Employee";
  String presentDays = "0";
  String weekoffDays = "0";
  String absentDays = "0";

  // --- ATTENDANCE STATE ---
  int punchStatus = 0; // 0: Not Punched, 1: In, 2: Out
  String punchInTime = "--:--";
  String punchOutTime = "--:--";
  bool _isPunching = false; // To show loading while saving punch to server

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _fetchDashboardData(); // Fetch real data when screen opens
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================
  // API CALL: FETCH DASHBOARD DATA
  // ==========================================
  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get-dashboard'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN', // You will need this!
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          setState(() {
            userName = data['data']['first_name'] ?? "Employee";
            presentDays = data['data']['present_days'].toString();
            weekoffDays = data['data']['weekoffs'].toString();
            absentDays = data['data']['absent_days'].toString();

            // You can also fetch the initial punch status here if the user
            // already punched in earlier today
            // punchStatus = data['data']['current_punch_status'];
          });
        }
      } else {
        print("Failed to load dashboard: ${response.statusCode}");
      }
    } catch (e) {
      print("API Error: $e");
    } finally {
      setState(() {
        _isLoadingDashboard = false;
      });
    }
  }

  // ==========================================
  // API CALL: SAVE PUNCH TO DATABASE
  // ==========================================
  Future<void> _savePunchToServer(
    String time,
    int newStatus,
    String punchType,
  ) async {
    setState(() {
      _isPunching = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/punch-attendance'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
        body: jsonEncode({
          'punch_time': time,
          'punch_type': punchType, // e.g., "IN" or "OUT"
          // Add location data here if your API requires it
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Successfully saved to server, now update the UI
        setState(() {
          punchStatus = newStatus;
          if (newStatus == 1) punchInTime = time;
          if (newStatus == 2) punchOutTime = time;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Punch saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to save punch'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPunching = false;
      });
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          AlertsScreen(onBackPressed: () => _pageController.jumpToPage(0)),
          const MainProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 'Home', 0),
              _buildBottomNavItem(Icons.notifications_none, 'Alerts', 1),
              _buildBottomNavItem(Icons.person_outline, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_isLoadingDashboard) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF38468E)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Stack(
        children: [
          Container(
            height: 320,
            decoration: const BoxDecoration(color: Color(0xFF38468E)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeaderContent(),
                _buildDynamicPunchCard(),
                _buildBodyContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPunchCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S SHIFT • REGULAR",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              if (punchStatus == 2)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "✓ Complete",
                    style: TextStyle(
                      color: Color(0xFF38468E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (punchStatus == 0) ...[
                const Text(
                  "Not punched in",
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _punchButton("Punch In", const Color(0xFF28A745), 1),
              ] else if (punchStatus == 1) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      punchInTime,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "✓ Punched in - Regular Shift",
                      style: TextStyle(
                        color: Color(0xFF28A745),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                _punchButton("Punch Out", const Color(0xFFDC3545), 2),
              ] else ...[
                Row(
                  children: [
                    _timeColumn("IN", punchInTime, const Color(0xFF28A745)),
                    const SizedBox(width: 30),
                    _timeColumn("OUT", punchOutTime, const Color(0xFFDC3545)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _punchButton(String label, Color color, int nextStatus) {
    return ElevatedButton(
      onPressed: _isPunching
          ? null
          : () async {
              // 1. Go to Camera/Location Screen first
              final resultTime = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PunchScreen(type: label),
                ),
              );

              // 2. If user successfully captured punch info, save it to API
              if (resultTime != null) {
                String punchType = nextStatus == 1 ? "IN" : "OUT";
                await _savePunchToServer(resultTime, nextStatus, punchType);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: _isPunching
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label),
    );
  }

  Widget _timeColumn(String label, String time, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good Morning, $userName 👋", // Now uses API Variable
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _pageController.jumpToPage(2),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userName.isNotEmpty
                        ? userName[0].toUpperCase()
                        : "E", // Dynamic Initials
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(presentDays, "Present Day"), // Dynamic variable
              const SizedBox(width: 8),
              _buildStatCard(weekoffDays, "Weekoff"), // Dynamic variable
              const SizedBox(width: 8),
              _buildStatCard(absentDays, "Absent"), // Dynamic variable
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MODULES",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
            children: [
              ModuleCard(
                icon: Icons.fingerprint_rounded,
                title: "Attendance",
                targetScreen: const AttendanceScreen(title: 'Attendance'),
              ),
              ModuleCard(
                icon: Icons.event_busy_rounded,
                title: "Leave",
                targetScreen: const LeaveManagementScreen(title: 'Leave'),
              ),
              ModuleCard(
                icon: Icons.beach_access_rounded,
                title: "Holiday",
                targetScreen: const HolidaysScreen(title: 'Holiday'),
              ),
              ModuleCard(
                icon: Icons.receipt_long_rounded,
                title: "Expense",
                targetScreen: const ReimbursementScreen(title: 'Expense'),
              ),
              ModuleCard(
                icon: Icons.insights_rounded,
                title: "Performance",
                targetScreen: const PerformanceScreen(title: 'Performance'),
              ),
              ModuleCard(
                icon: Icons.folder_shared_rounded,
                title: "HR Docs",
                targetScreen: const DocumentsScreen(title: 'HR Docs'),
              ),
              ModuleCard(
                icon: Icons.policy_rounded,
                title: "Policies",
                targetScreen: const PoliciesScreen(title: 'Policies'),
              ),
              ModuleCard(
                icon: Icons.groups_rounded,
                title: "Team",
                targetScreen: const TeamScreen(title: 'Team'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    Color color = isActive ? const Color(0xFF38468E) : Colors.grey.shade500;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget targetScreen;

  const ModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.targetScreen,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isActive = true),
      onTapUp: (_) {
        setState(() => _isActive = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget.targetScreen),
        );
      },
      onTapCancel: () => setState(() => _isActive = false),
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isActive
                      ? const Color(0xFF38468E)
                      : Colors.grey.shade200,
                  width: _isActive ? 2.0 : 1.0,
                ),
                boxShadow: _isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF38468E).withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: const Color(0xFF38468E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
