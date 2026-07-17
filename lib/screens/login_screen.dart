import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = _userIdController.text.trim();
      final String password = _passwordController.text;

      // Retrieve locally saved registration data
      final String? savedPassword = prefs.getString('registered_password_$userId');
      final String? savedRole = prefs.getString('registered_role_$userId');

      // Hardcoded Admin fallback for testing (User ID: admin, Password: password123)
      if (userId == 'admin' && password == 'password123') {
        await prefs.setString('auth_role', 'admin');
        if (mounted) Navigator.pushReplacementNamed(context, '/admin_home');
        return;
      }

      // Check credential validation
      if (savedPassword != null && savedPassword == password) {
        await prefs.setString('auth_role', savedRole ?? 'user');
        if (mounted) {
          Navigator.pushReplacementNamed(
              context,
              savedRole == 'admin' ? '/admin_home' : '/user_home'
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid User ID or Password')),
          );
        }
      }
    } catch (e) {
      debugPrint("🚨 Login Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 80, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text('HelpHub AI Login', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'User ID', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Enter your User ID' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Enter your password' : null,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _handleLogin,
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('New user? Register here', style: TextStyle(color: Colors.redAccent)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}