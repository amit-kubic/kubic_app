// ignore_for_file: file_names, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:kt_app/profile_screen.dart';

class PersonalInformationScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const PersonalInformationScreen({super.key, this.onBackPressed});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  // --- API SETTINGS ---
  // TODO: Update this to your actual API Base URL
  final String baseUrl = "http://10.0.2.2:3000/api";
  bool _isLoading = true;

  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  // --- DYNAMIC DATA MAPS (Initialized with Fallback Dummy Data) ---
  Map<String, String> basicInfo = {
    'Full Name': 'Jatin Dixit',
    'Employee ID': 'EMP-042',
    'Date of Birth': '15 Aug 1998',
    'Gender': 'Male',
    'Blood Group': 'B+',
    'Marital Status': 'Single',
  };

  Map<String, String> contactDetails = {
    'Mobile No.': '+91 98765 43210',
    'Emergency No.': '+91 91234 56789',
    'Email': 'jatin.dixit@kubictech.com',
    'Alternate Email': 'jatindixit@gmail.com',
    'Current Address': 'A-204, Shanti Nagar, Malad West, Mumbai - 400064',
    'Permanent Address': '12, Ganesh Colony, Indore - 452001, MP',
  };

  Map<String, String> employmentDetails = {
    'Department': 'Engineering',
    'Designation': 'Software Developer',
    'Reporting Manager': 'Rohit Sharma',
    'Date of Joining': '10 Jan 2024',
    'Employment Type': 'Full-time',
    'Work Location': 'Malad, Mumbai',
  };

  Map<String, String> bankDetails = {
    'Bank Name': 'HDFC Bank',
    'Account No.': 'XXXX XXXX 4782',
    'IFSC Code': 'HDFC0001234',
    'Branch': 'Malad West, Mumbai',
    'Account Type': 'Savings',
  };

  List<String> uploadedDocs = [
    'Aadhar Card',
    'PAN Card',
    'Electricity Bill',
    'Cancelled Cheque',
    'Education Docs',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // ==========================================
  // API CALL 1: FETCH PROFILE DATA
  // ==========================================
  Future<void> _fetchProfileData() async {
    try {
      // TODO: Replace with your exact Swagger endpoint for GET Profile
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _profileImageUrl =
                data['data']['profile_image'] ?? _profileImageUrl;

            // Safely update maps if API provides them
            if (data['data']['basic_info'] != null) {
              basicInfo = Map<String, String>.from(data['data']['basic_info']);
            }
            if (data['data']['contact_details'] != null) {
              contactDetails = Map<String, String>.from(
                data['data']['contact_details'],
              );
            }
            if (data['data']['employment_details'] != null) {
              employmentDetails = Map<String, String>.from(
                data['data']['employment_details'],
              );
            }
            if (data['data']['bank_details'] != null) {
              bankDetails = Map<String, String>.from(
                data['data']['bank_details'],
              );
            }
            if (data['data']['uploaded_docs'] != null) {
              uploadedDocs = List<String>.from(data['data']['uploaded_docs']);
            }
          });
        }
      }
    } catch (e) {
      print("Failed to fetch profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // API CALL 2: UPDATE BANK DETAILS
  // ==========================================
  Future<void> _updateBankDetails(Map<String, String> newData) async {
    try {
      // TODO: Replace with your exact Swagger endpoint for PUT Bank Details
      final response = await http.put(
        Uri.parse('$baseUrl/profile/bank-details'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode(newData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        setState(() {
          bankDetails = newData;
        });
        _showToast("Bank details updated successfully!", Colors.green);
      } else {
        _showToast(
          data['message'] ?? "Failed to update bank details",
          Colors.red,
        );
      }
    } catch (e) {
      print("Failed to update bank details: $e");
      _showToast("Network Error. Try again.", Colors.red);
    }
  }

  // ==========================================
  // API CALL 3: UPLOAD PROFILE PICTURE
  // ==========================================
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Show loading toast
        _showToast("Uploading profile picture...", Colors.blue);

        // TODO: Replace with your exact Swagger endpoint for Profile Image Upload
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/profile/upload-avatar'),
        );
        // request.headers['Authorization'] = 'Bearer YOUR_TOKEN';
        request.files.add(
          await http.MultipartFile.fromPath('avatar', pickedFile.path),
        );

        var response = await request.send();
        var responseData = await http.Response.fromStream(response);
        var result = jsonDecode(responseData.body);

        if (response.statusCode == 200 && result['status'] == true) {
          setState(() {
            // Update local UI immediately, or use the URL returned by the server
            _profileImageUrl = result['data']['image_url'] ?? pickedFile.path;
          });
          _showToast("Profile picture updated!", Colors.green);
        } else {
          _showToast(result['message'] ?? "Failed to upload image", Colors.red);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      _showToast("Error selecting image", Colors.red);
    }
  }

  void _showToast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "Change Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF3B5998),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF3B5998)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  widget.onBackPressed?.call();
                }
              },
            ),
          ),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF38468E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),
                  InfoSectionCard(
                    title: 'Basic Information',
                    icon: Icons.person,
                    data: basicInfo,
                  ),
                  const SizedBox(height: 12),
                  InfoSectionCard(
                    title: 'Contact Details',
                    icon: Icons.phone_in_talk,
                    data: contactDetails,
                  ),
                  const SizedBox(height: 12),
                  InfoSectionCard(
                    title: 'Employment Details',
                    icon: Icons.business,
                    data: employmentDetails,
                  ),
                  const SizedBox(height: 12),
                  EditableSectionCard(
                    title: 'Bank Details',
                    icon: Icons.account_balance,
                    data: bankDetails,
                    onSave: (newData) {
                      _updateBankDetails(newData); // Trigger API update
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // --- Helper to get initials ---
  String _getInitials(String name) {
    List<String> names = name.trim().split(" ");
    if (names.isEmpty) return "E";
    if (names.length == 1) return names[0][0].toUpperCase();
    return "${names[0][0]}${names[names.length - 1][0]}".toUpperCase();
  }

  Widget _buildHeaderCard() {
    String fullName = basicInfo['Full Name'] ?? 'Employee';
    String designation = employmentDetails['Designation'] ?? 'Staff';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B5998),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showImageSourceOptions,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    image:
                        _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: _profileImageUrl!.startsWith('http')
                                ? NetworkImage(_profileImageUrl!)
                                : FileImage(File(_profileImageUrl!))
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                      ? Text(
                          _getInitials(fullName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Color(0xFF3B5998),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  designation,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isDocExpanded = false;

  Widget _buildDocumentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => isDocExpanded = !isDocExpanded),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description, color: Color(0xFF1E293B)),
            ),
            title: const Text(
              'Uploaded Documents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${uploadedDocs.length} documents'),
            trailing: Icon(
              isDocExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          ),
          if (isDocExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: uploadedDocs
                    .map(
                      (doc) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              doc,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Uploaded',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InfoSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Map<String, String> data;

  const InfoSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  State<InfoSectionCard> createState() => _InfoSectionCardState();
}

class _InfoSectionCardState extends State<InfoSectionCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => isExpanded = !isExpanded),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: const Color(0xFF1E293B)),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: widget.data.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EditableSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Map<String, String> data;
  final Function(Map<String, String>) onSave;

  const EditableSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
    required this.onSave,
  });

  @override
  State<EditableSectionCard> createState() => _EditableSectionCardState();
}

class _EditableSectionCardState extends State<EditableSectionCard> {
  bool isExpanded = false;
  bool isEditing = false;
  late Map<String, String> tempEditData;

  @override
  void initState() {
    super.initState();
    tempEditData = Map.from(widget.data);
  }

  @override
  void didUpdateWidget(covariant EditableSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      tempEditData = Map.from(widget.data);
    }
  }

  void _saveChanges() {
    widget.onSave(tempEditData);
    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? const Color(0xFF3B5998) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => isExpanded = !isExpanded),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: const Color(0xFF1E293B)),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isEditing)
                        TextButton.icon(
                          onPressed: () => setState(() {
                            isEditing = true;
                            tempEditData = Map.from(
                              widget.data,
                            ); // Reset temp data on edit
                          }),
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Color(0xFF3B5998),
                          ),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Color(0xFF3B5998)),
                          ),
                        )
                      else
                        Row(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => isEditing = false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B5998),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  ...widget.data.keys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: isEditing
                          ? TextFormField(
                              initialValue: tempEditData[key],
                              decoration: InputDecoration(
                                labelText: key,
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF3B5998),
                                  ),
                                ),
                              ),
                              onChanged: (val) => tempEditData[key] = val,
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    widget.data[key] ?? '',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
