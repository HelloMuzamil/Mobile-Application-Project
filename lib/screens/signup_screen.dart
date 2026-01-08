import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homescreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
 
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool loading = false;

  // Signup function
  void registerUser() async {
    setState(() {
      loading = true;
    });

    try {
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),


      );

        // 2️⃣ Save user info in Firestore
  String uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'name': nameController.text.trim(),
    'email': emailController.text.trim(),
    'createdAt': FieldValue.serverTimestamp(), // optional
  });
     
      // ✅ SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup Successful")));

      // ✅ Small delay so user SnackBar dekh sake
      await Future.delayed(const Duration(seconds: 1));

      // ✅ Redirect to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } 
    catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // HEADER (bold + bigger)
                      Center(
                        child: Text(
                          "SIGNUP",
                          style: TextStyle(
                            fontSize: 36, // bigger
                            fontWeight: FontWeight.bold, // bold
                            letterSpacing: 2,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      _label("Full Name"),
                      _field(
                        "Enter Your Full Name",
                        controller: nameController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Name required";
                          }
                          return null;
                        },
                      ),

                      _label("Email"),
                      _field(
                        "Enter Your Email",
                        controller: emailController,
                        validator: (v) {
                          if (v == null || !v.contains("@")) {
                            return "Invalid email";
                          }
                          return null;
                        },
                      ),

                      _label("Phone"),
                      _field(
                        "Phone number",
                        controller: phoneController,
                        validator: (v) {
                          if (v == null || v.length < 10) {
                            return "Invalid phone";
                          }
                          return null;
                        },
                      ),

                      _label("Password"),
                      _field(
                        "Password",
                        controller: passwordController,
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return "Min 6 characters";
                          }
                          return null;
                        },
                      ),

                      _label("Confirm Password"),
                      _field(
                        "Confirm Password",
                        controller: confirmPasswordController,
                        obscure: true,
                        validator: (v) {
                          if (v != passwordController.text) {
                            return "Password not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              registerUser();
                            }
                          },
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Label widget
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 6),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
    );
  }

  // Input field widget
  Widget _field(
    String hint, {
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
