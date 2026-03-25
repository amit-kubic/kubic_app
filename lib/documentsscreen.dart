// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, required String title});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String searchQuery = "";

  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  // --- DYNAMIC DOCUMENT DATA (Initialized with Fallback Dummy Data) ---
  List<Map<String, dynamic>> allDocuments = [
    {
      "title": "Offer Letter",
      "date": "Jan 2024",
      "size": "245 KB",
      "icon": Icons.description_outlined,
      "iconColor": Colors.grey.shade700,
      "bgColor": Colors.grey.shade100,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
    {
      "title": "Salary Slip - Jan 2026",
      "date": "Jan 2026",
      "size": "180 KB",
      "icon": Icons.monetization_on_outlined,
      "iconColor": Colors.green.shade700,
      "bgColor": Colors.green.shade50,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
    {
      "title": "Appraisal Letter 2025",
      "date": "Dec 2025",
      "size": "320 KB",
      "icon": Icons.insert_chart_outlined,
      "iconColor": Colors.blue.shade700,
      "bgColor": Colors.blue.shade50,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
    {
      "title": "Medical Insurance Policy",
      "date": "Jan 2024",
      "size": "2.1 MB",
      "icon": Icons.medical_services_outlined,
      "iconColor": Colors.red.shade700,
      "bgColor": Colors.red.shade50,
      "pdfPath": "assets/pdfs/Kubic_app.pdf",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  // ==========================================
  // API CALL: FETCH HR DOCUMENTS
  // ==========================================
  Future<void> _fetchDocuments() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Documents
      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_SAVED_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          List<Map<String, dynamic>> fetchedDocs = [];

          for (var item in data['data']) {
            fetchedDocs.add(_formatDocumentData(item));
          }

          setState(() {
            allDocuments = fetchedDocs;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch documents: $e");
      // Fallback data remains visible if API fails
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to automatically assign visual styling based on document title
  Map<String, dynamic> _formatDocumentData(Map<String, dynamic> doc) {
    String title = doc['title']?.toString().toLowerCase() ?? '';

    IconData icon = Icons.description_outlined;
    Color iconColor = Colors.grey.shade700;
    Color bgColor = Colors.grey.shade100;

    if (title.contains('salary') ||
        title.contains('pay') ||
        title.contains('bonus')) {
      icon = Icons.monetization_on_outlined;
      iconColor = Colors.green.shade700;
      bgColor = Colors.green.shade50;
    } else if (title.contains('appraisal') || title.contains('performance')) {
      icon = Icons.insert_chart_outlined;
      iconColor = Colors.blue.shade700;
      bgColor = Colors.blue.shade50;
    } else if (title.contains('medical') ||
        title.contains('insurance') ||
        title.contains('health')) {
      icon = Icons.medical_services_outlined;
      iconColor = Colors.red.shade700;
      bgColor = Colors.red.shade50;
    } else if (title.contains('policy') ||
        title.contains('handbook') ||
        title.contains('guideline')) {
      icon = Icons.policy_outlined;
      iconColor = Colors.purple.shade700;
      bgColor = Colors.purple.shade50;
    }

    return {
      "title": doc['title'] ?? 'HR Document',
      "date": doc['date'] ?? '--',
      "size": doc['size'] ?? 'Unknown Size',
      "icon": icon,
      "iconColor": iconColor,
      "bgColor": bgColor,
      "pdfPath":
          doc['url'] ??
          doc['pdfPath'] ??
          '', // Assume API sends a 'url' key for the PDF link
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
                "File Size: ${doc['size']} • PDF Document",
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

                  // Navigate to the PDF Viewer Screen
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
    final filteredDocs = allDocuments
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
          "HR Documents",
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
                hintText: "Search documents...",
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

          // --- DOCUMENT LIST ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38468E)),
                  )
                : filteredDocs.isEmpty
                ? Center(
                    child: Text(
                      "No documents found.",
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
                                      "${doc['date']} • ${doc['size']}",
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
      // Use SfPdfViewer.network for live URLs, and SfPdfViewer.asset for local files
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
                  'Error loading local PDF: Make sure $pdfPath exists.',
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
