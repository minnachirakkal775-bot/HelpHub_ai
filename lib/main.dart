import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/admin_home_screen.dart';

void main() async {
  // Ensure Flutter bindings are ready before executing services
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the secure environment variables (for your Groq API key)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ Warning: Could not load .env configuration asset: $e");
  }

  // 2. Determine initial entry route based on device persistence memory
  final prefs = await SharedPreferences.getInstance();
  final String? userRole = prefs.getString('auth_role');

  runApp(HelpHubApp(initialRole: userRole));
}

class HelpHubApp extends StatelessWidget {
  final String? initialRole;

  const HelpHubApp({super.key, this.initialRole});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpHub AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // UPDATED: Shifted seed and primary colors to match the blue canvas brand layout
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // Corporate Dark Blue theme anchor
          primary: const Color(0xFF0D47A1),
        ),
        scaffoldBackgroundColor: const Color(0xFFE1F5FE), // Consistent Sky Blue background canvas
        useMaterial3: true,
      ),
      // 3. Mounts the initial UI widget view context dynamically based on saved role string
      home: _getInitialScreen(initialRole),

      // 4. Declared explicitly named App Routing table
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/user_home': (context) => const UserHomeScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
      },
    );
  }

  Widget _getInitialScreen(String? role) {
    if (role == 'admin') {
      return const AdminHomeScreen();
    } else if (role == 'user') {
      return const UserHomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}