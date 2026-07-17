import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Account Controllers
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Profile Details Controllers (Matching your UI fields)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();

  String _selectedBloodGroup = 'B+'; // Default matching your profile screenshot
  String _selectedRole = 'user';
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _medicalController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = _userIdController.text.trim();

      // 1. Save Core Authentication Credentials
      await prefs.setString('registered_password_$userId', _passwordController.text);
      await prefs.setString('registered_role_$userId', _selectedRole);

      // 2. Save Detailed Profile Metadata linked directly to this specific User ID
      await prefs.setString('profile_name_$userId', _nameController.text.trim());
      await prefs.setString('profile_phone_$userId', _phoneController.text.trim());
      await prefs.setString('profile_blood_$userId', _selectedBloodGroup);
      await prefs.setString('profile_medical_$userId', _medicalController.text.trim());

      // 3. Log the user into the active device session directly
      await prefs.setString('auth_role', _selectedRole);
      await prefs.setString('current_user_id', userId); // Track who is logged in

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created & Profile Details Updated!')),
        );

        // Route straight to the designated home matrix board
        Navigator.pushNamedAndRemoveUntil(
          context,
          _selectedRole == 'admin' ? '/admin_home' : '/user_home',
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("🚨 Registration Failure: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFB),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New User Registration', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Fill out your details to setup your profile.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Full Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  validator: (val) => val!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 16),

                // Primary Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Primary Phone Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                  validator: (val) => val!.isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 16),

                // Blood Group Dropdown Setup
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder(), prefixIcon: Icon(Icons.bloodtype)),
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                      .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBloodGroup = val!),
                ),
                const SizedBox(height: 16),

                // Critical Medical Conditions Form Field
                TextFormField(
                  controller: _medicalController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Critical Medical Conditions / Allergies',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const Divider(height: 40, thickness: 1),

                // System Security Login Account Mappings
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'Choose a Unique User ID', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                  validator: (val) => val!.isEmpty ? 'Please choose a User ID' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                  validator: (val) => val!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // Account Access Level Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'App Access Role', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Public App User')),
                    DropdownMenuItem(value: 'admin', child: Text('Command Center Admin')),
                  ],
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: 32),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleRegister,
                  child: const Text('Register & Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}