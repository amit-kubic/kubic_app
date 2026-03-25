// ignore_for_file: file_names, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlertsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const AlertsScreen({super.key, this.onBackPressed});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  // --- DYNAMIC ALERTS (Initialized with Fallback Dummy Data) ---
  List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Leave Approved',
      'shortMsg': 'Your Casual Leave for 20 Mar 2026 has been approved.',
      'fullMsg':
          'Your Casual Leave request for 20 Mar 2026 has been reviewed and approved by your manager, Rohit Sharma. Enjoy your time off! Please ensure your pending tasks are handed over to your team before you leave.',
      'time': 'Today, 9:30 AM',
      'icon': Icons.check_box,
      'color': Colors.green,
      'bgColor': Colors.green.shade50,
    },
    {
      'title': 'Reimbursement Pending',
      'shortMsg': 'Travel Expense claim of ₹2,400 is awaiting approval.',
      'fullMsg':
          'Your Travel Expense claim (ID: EXP-982) for ₹2,400 submitted on 12 Mar 2026 is currently pending approval from the Finance Department. You will be notified once the amount is processed and credited to your bank account.',
      'time': 'Today, 8:15 AM',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange.shade700,
      'bgColor': Colors.orange.shade50,
    },
    {
      'title': 'Gudi Padwa Holiday',
      'shortMsg': 'Office closed on 19 Mar 2026 (Thursday) for Gudi Padwa.',
      'fullMsg':
          'This is a company-wide announcement. The office will remain closed on Thursday, 19 Mar 2026, on account of Gudi Padwa. Regular operations will resume on Friday, 20 Mar 2026. Wishing you all a very Happy Gudi Padwa!',
      'time': 'Yesterday',
      'icon': Icons.campaign,
      'color': const Color(0xFF5C6BC0), // Indigo
      'bgColor': const Color(0xFFE8EAF6),
    },
    {
      'title': 'Appraisal Cycle Open',
      'shortMsg':
          'Q1 2026 performance review open. Submit self-assessment by 31 Mar.',
      'fullMsg':
          'The Q1 2026 Appraisal and Performance Review cycle is now officially open. Please navigate to the Performance module and complete your self-assessment. The hard deadline for submission is 31 March 2026. Late submissions will not be entertained.',
      'time': '11 Mar',
      'icon': Icons.assignment,
      'color': Colors.blueGrey,
      'bgColor': Colors.blueGrey.shade50,
    },
    {
      'title': 'Birthday: Amit Shinde',
      'shortMsg': "Today is Amit's birthday! Wish her on the Team page.",
      'fullMsg':
          "It's time to celebrate! Today is Riya Sharma's birthday. Drop a message on the team portal to wish her a fantastic day and a great year ahead!",
      'time': '11 Mar, 9:00 AM',
      'icon': Icons.cake,
      'color': Colors.pink.shade400,
      'bgColor': Colors.pink.shade50,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  // ==========================================
  // API CALL: FETCH ALERTS & NOTIFICATIONS
  // ==========================================
  Future<void> _fetchAlerts() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Notifications
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          List<Map<String, dynamic>> fetchedAlerts = [];

          // Loop through API data and format it with UI colors/icons
          for (var item in data['data']) {
            fetchedAlerts.add(_formatAlertData(item));
          }

          setState(() {
            _alerts = fetchedAlerts;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch alerts: $e");
      // If it fails, it will quietly keep showing the dummy data!
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to automatically assign Icons and Colors based on the API alert 'type'
  Map<String, dynamic> _formatAlertData(Map<String, dynamic> rawData) {
    String type = rawData['type']?.toString().toLowerCase() ?? '';
    String title = rawData['title']?.toString().toLowerCase() ?? '';

    IconData icon = Icons.notifications;
    Color color = Colors.blueGrey;
    Color bgColor = Colors.blueGrey.shade50;

    // Determine visuals based on keywords in type or title
    if (type.contains('leave') ||
        title.contains('approved') ||
        type.contains('success')) {
      icon = Icons.check_box;
      color = Colors.green;
      bgColor = Colors.green.shade50;
    } else if (type.contains('pending') ||
        type.contains('reimbursement') ||
        type.contains('expense')) {
      icon = Icons.warning_amber_rounded;
      color = Colors.orange.shade700;
      bgColor = Colors.orange.shade50;
    } else if (type.contains('holiday') || type.contains('announcement')) {
      icon = Icons.campaign;
      color = const Color(0xFF5C6BC0);
      bgColor = const Color(0xFFE8EAF6);
    } else if (type.contains('birthday') || type.contains('celebration')) {
      icon = Icons.cake;
      color = Colors.pink.shade400;
      bgColor = Colors.pink.shade50;
    } else if (type.contains('appraisal') || type.contains('task')) {
      icon = Icons.assignment;
      color = Colors.blueGrey;
      bgColor = Colors.blueGrey.shade50;
    }

    return {
      'title': rawData['title'] ?? 'New Notification',
      'shortMsg': rawData['shortMsg'] ?? '',
      'fullMsg': rawData['fullMsg'] ?? 'No further details provided.',
      'time': rawData['time'] ?? 'Just now',
      'icon': icon,
      'color': color,
      'bgColor': bgColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
              onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF38468E)),
            )
          : _alerts.isEmpty
          ? const Center(
              child: Text(
                "No new notifications.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return _buildAlertCard(context, alert);
              },
            ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> alert) {
    return GestureDetector(
      onTap: () {
        _showFullMessage(context, alert);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert['bgColor'],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: alert['color'].withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: alert['color'].withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(alert['icon'], color: alert['color'], size: 24),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['title'],
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert['shortMsg'],
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alert['time'],
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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

  // --- Pop-up Bottom Sheet for Full Message ---
  void _showFullMessage(BuildContext context, Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(alert['icon'], color: alert['color'], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(),
              ),
              Text(
                alert['fullMsg'],
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Received: ${alert['time']}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38468E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
