import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Input controller bridges
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();

  String _selectedBloodGroup = 'B+'; // Default matching your registration baseline fallback value
  bool _isLoading = true;
  String _currentUserId = ''; // Track active session key

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Read stored fields on start
  }

  // Pulls data out of local system storage and populates the text fields
  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Get the current active user ID that logged in or registered
      _currentUserId = prefs.getString('current_user_id') ?? '';

      setState(() {
        // 2. FIXED: Read values matching the EXACT keys set in RegisterScreen
        _nameController.text = prefs.getString('profile_name_$_currentUserId') ?? '';
        _phoneController.text = prefs.getString('profile_phone_$_currentUserId') ?? '';
        _medicalController.text = prefs.getString('profile_medical_$_currentUserId') ?? '';
        _selectedBloodGroup = prefs.getString('profile_blood_$_currentUserId') ?? 'B+';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load user profile values: $e");
      setState(() => _isLoading = false);
    }
  }

  // Persists the form input string values down to flash storage keys
  Future<void> _saveProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // FIXED: Save back to the exact same dynamic keys per specific user account ID
      await prefs.setString('profile_name_$_currentUserId', _nameController.text.trim());
      await prefs.setString('profile_phone_$_currentUserId', _phoneController.text.trim());
      await prefs.setString('profile_blood_$_currentUserId', _selectedBloodGroup);
      await prefs.setString('profile_medical_$_currentUserId', _medicalController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile changes securely committed to disk storage!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Storage write failure: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to preserve system modifications locally.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _medicalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFEF5350), // RedAccent tone
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF5350))))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Profile Avatar Placeholder Ring
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFF9E9E9E), // Gray circular mask
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 65, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            // Outlined Input Fields Group
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Primary Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Blood Group Combo Selector Menu
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'A+', child: Text('A+')),
                DropdownMenuItem(value: 'A-', child: Text('A-')),
                DropdownMenuItem(value: 'B+', child: Text('B+')),
                DropdownMenuItem(value: 'B-', child: Text('B-')),
                DropdownMenuItem(value: 'O+', child: Text('O+')),
                DropdownMenuItem(value: 'O-', child: Text('O-')),
                DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                DropdownMenuItem(value: 'AB-', child: Text('AB-')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedBloodGroup = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Multiline Medical Box
            TextField(
              controller: _medicalController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Critical Medical Conditions / Allergies',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 36),

            // Save Profile Data Button Callout
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF5350),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 2,
                ),
                onPressed: _saveProfileData,
                child: const Text(
                  'Save Profile Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}