// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kt_app/sumbit_claim.dart';

class ReimbursementScreen extends StatefulWidget {
  const ReimbursementScreen({super.key, required String title});

  @override
  State<ReimbursementScreen> createState() => _ReimbursementScreenState();
}

class _ReimbursementScreenState extends State<ReimbursementScreen> {
  final currencyFormat = NumberFormat("#,##0", "en_IN");

  // --- DUMMY DATA (Updated status to 'Settled') ---
  List<Map<String, dynamic>> expenses = [
    {
      "title": "Travel Expense",
      "date": "10 Mar 2026",
      "amount": 2400,
      "status": "Pending",
      "reason": "Client Meeting in Mumbai",
    },
    {
      "title": "Meal Allowance",
      "date": "5 Mar 2026",
      "amount": 800,
      "status": "Settled",
      "reason": "Project Overtime Dinner",
      "hrName": "Priya Sharma",
      "settledAt": "07 Mar 2026, 04:30 PM",
    },
    {
      "title": "Internet Bill",
      "date": "1 Mar 2026",
      "amount": 1200,
      "status": "Settled",
      "reason": "Work from Home - Monthly",
      "hrName": "Rahul Verma",
      "settledAt": "03 Mar 2026, 11:15 AM",
    },
  ];

  Map<String, int> _calculateTotals() {
    int pending = 0;
    int settled = 0;
    for (var expense in expenses) {
      if (expense['status'] == 'Pending') {
        pending += expense['amount'] as int;
      } else if (expense['status'] == 'Settled') {
        settled += expense['amount'] as int;
      }
    }
    return {
      "submitted": pending + settled,
      "settled": settled,
      "pending": pending,
    };
  }

  void _deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Claim deleted successfully"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showExpenseDetails(Map<String, dynamic> item, int index) {
    bool isPending = item['status'] == 'Pending';
    bool isSettled = item['status'] == 'Settled';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(item['status']),
                ],
              ),
              const Divider(height: 30),
              _detailItem(
                "Amount",
                "₹${currencyFormat.format(item['amount'])}",
                Icons.payments_outlined,
              ),
              _detailItem(
                "Expense Date",
                item['date'],
                Icons.calendar_today_outlined,
              ),
              _detailItem(
                "Description",
                item['reason'] ?? "No description",
                Icons.notes,
              ),

              const Text(
                "User Bill Attachment",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildImagePlaceholder("User Bill Preview"),

              // --- HR SETTLE DETAILS (Added below bill attachment) ---
              if (isSettled) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Settlement Details (HR)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF38468E),
                  ),
                ),
                const SizedBox(height: 16),
                _detailItem(
                  "Settled By HR",
                  item['hrName'] ?? "HR Admin",
                  Icons.person_pin_outlined,
                ),
                _detailItem(
                  "Settled On",
                  item['settledAt'] ?? "N/A",
                  Icons.history_toggle_off_outlined,
                ),
                const Text(
                  "Payment Proof (Attached by HR)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                _buildImagePlaceholder("HR Payment Receipt"),
              ],

              if (isPending) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteExpense(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      "Delete Claim Request",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String label) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 30, color: Colors.grey),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF38468E)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    bool isSettled = status == 'Settled';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSettled ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSettled ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reimbursement",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF38468E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  "₹${currencyFormat.format(totals['submitted'])}",
                  "SUBMITTED",
                  Colors.white,
                ),
                _buildStatColumn(
                  "₹${currencyFormat.format(totals['settled'])}",
                  "SETTLED",
                  Colors.white,
                ),
                _buildStatColumn(
                  "₹${currencyFormat.format(totals['pending'])}",
                  "PENDING",
                  Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final item = expenses[index];
                return GestureDetector(
                  onTap: () => _showExpenseDetails(item, index),
                  child: Container(
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
                              item['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['date'],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${currencyFormat.format(item['amount'])}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildStatusChip(item['status']),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () async {
                // Navigate to Submit Screen and wait for the result
                final newClaim = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitClaimScreen(),
                  ),
                );

                // If user submitted a claim, add it to the list and refresh
                if (newClaim != null) {
                  setState(() {
                    expenses.insert(0, newClaim); // Adds to top of list
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF38468E),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38468E).withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Text(
                  " Submit New Claim",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String amount, String label, Color color) {
    return Column(
      children: [
        Text(
          amount,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
