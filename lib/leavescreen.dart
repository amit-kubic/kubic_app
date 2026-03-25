// ignore_for_file: depend_on_referenced_packages, unnecessary_to_list_in_spreads, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class LeaveManagementScreen extends StatefulWidget {
  final int initialTab;
  final Map<String, dynamic>? prefilledHoliday;
  final String title;

  const LeaveManagementScreen({
    super.key,
    this.initialTab = 0,
    this.prefilledHoliday,
    required this.title,
  });

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  late int _currentTab;

  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";

  // --- STATE VARIABLES ---
  bool _isLoading = true;
  bool _isSubmitting = false;

  // --- DYNAMIC LEAVE BALANCES (Now populated from API) ---
  Map<String, int> dynamicBalances = {};
  int leavesUsed = 0;
  List<Map<String, dynamic>> leaveHistory = [];

  // Form State
  String? _selectedLeaveType;
  bool _isHalfDay = false;
  bool _isDateLocked = false;
  String _selectedSession = "Session 1";
  PlatformFile? _attachedFile; // Store the actual file for API upload

  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final _reasonController = TextEditingController();

  final List<String> _sessions = ["Session 1", "Session 2"];

  // --- RESTRICTED DATES LIST FOR THE CALENDAR ---
  final List<DateTime> _restrictedDates = [
    DateFormat('d MMM yyyy').parse('21 Mar 2026'),
    DateFormat('d MMM yyyy').parse('31 Mar 2026'),
    DateFormat('d MMM yyyy').parse('3 Apr 2026'),
    DateFormat('d MMM yyyy').parse('27 May 2026'),
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;

    _fetchLeaveData(); // Fetch balances and history from API

    if (widget.prefilledHoliday != null) {
      _selectedLeaveType = "Restricted Holiday Leave";
      _fromDateController.text = widget.prefilledHoliday!['fullDate'];
      _toDateController.text = widget.prefilledHoliday!['fullDate'];
      _reasonController.text =
          "Applying restricted holiday for ${widget.prefilledHoliday!['name']}.";

      _isHalfDay = false;
      _isDateLocked = widget.prefilledHoliday!['isDateLocked'] ?? true;
    }
  }

  // ==========================================
  // API CALL: FETCH LEAVE BALANCES & HISTORY
  // ==========================================
  Future<void> _fetchLeaveData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch Balances
      // TODO: Replace with your exact Swagger endpoint for GET Leave Balance
      final balanceRes = await http.get(Uri.parse('$baseUrl/leave-balances'));

      // 2. Fetch History
      // TODO: Replace with your exact Swagger endpoint for GET Leave History
      final historyRes = await http.get(Uri.parse('$baseUrl/leave-history'));

      if (balanceRes.statusCode == 200 && historyRes.statusCode == 200) {
        final balanceData = jsonDecode(balanceRes.body);
        final historyData = jsonDecode(historyRes.body);

        setState(() {
          // Parse dynamic balances from API
          // Assumes API returns a Map like: {"Paid Leave": 7, "Sick Leave": 2}
          if (balanceData['data'] != null) {
            dynamicBalances = Map<String, int>.from(
              balanceData['data']['balances'],
            );
            leavesUsed = balanceData['data']['total_used'] ?? 0;
          }

          // Parse history from API
          if (historyData['data'] != null) {
            leaveHistory = List<Map<String, dynamic>>.from(historyData['data']);
          }
        });
      }
    } catch (e) {
      print("API Fetch Error: $e");
      _showToast("Failed to load leave data.", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // API CALL: SUBMIT LEAVE REQUEST
  // ==========================================
  Future<void> _submitLeaveRequest() async {
    final String leaveKey = _selectedLeaveType ?? "";
    if (leaveKey.isEmpty || _fromDateController.text.isEmpty) {
      _showToast("Please select Leave Type and From Date", Colors.red);
      return;
    }
    if (leaveKey == "Sick Leave" && _attachedFile == null) {
      _showToast("Medical certificate is mandatory for Sick Leave", Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Replace with your exact Swagger endpoint for Apply Leave
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/apply-leave'),
      );

      // Attach text fields to request
      request.fields['leave_type'] = leaveKey;
      request.fields['from_date'] = _fromDateController.text;
      request.fields['to_date'] = _toDateController.text.isEmpty
          ? _fromDateController.text
          : _toDateController.text;
      request.fields['reason'] = _reasonController.text;
      request.fields['is_half_day'] = _isHalfDay.toString();
      if (_isHalfDay) {
        request.fields['session'] = _selectedSession;
      }

      // Attach file if it exists (for sick leave)
      if (_attachedFile != null && _attachedFile!.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'certificate',
            _attachedFile!.path!,
          ),
        );
      }

      // Add Headers (like Authorization token)
      // request.headers['Authorization'] = 'Bearer YOUR_TOKEN';

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var result = jsonDecode(responseData.body);

      if (response.statusCode == 200 && result['status'] == true) {
        _showToast(
          result['message'] ?? "Leave Request Submitted!",
          Colors.green,
        );

        // Clear form
        setState(() {
          _selectedLeaveType = null;
          _isHalfDay = false;
          _isDateLocked = false;
          _attachedFile = null;
          _fromDateController.clear();
          _toDateController.clear();
          _reasonController.clear();
          _currentTab = 0; // Switch back to history tab
        });

        // Re-fetch data to update balances and history UI
        _fetchLeaveData();
      } else {
        _showToast(result['message'] ?? "Failed to apply leave", Colors.red);
      }
    } catch (e) {
      print("Submit Error: $e");
      _showToast("Network Error. Try again.", Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    bool isRestrictedLeave = _selectedLeaveType == "Restricted Holiday Leave";
    DateTime initialSelection = DateTime.now();

    if (isRestrictedLeave && _restrictedDates.isNotEmpty) {
      initialSelection = _restrictedDates.first;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialSelection,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      selectableDayPredicate: (DateTime day) {
        if (isRestrictedLeave) {
          return _restrictedDates.any(
            (restrictedDate) =>
                day.year == restrictedDate.year &&
                day.month == restrictedDate.month &&
                day.day == restrictedDate.day,
          );
        }
        return true;
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
        if (isRestrictedLeave && controller == _fromDateController) {
          _toDateController.text = _fromDateController.text;
        }
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null) {
      setState(() {
        _attachedFile = result.files.single;
      });
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
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF38468E)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildDetailedLeaveBalance(),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton("Leave History", 0),
                        _buildTabButton("Apply Leave", 1),
                      ],
                    ),
                  ),
                  _currentTab == 0 ? _buildHistoryTab() : _buildApplyTab(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailedLeaveBalance() {
    int totalRemaining = dynamicBalances.isEmpty
        ? 0
        : dynamicBalances.values.reduce((a, b) => a + b);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Leave Balance",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "$totalRemaining Leaves",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Leave",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                "Balance",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (dynamicBalances.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "No leave balances available.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...dynamicBalances.entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        "${e.value} Left",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Leaves Used",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$leavesUsed Days",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF38468E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isActive = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF38468E) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (leaveHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Text(
          "No leave history found.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: leaveHistory
            .map(
              (leave) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave['type']?.toString() ?? 'Leave',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leave['date']?.toString() ?? '--',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusChip(leave['status']?.toString() ?? 'Pending'),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildApplyTab() {
    bool isRestrictedLeave = _selectedLeaveType == "Restricted Holiday Leave";
    bool disableHalfDay = _isDateLocked || isRestrictedLeave;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeaveTypeDropdown(),
          _buildDateField("FROM DATE", _fromDateController, !_isDateLocked),
          _buildDateField(
            "TO DATE",
            _toDateController,
            !_isHalfDay && !_isDateLocked && !isRestrictedLeave,
          ),
          Row(
            children: [
              Checkbox(
                value: _isHalfDay,
                activeColor: const Color(0xFF38468E),
                onChanged: disableHalfDay
                    ? null
                    : (bool? value) {
                        setState(() {
                          _isHalfDay = value ?? false;
                          if (_isHalfDay) _toDateController.clear();
                        });
                      },
              ),
              Text(
                "Half Day",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: disableHalfDay ? Colors.grey : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          if (_isHalfDay) _buildSessionDropdown(),
          if (_selectedLeaveType == "Sick Leave") ...[
            const SizedBox(height: 16),
            const Text(
              "MEDICAL CERTIFICATE *",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _attachedFile != null
                        ? Colors.green
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.upload_file,
                      color: _attachedFile != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _attachedFile?.name ??
                            "Upload Medical Report (Mandatory)",
                        style: TextStyle(
                          color: _attachedFile != null
                              ? Colors.black
                              : Colors.grey,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildInputField(
            "REASON",
            "Briefly describe your reason...",
            _reasonController,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitLeaveRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38468E),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Submit Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "LEAVE TYPE",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLeaveType,
          hint: const Text("Select Leave Type"),
          items: dynamicBalances.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text("${e.key} (${e.value} Left)"),
                ),
              )
              .toList(),
          onChanged: _isDateLocked
              ? null
              : (val) {
                  setState(() {
                    _selectedLeaveType = val;
                    if (val == "Restricted Holiday Leave") {
                      _isHalfDay = false;
                      _fromDateController.clear();
                      _toDateController.clear();
                    }
                  });
                },
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSessionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Half day for which session",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSession,
          items: _sessions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() => _selectedSession = val!),
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: true,
            enabled: enabled,
            onTap: enabled ? () => _selectDate(context, controller) : null,
            decoration: _inputDecoration().copyWith(
              hintText: "dd-MMM-yyyy",
              suffixIcon: Icon(
                Icons.calendar_month,
                size: 20,
                color: enabled ? Colors.black54 : Colors.grey.shade300,
              ),
              fillColor: enabled ? Colors.white : Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF38468E)),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: _inputDecoration().copyWith(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    bool isApproved = status == "Approved" || status == "Approved";
    bool isRejected = status == "Rejected";

    Color bgColor = const Color(0xFFFFF8E1); // Pending (Yellow)
    Color txtColor = const Color(0xFFF57F17);

    if (isApproved) {
      bgColor = const Color(0xFFE8F5E9);
      txtColor = const Color(0xFF2E7D32);
    } else if (isRejected) {
      bgColor = const Color(0xFFFFEBEE);
      txtColor = const Color(0xFFC62828);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: txtColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
