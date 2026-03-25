// ignore_for_file: prefer_final_fields, use_build_context_synchronously, use_super_parameters, depend_on_referenced_packages, curly_braces_in_flow_control_structures, unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 0;
  Map<String, String> _selectedFiles = {};

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();

  final Color primaryColor = const Color(0xFF3B4A9A);
  final Color backgroundColor = const Color(0xFFF4F6F9);
  final Color darkLabelColor = const Color(0xFF1E293B);

  void _goToDocuments() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _goToPersonalInfo() {
    setState(() {
      _currentStep = 0;
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
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
                  const SizedBox(width: 16),
                  const Text(
                    "Employee Registration",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            // --- TAB TOGGLE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      title: "1. Personal Info",
                      isActive: _currentStep == 0,
                      onTap: _goToPersonalInfo,
                    ),
                    _buildTabButton(
                      title: "2. Documents",
                      isActive: _currentStep == 1,
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _goToDocuments();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _currentStep == 0
                    ? _buildPersonalInfoSection()
                    : _buildDocumentsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? primaryColor : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("FULL NAME *", "Enter full name"),
          _buildTextField("CONTACT NO. *", "+91 XXXXX XXXXX", isPhone: true),
          _buildTextField(
            "ALTERNATE CONTACT NO.",
            "+91 XXXXX XXXXX",
            isPhone: true,
          ),
          _buildTextField("EMAIL *", "you@example.com", isEmail: true),
          _buildTextField(
            "ALTERNATE EMAIL",
            "alternate@example.com",
            isEmail: true,
          ),
          _buildDropdownField("GENDER *", "Select Gender", [
            "Male",
            "Female",
            "Other",
          ]),
          _buildDateField("DATE OF BIRTH *", "dd-mm-yyyy"),
          _buildDropdownField("BLOOD GROUP *", "Select Blood Group", [
            "A+",
            "A-",
            "B+",
            "B-",
            "O+",
            "O-",
            "AB+",
            "AB-",
          ]),
          const SizedBox(height: 24),
          _buildActionButton("Continue to Documents", _goToDocuments),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      children: [
        // --- ADDED DOCUMENT INSTRUCTION BANNER (Matches image_c94bf4.png) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6), // Light yellowish background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFE082),
            ), // Light gold border
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.attach_file, color: Colors.black54, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Upload clear scanned copies or photos. Accepted formats: PDF, JPG, PNG.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        _buildDocumentUploadCard("Aadhar Card *"),
        _buildDocumentUploadCard("PAN Card *"),
        _buildDocumentUploadCard(
          "Last 3 Months Electricity Bill *",
          allowMultiple: true,
        ),
        _buildDocumentUploadCard("Education Document", allowMultiple: true),
        _buildDocumentUploadCard("Cancelled Cheque *"),
        const SizedBox(height: 30),
        _buildActionButton("Submit Registration", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Submission Successful"),
              backgroundColor: Colors.green,
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    bool isPhone = false,
    bool isEmail = false,
  }) {
    bool isRequired = label.contains('*');
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: isPhone
                ? TextInputType.phone
                : (isEmail ? TextInputType.emailAddress : TextInputType.text),
            validator: (value) =>
                (isRequired && (value == null || value.trim().isEmpty))
                ? 'Required'
                : null,
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items) {
    bool isRequired = label.contains('*');
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: _inputDecoration(hint),
            items: items
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {},
            validator: (v) => (isRequired && (v == null || v.isEmpty))
                ? 'Selection Required'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: darkLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: _inputDecoration(
              hint,
            ).copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 20)),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null)
                setState(
                  () => _dobController.text =
                      "${picked.day}-${picked.month}-${picked.year}",
                );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildDocumentUploadCard(String title, {bool allowMultiple = false}) {
    String fileStatus = _selectedFiles[title] ?? "No file chosen";
    bool hasFile = _selectedFiles.containsKey(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? Colors.green.shade300 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: title.length > 25 ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fileStatus,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasFile
                        ? Colors.green.shade700
                        : Colors.grey.shade400,
                    fontWeight: hasFile ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: allowMultiple,
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
              );

              if (result != null) {
                // --- NEW: VALIDATION FOR MAXIMUM 5 FILES ---
                if (allowMultiple && result.files.length > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "You can only upload a maximum of 5 files.",
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return; // Stop the execution, don't save the files
                }

                setState(() {
                  if (allowMultiple && result.files.length > 1) {
                    _selectedFiles[title] =
                        "${result.files.length} files selected";
                  } else {
                    _selectedFiles[title] = result.files.single.name;
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: hasFile ? Colors.green.shade50 : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasFile ? "Change" : "Upload",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: hasFile ? Colors.green : primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
