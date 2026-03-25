// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _activeTabIndex = 0; // 0: FAQs, 1: Contact, 2: Raise Ticket

  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";

  // --- 1. FAQS STATE ---
  bool _isLoadingFaqs = true;
  List<Map<String, String>> _faqs = [
    {
      "question": "How do I apply for leave?",
      "answer":
          "Go to the Leave Management section, select 'Apply Leave', choose your dates, and submit.",
    },
    {
      "question": "What are restricted holidays?",
      "answer":
          "Restricted holidays are optional holidays. You can choose to take a maximum of 2 per year.",
    },
    {
      "question": "How does Punch In/Out work?",
      "answer":
          "Click the Punch In button on your dashboard when you start work, and Punch Out when your shift ends.",
    },
    {
      "question": "How do I submit a reimbursement claim?",
      "answer":
          "Go to the Expense module, upload your receipt, enter the amount, and submit it for Manager approval.",
    },
  ];

  // --- 2. CONTACT STATE ---
  bool _isLoadingContacts = true;
  Map<String, String> _contactInfo = {
    "hrEmail": "VigneshSangekar@kubictech.com",
    "hrPhone": "+91 9372677942",
    "itEmail": "it-support@kubictech.com",
    "portal": "hr.kubictech.com",
    "weekdays": "9:00 AM - 6:00 PM",
    "weekend": "Closed",
  };

  // --- 3. TICKET FORM STATE ---
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmittingTicket = false;

  @override
  void initState() {
    super.initState();
    // Fetch data for the first two tabs when the screen opens
    _fetchFaqs();
    _fetchContacts();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ==========================================
  // API CALL 1: FETCH FAQS
  // ==========================================
  Future<void> _fetchFaqs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/faqs'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _faqs = List<Map<String, String>>.from(
              data['data'].map(
                (item) => {
                  "question": item['question']?.toString() ?? "",
                  "answer": item['answer']?.toString() ?? "",
                },
              ),
            );
          });
        }
      }
    } catch (e) {
      print("Failed to fetch FAQs: $e");
    } finally {
      setState(() => _isLoadingFaqs = false);
    }
  }

  // ==========================================
  // API CALL 2: FETCH CONTACT INFO
  // ==========================================
  Future<void> _fetchContacts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/contacts'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _contactInfo = {
              "hrEmail": data['data']['hr_email'] ?? _contactInfo['hrEmail']!,
              "hrPhone": data['data']['hr_phone'] ?? _contactInfo['hrPhone']!,
              "itEmail": data['data']['it_email'] ?? _contactInfo['itEmail']!,
              "portal": data['data']['portal_link'] ?? _contactInfo['portal']!,
              "weekdays":
                  data['data']['hours_weekdays'] ?? _contactInfo['weekdays']!,
              "weekend":
                  data['data']['hours_weekend'] ?? _contactInfo['weekend']!,
            };
          });
        }
      }
    } catch (e) {
      print("Failed to fetch contacts: $e");
    } finally {
      setState(() => _isLoadingContacts = false);
    }
  }

  // ==========================================
  // API CALL 3: SUBMIT TICKET
  // ==========================================
  Future<void> _submitTicket() async {
    if (_categoryController.text.trim().isEmpty ||
        _subjectController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      _showToast("Please fill all required fields", Colors.red);
      return;
    }

    setState(() => _isSubmittingTicket = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "category": _categoryController.text.trim(),
          "subject": _subjectController.text.trim(),
          "description": _descriptionController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        _showToast(
          data['message'] ?? "Ticket Submitted Successfully!",
          Colors.green,
        );
        _categoryController.clear();
        _subjectController.clear();
        _descriptionController.clear();
        setState(
          () => _activeTabIndex = 1,
        ); // Jump back to contact tab on success
      } else {
        _showToast(data['message'] ?? "Failed to submit ticket", Colors.red);
      }
    } catch (e) {
      print("Error submitting ticket: $e");
      _showToast("Network Error. Please try again.", Colors.red);
    } finally {
      setState(() => _isSubmittingTicket = false);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBlueHeaderCard(),
            const SizedBox(height: 20),
            _buildTabSwitcher(),
            const SizedBox(height: 24),
            _buildActiveContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C79BD), Color(0xFF3B5998)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.help_outline, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help you?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Browse FAQs, contact HR, or raise a support ticket below.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabItem(0, 'FAQs', Icons.book_outlined),
          _tabItem(1, 'Contact', Icons.phone_outlined),
          _tabItem(2, 'Raise Ticket', Icons.confirmation_number_outlined),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label, IconData icon) {
    bool isActive = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B5998) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveContent() {
    switch (_activeTabIndex) {
      case 0:
        return _buildFAQSection();
      case 1:
        return _buildContactSection();
      case 2:
        return _buildTicketSection();
      default:
        return const SizedBox();
    }
  }

  // --- 1. FAQ SECTION ---
  Widget _buildFAQSection() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search FAQs...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingFaqs)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Color(0xFF3B5998)),
          )
        else
          ..._faqs
              .map(
                (faq) => _buildExpandableTile(faq["question"]!, faq["answer"]!),
              )
              .toList(),
      ],
    );
  }

  Widget _buildExpandableTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.add, size: 16, color: Color(0xFF3B5998)),
        ),
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. CONTACT SECTION ---
  Widget _buildContactSection() {
    if (_isLoadingContacts)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B5998)),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HR & IT CONTACTS",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _contactCard(
          "HR EMAIL",
          _contactInfo["hrEmail"]!,
          Icons.email_outlined,
          "Email HR",
          () {},
        ),
        _contactCard(
          "HR HELPLINE",
          _contactInfo["hrPhone"]!,
          Icons.phone_callback,
          "Call Now",
          () {},
        ),
        _contactCard(
          "IT SUPPORT",
          _contactInfo["itEmail"]!,
          Icons.chat_bubble_outline,
          "Email IT",
          () {},
        ),
        _contactCard(
          "HR PORTAL",
          _contactInfo["portal"]!,
          Icons.public,
          "Open",
          () {},
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "HR Office Hours",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              _hoursRow("Monday - Saturday", _contactInfo["weekdays"]!),
              _hoursRow("Sunday", _contactInfo["weekend"]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactCard(
    String label,
    String value,
    IconData icon,
    String btnText,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3B5998)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5998),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              btnText,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hoursRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 12)),
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- 3. RAISE TICKET SECTION ---
  Widget _buildTicketSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade100),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Use this form for HR queries, document corrections, attendance disputes, or any workplace issue.",
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ticketLabel("ISSUE CATEGORY"),
        TextFormField(
          controller: _categoryController,
          decoration: _inputDecoration("e.g. Attendance, Payroll, IT"),
        ),
        const SizedBox(height: 16),
        _ticketLabel("SUBJECT"),
        TextFormField(
          controller: _subjectController,
          decoration: _inputDecoration("Brief summary of your issue"),
        ),
        const SizedBox(height: 16),
        _ticketLabel("DESCRIPTION *"),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: _inputDecoration("Describe your issue in detail..."),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isSubmittingTicket ? null : _submitTicket,
            icon: _isSubmittingTicket
                ? const SizedBox.shrink()
                : const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.white,
                  ),
            label: _isSubmittingTicket
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Submit Ticket",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5998),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ticketLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3B5998)),
    ),
  );
}
