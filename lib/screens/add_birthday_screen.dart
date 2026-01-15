import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './services/notification_service.dart'; // ✅ IMPORT NOTIFICATION SERVICE

class AddBirthdayScreen extends StatefulWidget {
  const AddBirthdayScreen({super.key});

  @override
  State<AddBirthdayScreen> createState() => _AddBirthdayScreenState();
}

class _AddBirthdayScreenState extends State<AddBirthdayScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // ✅ Template selection variables
  String? _selectedTemplateId;
  String? _selectedTemplateName;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// ✅ PICK IMAGE FROM GALLERY
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  /// ✅ SELECT TEMPLATE FUNCTION
  Future<void> _selectTemplate() async {
    final result = await Navigator.pushNamed(
      context,
      "/viewTemplates",
      arguments: {'selectMode': true},
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedTemplateId = result['id'];
        _selectedTemplateName = result['name'];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: $_selectedTemplateName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FA3D9),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Add Birthday",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // ✅ USER IMAGE PICKER
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.black54,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ NAME FIELD
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ PHONE NUMBER FIELD
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Phone Number (with country code)",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "e.g. +923001234567",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ DOB FIELD
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "DOB",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Date of Birth",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dobController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                ),

                const SizedBox(height: 32),

                // ✅ SELECT TEMPLATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectTemplate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C3C3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedTemplateName ?? "Select Template",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ ADD FRIEND BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _addBirthday,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C3C3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add Friend",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // ✅ LOADING OVERLAY
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ✅ ADD BIRTHDAY FUNCTION WITH NOTIFICATION SETUP
  Future<void> _addBirthday() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select an image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw "User not logged in";
      }

      // ✅ CONVERT IMAGE TO BASE64
      final bytes = await _pickedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // ✅ CONVERT DOB STRING TO DATETIME
      List<String> parts = _dobController.text.split('/');
      DateTime dob = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      // ✅ SAVE TO FIRESTORE
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('birthdays')
          .add({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': Timestamp.fromDate(dob),
        'imageBase64': base64Image,
        'selectedTemplateId': _selectedTemplateId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ SCHEDULE NOTIFICATIONS FOR THIS BIRTHDAY
      await NotificationService.checkAndScheduleNotifications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Birthday Added & Notifications Set ✓"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("❌ Error: $e");
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}