// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.title});

  final String title;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  String searchQuery = "";

  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  // --- BRAND COLORS ---
  final Color primaryPurple = const Color(0xFF7A357C);
  final Color lightPurple = const Color(0xFF8C408D);
  final Color darkPurple = const Color(0xFF511B55);

  // --- DUMMY TEAM DATA (Fallback Data) ---
  List<Map<String, dynamic>> teamMembers = [
    {
      "name": "Amit Shinde",
      "role": "Flutter Developer",
      "birthday": "13 Mar",
      "isBirthdayToday": true,
      "avatarColor": const Color(0xFF5C6BC0), // Indigo
    },
    {
      "name": "Jatin Dixit",
      "role": "Backend Developer",
      "birthday": "28 Mar",
      "isBirthdayToday": false,
      "avatarColor": const Color(0xFF2E7D32), // Green
    },
    {
      "name": "Shubham Parmar",
      "role": "Laravel Developer",
      "birthday": "5 Apr",
      "isBirthdayToday": false,
      "avatarColor": const Color(0xFFE91E63), // Pink
    },
    {
      "name": "Raj mandel",
      "role": "Flutter Developer",
      "birthday": "18 Apr",
      "isBirthdayToday": false,
      "avatarColor": const Color(0xFF7E57C2), // Purple
    },
    {
      "name": "Suhas Gawde",
      "role": "Engineer",
      "birthday": "2 May",
      "isBirthdayToday": false,
      "avatarColor": const Color(0xFFFF8F00), // Orange
    },
    {
      "name": "Ajay Chorge",
      "role": "Engineer",
      "birthday": "14 Jun",
      "isBirthdayToday": false,
      "avatarColor": const Color(0xFF0288D1), // Blue
    },
    {
      "name": "Vignesh Sangekar",
      "role": "Tester",
      "birthday": "14 Jun",
      "isBirthdayToday": false,
      "avatarColor": const Color(0xFF009688), // Teal
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchTeamData();
  }

  // ==========================================
  // API CALL: FETCH TEAM DIRECTORY
  // ==========================================
  Future<void> _fetchTeamData() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Team Members
      final response = await http.get(
        Uri.parse('$baseUrl/team/directory'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          List<Map<String, dynamic>> fetchedMembers = [];

          for (var item in data['data']) {
            String name = item['name'] ?? 'Employee';
            fetchedMembers.add({
              "name": name,
              "role": item['role'] ?? 'Staff',
              "birthday": item['birthday'] ?? '--',
              "isBirthdayToday": item['isBirthdayToday'] ?? false,
              // Assign a consistent random color based on the person's name length
              "avatarColor": _getRandomColor(name),
            });
          }

          setState(() {
            teamMembers = fetchedMembers;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch team data: $e");
      // Silently keep dummy data visible if API fails
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to generate a consistent color based on string hash
  Color _getRandomColor(String seed) {
    final List<Color> colors = [
      const Color(0xFF5C6BC0), // Indigo
      const Color(0xFF2E7D32), // Green
      const Color(0xFFE91E63), // Pink
      const Color(0xFF7E57C2), // Purple
      const Color(0xFFFF8F00), // Orange
      const Color(0xFF0288D1), // Blue
      const Color(0xFF009688), // Teal
      const Color(0xFFD32F2F), // Red
    ];
    int hash = 0;
    for (int i = 0; i < seed.length; i++) {
      hash = seed.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  String getInitials(String name) {
    List<String> names = name.trim().split(RegExp(r'\s+'));
    if (names.isEmpty || names[0].isEmpty) return "E";
    if (names.length >= 2 && names[1].isNotEmpty) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = teamMembers
        .where(
          (m) =>
              m["name"].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              m["role"].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9), // AppBar uses Primary Purple
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Directory",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR AREA ---
          Container(
            color:
                primaryPurple, // Extending the purple background behind the search bar
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
              top: 10,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: darkPurple.withOpacity(
                      0.2,
                    ), // Dark purple subtle shadow
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: "Search name or role...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: lightPurple,
                  ), // Light purple search icon
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // --- LIST VIEW ---
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryPurple))
                : filteredMembers.isEmpty
                ? Center(
                    child: Text(
                      "No members found",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = filteredMembers[index];
                      return _buildTeamCard(member);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> member) {
    bool isBirthday = member['isBirthdayToday'] ?? false;
    Color avatarColor = member['avatarColor'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          // Soft Light Purple border for birthdays
          color: isBirthday ? lightPurple.withOpacity(0.3) : Colors.transparent,
          width: isBirthday ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(
              0.04,
            ), // Dark purple tinted shadow for the cards
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: avatarColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    getInitials(member['name']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // --- DETAILS ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member['role'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.cake_rounded,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member['birthday'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- NORMAL CARD ACTIONS (Message & Call) ---
              if (!isBirthday) ...[
                _buildCircularActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  bgColor: darkPurple.withOpacity(0.08), // Tinted background
                  iconColor: darkPurple, // Darker purple for Message
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Messaging feature coming soon!'),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildCircularActionButton(
                  icon: Icons.call_outlined,
                  bgColor: primaryPurple.withOpacity(0.1), // Tinted background
                  iconColor: primaryPurple, // Primary purple for Call
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calling feature coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),

          // --- BIRTHDAY CARD ACTION (Full Width Button) ---
          if (isBirthday) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Wish sent to ${member['name']}!'),
                    backgroundColor:
                        primaryPurple, // Snackbar in primary purple
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  // Gradient effect using Light and Primary purple with low opacity
                  gradient: LinearGradient(
                    colors: [
                      lightPurple.withOpacity(0.15),
                      primaryPurple.withOpacity(0.15),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      color: primaryPurple,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Send Birthday Wish",
                      style: TextStyle(
                        color: primaryPurple, // Text matches Primary Purple
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper for the circular Message and Call buttons
  Widget _buildCircularActionButton({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
