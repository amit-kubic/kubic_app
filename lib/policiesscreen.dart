// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({super.key, required String title});

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  String searchQuery = "";

  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  // --- POLICY DATA (Initialized with Fallback Dummy Data) ---
  List<Map<String, dynamic>> allPolicies = [
    {
      "title": "Work From Home Policy",
      "date": "Updated Jan 2026",
      "icon": Icons.access_time_rounded,
      "iconColor": Colors.blue.shade700,
      "bgColor": Colors.blue.shade50,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
    {
      "title": "Leave & Holiday Policy",
      "date": "Updated Mar 2026",
      "icon": Icons.beach_access_rounded,
      "iconColor": Colors.green.shade700,
      "bgColor": Colors.green.shade50,
      "pdfPath": "assets/pdfs/Leave_Policy.pdf",
    },
    {
      "title": "IT & Device Usage Policy",
      "date": "Updated Dec 2025",
      "icon": Icons.laptop_mac_rounded,
      "iconColor": Colors.grey.shade700,
      "bgColor": Colors.grey.shade200,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
    {
      "title": "Data Privacy Policy",
      "date": "Updated Nov 2025",
      "icon": Icons.lock_outline_rounded,
      "iconColor": Colors.purple.shade700,
      "bgColor": Colors.purple.shade50,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
    {
      "title": "Code of Conduct",
      "date": "Updated Jan 2026",
      "icon": Icons.handshake_outlined,
      "iconColor": Colors.orange.shade700,
      "bgColor": Colors.orange.shade50,
      "pdfPath": "assets/pdfs/Performance_Parameters.pdf",
    },
    {
      "title": "Health & Safety Policy",
      "date": "Updated Jan 2024",
      "icon": Icons.local_hospital_outlined,
      "iconColor": Colors.red.shade700,
      "bgColor": Colors.red.shade50,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
    {
      "title": "Training & Development",
      "date": "Updated Mar 2026",
      "icon": Icons.school_outlined,
      "iconColor": Colors.blueGrey.shade700,
      "bgColor": Colors.blueGrey.shade50,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchPolicies();
  }

  // ==========================================
  // API CALL: FETCH POLICIES
  // ==========================================
  Future<void> _fetchPolicies() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Policies
      final response = await http.get(
        Uri.parse('$baseUrl/policies'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          List<Map<String, dynamic>> fetchedPolicies = [];

          for (var item in data['data']) {
            fetchedPolicies.add(_formatPolicyData(item));
          }

          setState(() {
            allPolicies = fetchedPolicies;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch policies: $e");
      // Silently keeps the dummy data visible if API fails
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to automatically assign icons and colors based on policy name
  Map<String, dynamic> _formatPolicyData(Map<String, dynamic> doc) {
    String title = doc['title']?.toString().toLowerCase() ?? '';

    IconData icon = Icons.description_outlined;
    Color iconColor = Colors.blueGrey.shade700;
    Color bgColor = Colors.blueGrey.shade50;

    if (title.contains('work from home') || title.contains('wfh')) {
      icon = Icons.access_time_rounded;
      iconColor = Colors.blue.shade700;
      bgColor = Colors.blue.shade50;
    } else if (title.contains('leave') || title.contains('holiday')) {
      icon = Icons.beach_access_rounded;
      iconColor = Colors.green.shade700;
      bgColor = Colors.green.shade50;
    } else if (title.contains('it ') ||
        title.contains('device') ||
        title.contains('tech')) {
      icon = Icons.laptop_mac_rounded;
      iconColor = Colors.grey.shade700;
      bgColor = Colors.grey.shade200;
    } else if (title.contains('privacy') || title.contains('data')) {
      icon = Icons.lock_outline_rounded;
      iconColor = Colors.purple.shade700;
      bgColor = Colors.purple.shade50;
    } else if (title.contains('conduct') || title.contains('ethics')) {
      icon = Icons.handshake_outlined;
      iconColor = Colors.orange.shade700;
      bgColor = Colors.orange.shade50;
    } else if (title.contains('health') || title.contains('safety')) {
      icon = Icons.local_hospital_outlined;
      iconColor = Colors.red.shade700;
      bgColor = Colors.red.shade50;
    } else if (title.contains('training') || title.contains('development')) {
      icon = Icons.school_outlined;
      iconColor = Colors.blueGrey.shade700;
      bgColor = Colors.blueGrey.shade50;
    }

    return {
      "title": doc['title'] ?? 'Company Policy',
      "date": doc['date'] ?? 'Updated Recently',
      "icon": icon,
      "iconColor": iconColor,
      "bgColor": bgColor,
      "pdfPath": doc['url'] ?? doc['pdfPath'] ?? '', // Expecting 'url' from API
    };
  }

  // Function to show the popup when a document is clicked
  void _showDocumentActionDialog(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${doc['date']} • PDF Document",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // OPEN PDF BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet

                  if (doc['pdfPath'] == null ||
                      doc['pdfPath'].toString().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF Link is unavailable.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        title: doc['title'],
                        pdfPath: doc['pdfPath'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38468E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Open in PDF Viewer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // CANCEL BUTTON
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter documents based on search query
    final filteredDocs = allPolicies
        .where(
          (doc) => doc['title'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.black87,
              size: 22,
            ),
          ),
        ),
        title: const Text(
          "Company Policies",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: "Search policies...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF38468E),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- POLICY LIST ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38468E)),
                  )
                : filteredDocs.isEmpty
                ? Center(
                    child: Text(
                      "No policies found.",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];

                      return GestureDetector(
                        onTap: () => _showDocumentActionDialog(context, doc),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                          child: Row(
                            children: [
                              // ICON
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: doc['bgColor'],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  doc['icon'],
                                  color: doc['iconColor'],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // TITLE & SUBTITLE
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doc['date'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// ACTUAL PDF VIEWER SCREEN
// ========================================================
class PDFViewerScreen extends StatelessWidget {
  final String title;
  final String pdfPath;

  const PDFViewerScreen({
    super.key,
    required this.title,
    required this.pdfPath,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the path is an external URL or a local asset
    bool isNetworkUrl =
        pdfPath.startsWith('http://') || pdfPath.startsWith('https://');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF38468E),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Automatically uses .network for API URLs or .asset for Fallbacks
      body: isNetworkUrl
          ? SfPdfViewer.network(
              pdfPath,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                _showErrorSnackBar(context, 'Failed to load PDF from server.');
              },
            )
          : SfPdfViewer.asset(
              pdfPath,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                _showErrorSnackBar(
                  context,
                  'Error loading PDF: Make sure $pdfPath exists in assets folder.',
                );
              },
            ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
