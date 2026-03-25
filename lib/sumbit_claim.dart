import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubmitClaimScreen extends StatefulWidget {
  const SubmitClaimScreen({super.key});

  @override
  State<SubmitClaimScreen> createState() => _SubmitClaimScreenState();
}

class _SubmitClaimScreenState extends State<SubmitClaimScreen> {
  // controllers
  String? _selectedExpenseTitle; // For Dropdown
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _remarksController = TextEditingController(); // For Remarks

  final Color primaryColor = const Color(0xFF38468E);

  // List of Expense categories
  final List<String> _expenseCategories = [
    "Travel Expense",
    "Fuel Expense",
    "Food Expense",
    "Accommodation Expense",
    "Office Supplies",
    "Client Meeting Expense",
    "Internet / Mobile Bill",
    "Software / Subscription",
    "Courier / Postage",
    "Miscellaneous",
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fill today's date
    _dateController.text = DateFormat("d MMM yyyy").format(DateTime.now());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submitData() {
    // Validation
    if (_selectedExpenseTitle == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Expense Title and enter Amount"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create the new claim object including remarks
    Map<String, dynamic> newClaim = {
      "title": _selectedExpenseTitle,
      "date": _dateController.text,
      "amount": int.tryParse(_amountController.text) ?? 0,
      "status": "Pending",
      "reason": _remarksController.text, // Sending remarks as the reason
    };

    // Go back and pass data
    Navigator.pop(context, newClaim);
  }

  @override
  Widget build(BuildContext context) {
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
          "Submit New Claim",
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
            // INFO BANNER
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Please upload valid bills or receipts for quick approval. Limits apply as per company policy.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 1. EXPENSE TITLE DROPDOWN
            _buildDropdownField("EXPENSE TITLE"),

            // 2. AMOUNT FIELD
            _buildTextField(
              "AMOUNT (₹)",
              "0",
              _amountController,
              isNumber: true,
            ),

            // 3. DATE FIELD
            _buildDateField("EXPENSE DATE", _dateController),

            // 4. REMARKS FIELD (ADDED)
            _buildTextField(
              "REMARKS / NOTE",
              "Add a note for your manager...",
              _remarksController,
              maxLines: 3,
            ),

            const SizedBox(height: 10),

            // MOCK UPLOAD BOX
            Text(
              "ATTACH RECEIPT",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 36,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to upload image or PDF",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // SUBMIT BUTTON
            GestureDetector(
              onTap: _submitData,
              child: Container(
                width: double.infinity,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Text(
                  "Submit Request",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // BUILD DROPDOWN WIDGET
  Widget _buildDropdownField(String label) {
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
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedExpenseTitle,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            decoration: InputDecoration(
              hintText: "Select Category",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            items: _expenseCategories.map((String category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedExpenseTitle = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
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
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber
                ? TextInputType.number
                : TextInputType.multiline,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
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
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
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
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: Colors.black54,
                size: 20,
              ),
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
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                setState(() {
                  controller.text = DateFormat("d MMM yyyy").format(pickedDate);
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
