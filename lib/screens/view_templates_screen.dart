import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewTemplatesScreen extends StatefulWidget {
  const ViewTemplatesScreen({super.key});

  @override
  State<ViewTemplatesScreen> createState() => _ViewTemplatesScreenState();
}

class _ViewTemplatesScreenState extends State<ViewTemplatesScreen> {
  User? user;
  bool selectMode = false; // ✅ Selection mode check karne ke liye

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _initializePredefinedTemplates(); // ✅ Default templates add karenge
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // ✅ Check if we're in selection mode
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['selectMode'] == true) {
      selectMode = true;
    }
  }

  // ✅ DEFAULT TEMPLATES - Agar pehle se nahi hain to add kar do
  Future<void> _initializePredefinedTemplates() async {
    if (user == null) return;

    final templatesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('templates');

    // Check if templates already exist
    final snapshot = await templatesRef.get();
    if (snapshot.docs.isNotEmpty) return; // Already initialized

    // ✅ ADD PREDEFINED TEMPLATES
    final predefinedTemplates = [
      {
        'id': 'template_1',
        'name': 'Classic Wish',
        'text': 'Happy Birthday! 🎉 Wishing you a fantastic day filled with joy and laughter!',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'template_2',
        'name': 'Heartfelt Message',
        'text': 'Happy Birthday to an amazing person! May this year bring you endless happiness and success! 🎂✨',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'template_3',
        'name': 'Short & Sweet',
        'text': 'Happy Birthday! 🎈 Have a wonderful day!',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var template in predefinedTemplates) {
      await templatesRef.doc(template['id'] as String).set(template);
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          selectMode ? "Select Template" : "My Templates", // ✅ Dynamic title
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          if (!selectMode) // ✅ Add button sirf normal mode mein show ho
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/addTemplate");
              },
              icon: const Icon(Icons.add, color: Colors.black),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('templates')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No templates yet!\nTap + to add one.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final templates = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final doc = templates[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          data['name'] ?? 'Untitled',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data['text'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: selectMode
                            ? const Icon(Icons.chevron_right) // ✅ Selection indicator
                            : IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTemplate(doc.id),
                              ),
                        onTap: () {
                          if (selectMode) {
                            // ✅ Selection mode mein - template select karke wapis jao
                            Navigator.pop(context, {
                              'id': doc.id,
                              'name': data['name'],
                              'text': data['text'],
                            });
                          } else {
                            // ✅ Normal mode mein - template detail dikhao
                            _showTemplateDetail(context, data);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // ✅ Template delete karne ka function
  Future<void> _deleteTemplate(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text('Are you sure you want to delete this template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('templates')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ Template detail dikhane ka function
  void _showTemplateDetail(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['name'] ?? 'Template'),
        content: SingleChildScrollView(
          child: Text(data['text'] ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}