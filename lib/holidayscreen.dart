// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kt_app/leavescreen.dart';
import 'package:intl/intl.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key, required String title});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String search = "";

  // Logic for Restricted Limit
  int appliedRestrictedCount = 0; // Replace with your actual count from DB
  final int maxRestrictedAllowed = 2;

  // Map to store keys for each month to enable auto-scrolling
  final Map<String, GlobalKey> _monthKeys = {};

  final List<Map<String, dynamic>> holidays = [
    {
      "name": "New Year's Day",
      "date": "1 Jan 2026",
      "day": "Thu",
      "month": "January",
      "dateNum": "1",
      "monthStr": "JAN",
      "isRestricted": false,
    },
    {
      "name": "Republic Day",
      "date": "26 Jan 2026",
      "day": "Mon",
      "month": "January",
      "dateNum": "26",
      "monthStr": "JAN",
      "isRestricted": false,
    },
    {
      "name": "Holi",
      "date": "3 Mar 2026",
      "day": "Tue",
      "month": "March",
      "dateNum": "3",
      "monthStr": "MAR",
      "isRestricted": false,
    },
    {
      "name": "Gudi Padwa",
      "date": "19 Mar 2026",
      "day": "Thu",
      "month": "March",
      "dateNum": "19",
      "monthStr": "MAR",
      "isRestricted": false,
    },
    {
      "name": "Maharashtra Day",
      "date": "1 May 2026",
      "day": "Fri",
      "month": "May",
      "dateNum": "1",
      "monthStr": "MAY",
      "isRestricted": false,
    },
    {
      "name": "Independence Day",
      "date": "15 Aug 2026",
      "day": "Sat",
      "month": "August",
      "dateNum": "15",
      "monthStr": "AUG",
      "isRestricted": false,
    },
    {
      "name": "Ganesh Chaturthi",
      "date": "14 Sep 2026",
      "day": "Mon",
      "month": "September",
      "dateNum": "14",
      "monthStr": "SEP",
      "isRestricted": false,
    },
    {
      "name": "Gandhi Jayanti",
      "date": "2 Oct 2026",
      "day": "Fri",
      "month": "October",
      "dateNum": "2",
      "monthStr": "OCT",
      "isRestricted": false,
    },
    {
      "name": "Dussehra",
      "date": "20 Oct 2026",
      "day": "Tue",
      "month": "October",
      "dateNum": "20",
      "monthStr": "OCT",
      "isRestricted": false,
    },
    {
      "name": "Bhai Duj",
      "date": "11 Nov 2026",
      "day": "Wed",
      "month": "November",
      "dateNum": "11",
      "monthStr": "NOV",
      "isRestricted": false,
    },
    {
      "name": "Christmas",
      "date": "25 Dec 2026",
      "day": "Fri",
      "month": "December",
      "dateNum": "25",
      "monthStr": "DEC",
      "isRestricted": false,
    },
    {
      "name": "Ramjan Eid ",
      "date": "21 Mar 2026",
      "day": "Fri",
      "month": "March",
      "dateNum": "21",
      "monthStr": "MAR",
      "isRestricted": true,
    },
    {
      "name": "Mahavir Jayanti",
      "date": "31 Mar 2026",
      "day": "Fri",
      "month": "March",
      "dateNum": "31",
      "monthStr": "MAR",
      "isRestricted": true,
    },
    {
      "name": "Good Friday",
      "date": "3 Apr 2026",
      "day": "Fri",
      "month": "April",
      "dateNum": "3",
      "monthStr": "APR",
      "isRestricted": true,
    },
    {
      "name": "Id-ul-Zuha (Bakri eid)",
      "date": "27 May 2026",
      "day": "Fri",
      "month": "May",
      "dateNum": "27",
      "monthStr": "MAY",
      "isRestricted": true,
    },
    {
      "name": "Raksha Bandhan",
      "date": "28 Aug 2026",
      "day": "Fri",
      "month": "August",
      "dateNum": "28",
      "monthStr": "AUG",
      "isRestricted": true,
    },
    {
      "name": "Janamashtmi",
      "date": "5 Sep 2026",
      "day": "Fri",
      "month": "September",
      "dateNum": "5",
      "monthStr": "Sep",
      "isRestricted": true,
    },
    {
      "name": "Deepawali Padwa",
      "date": "10 Nov 2026",
      "day": "Fri",
      "month": "November ",
      "dateNum": "10",
      "monthStr": "NOV",
      "isRestricted": true,
    },
    {
      "name": "Deepawali Padwa",
      "date": "24 Nov 2026",
      "day": "Fri",
      "month": "November ",
      "dateNum": "24",
      "monthStr": "NOV",
      "isRestricted": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Create GlobalKeys for each month present in data
    for (var h in holidays) {
      if (!_monthKeys.containsKey(h["month"])) {
        _monthKeys[h["month"]] = GlobalKey();
      }
    }

    // After the first frame is rendered, scroll to current month
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToCurrentMonth(),
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  void _scrollToCurrentMonth() {
    String currentMonth = DateFormat('MMMM').format(DateTime.now());
    final key = _monthKeys[currentMonth];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic: Always show all months (unless searching)
    final displayList = holidays.where((h) {
      bool isRestrictedTab = _tabController.index == 1;
      bool matchesTab = h["isRestricted"] == isRestrictedTab;
      bool matchesSearch = h["name"].toLowerCase().contains(
        search.toLowerCase(),
      );
      return matchesTab && matchesSearch;
    }).toList();

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
          "Holiday List 2026",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- SLIDING TAB BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 54,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEEF5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF38468E),
                unselectedLabelColor: Colors.grey.shade600,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                tabs: const [
                  Tab(text: "1. Holiday"),
                  Tab(text: "2. Restricted"),
                ],
              ),
            ),
          ),

          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search holiday...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
          ),

          // --- HOLIDAY LIST ---
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text("No holidays found."))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final holiday = displayList[index];

                      // Identify if this is the first holiday of a month to attach the Key
                      bool isFirstOfMonth =
                          index == 0 ||
                          displayList[index - 1]["month"] != holiday["month"];

                      return _buildHolidayCard(
                        holiday,
                        isFirstOfMonth ? _monthKeys[holiday["month"]] : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayCard(Map<String, dynamic> holiday, GlobalKey? monthKey) {
    bool isRestricted = holiday['isRestricted'];
    bool isLimitReached =
        isRestricted && appliedRestrictedCount >= maxRestrictedAllowed;

    return Container(
      key: monthKey, // The key used for auto-scrolling
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRestricted ? const Color(0xFFFFE082) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // DATE PILL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isRestricted
                  ? const Color(0xFFFFF9E6)
                  : const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isRestricted
                    ? const Color(0xFFFFE082)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                Text(
                  holiday['dateNum'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isRestricted
                        ? const Color(0xFFF57F17)
                        : const Color(0xFF38468E),
                  ),
                ),
                Text(
                  holiday['monthStr'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${holiday['day']} • ${holiday['month']}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // ACTIONS
          if (isRestricted)
            GestureDetector(
              onTap: isLimitReached
                  ? null
                  : () {
                      final Map<String, dynamic> holidayDataForLeave = Map.from(
                        holiday,
                      );
                      holidayDataForLeave['fullDate'] = holiday['date'];

                      // --- NEW ADDITIONS ---
                      // Pass explicitly that this is a Half Day and the date cannot be changed
                      holidayDataForLeave['isHalfDay'] = true;
                      holidayDataForLeave['isDateLocked'] = true;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaveManagementScreen(
                            initialTab: 1,
                            prefilledHoliday: holidayDataForLeave,
                            title: 'Holiday',
                          ),
                        ),
                      );
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isLimitReached
                      ? Colors.grey.shade200
                      : const Color(0xFFF0A500),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLimitReached ? "Used" : "Apply",
                  style: TextStyle(
                    color: isLimitReached ? Colors.grey : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Mandatory",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
