// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kt_app/PersonalInformationScreen.dart';
import 'package:kt_app/changepassword_screen.dart';
import 'package:kt_app/helpsupportcreen.dart';
import 'package:kt_app/login.dart'; // Ensure you have your LoginScreen imported

class MainProfileScreen extends StatefulWidget {
  const MainProfileScreen({super.key});

  @override
  State<MainProfileScreen> createState() => _MainProfileScreenState();
}

class _MainProfileScreenState extends State<MainProfileScreen> {
  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  // --- DYNAMIC PROFILE DATA (Initialized with Fallback Dummy Data) ---
  String _profileImageUrl = "";
  String _fullName = "Jatin Dixit";
  String _designation = "Software Developer";
  String _department = "Engineering - Kubic Technology";
  String _empId = "EMP-042";
  String _joinedDate = "Jan 2024";
  String _location = "Mumbai";

  @override
  void initState() {
    super.initState();
    _fetchProfileSummary();
  }

  // ==========================================
  // API CALL: FETCH PROFILE SUMMARY
  // ==========================================
  Future<void> _fetchProfileSummary() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Profile Summary
      final response = await http.get(
        Uri.parse('$baseUrl/profile/summary'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _fullName = data['data']['full_name'] ?? _fullName;
            _designation = data['data']['designation'] ?? _designation;
            _department = data['data']['department'] ?? _department;
            _empId = data['data']['emp_id'] ?? _empId;
            _joinedDate = data['data']['joined_date'] ?? _joinedDate;
            _location = data['data']['location'] ?? _location;
            _profileImageUrl =
                data['data']['profile_image'] ?? _profileImageUrl;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch profile summary: $e");
      // Silently falls back to dummy data if API fails!
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ==========================================
  // API CALL: LOGOUT
  // ==========================================
  Future<void> _handleLogout() async {
    try {
      // Show loading indicator in dialog (Optional)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // TODO: Replace with your exact Swagger endpoint for POST Logout
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      // 1. Clear any locally saved tokens here (e.g., using SharedPreferences)
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.clear();

      // 2. Remove loading dialog
      if (mounted) Navigator.pop(context);

      // 3. Navigate back to Login Screen and remove all previous routes
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Logout failed: $e");
      if (mounted) Navigator.pop(context); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network Error. Could not log out.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper to extract initials from full name
  String _getInitials(String name) {
    List<String> names = name.trim().split(" ");
    if (names.isEmpty) return "E";
    if (names.length == 1) return names[0][0].toUpperCase();
    return "${names[0][0]}${names[names.length - 1][0]}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF38468E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 290,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38468E),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  image: _profileImageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(_profileImageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: _profileImageUrl.isEmpty
                                    ? Text(
                                        _getInitials(_fullName),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _designation,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _department,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: -35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatBox(_empId, 'EMPLOYEE ID'),
                            const SizedBox(width: 12),
                            _buildStatBox(_joinedDate, 'JOINED'),
                            const SizedBox(width: 12),
                            _buildStatBox(_location, 'LOCATION'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCOUNT SETTINGS',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildMenuCard(
                          title: 'Personal Information',
                          icon: Icons.person,
                          iconBgColor: Colors.grey.shade200,
                          iconColor: Colors.black87,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PersonalInformationScreen(),
                              ),
                            );
                          },
                        ),

                        _buildMenuCard(
                          title: 'Help & Support',
                          icon: Icons.help_outline,
                          iconBgColor: Colors.teal.shade50,
                          iconColor: Colors.teal.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpSupportScreen(),
                              ),
                            );
                          },
                        ),

                        _buildMenuCard(
                          title: 'Change Password',
                          icon: Icons.lock_outline_rounded,
                          iconBgColor: Colors.orange.shade50,
                          iconColor: Colors.orange.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),

                        _buildMenuCard(
                          title: 'Logout',
                          icon: Icons.logout,
                          iconBgColor: Colors.red.shade50,
                          iconColor: Colors.redAccent,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Logout"),
                                content: const Text(
                                  "Are you sure you want to logout?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      _handleLogout(); // Call the API Logout function
                                    },
                                    child: const Text(
                                      "Logout",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatBox(String title, String subtitle) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF38468E),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
