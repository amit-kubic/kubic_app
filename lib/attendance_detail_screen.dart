// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const AttendanceDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Determine colors based on status for a consistent UI
    Color themeColor;
    Color bgColor;

    // Safely extract theme with a fallback
    String theme = data['theme']?.toString() ?? 'default';

    switch (theme) {
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
        themeColor = Colors.grey.shade500;
        bgColor = Colors.grey.shade200;
        break;
    }

    // Safely extract variables from API data
    String date = data['date']?.toString() ?? 'Unknown Date';
    String day = data['day']?.toString() ?? '';
    String shift = data['shift']?.toString() ?? 'No Shift';
    String inTime = data['inTime']?.toString() ?? '--:--';
    String outTime = data['outTime']?.toString() ?? '--:--';
    String status = data['status']?.toString() ?? 'Unknown';
    // Use dynamic employee name from API, fallback to "Employee"
    String employeeName = data['employeeName']?.toString() ?? 'Employee';

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
          "Attendance Detail",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DATE HEADER
            Text(
              "$date | $day",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // SHIFT SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                theme == 'off' ? "N/A" : "$inTime - $outTime",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // STATUS PILL
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // LOG SECTION HEADER
            if (theme != 'off' && theme != 'absent') ...[
              const Text(
                "Logs & Approvals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),

              // LOG TIMELINE CARDS
              _buildLogCard(
                icon: Icons.fingerprint,
                iconColor: const Color(0xFF38468E),
                title: "Punched In | $shift | Office",
                subtitle: "By $employeeName on $date, $inTime",
              ),
              _buildLogCard(
                icon: Icons.check_circle_outline,
                iconColor: Colors.green.shade600,
                title: "Approved Punch-In Time",
                subtitle: "By Manager on $date, $inTime",
              ),
              if (outTime != 'Active' &&
                  outTime != 'N/A' &&
                  outTime != '--:--') ...[
                _buildLogCard(
                  icon: Icons.fingerprint,
                  iconColor: const Color(0xFF38468E),
                  title: "Punched Out | $shift | Office",
                  subtitle: "By $employeeName on $date, $outTime",
                ),
                _buildLogCard(
                  icon: Icons.check_circle,
                  iconColor: Colors.green.shade600,
                  title: "Approved Status: $status",
                  subtitle: "By Manager",
                ),
              ],
            ] else if (theme == 'absent') ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    "Employee marked absent. No logs generated.",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
