import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_assistant_screen.dart';
import 'login_screen.dart';
import 'settings/settings_screen.dart';
import 'blood_screen.dart';
import 'elderly_screen.dart';
import 'lost_found_screen.dart';
import 'sos_screen.dart';
import 'volunteer_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_role');
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // THEME UPDATE: Integrated Violet, Red, Green, and Orange across the dashboard actions
    final List<Map<String, dynamic>> features = [
      {
        'title': 'AI Assistant',
        'icon': Icons.psychology_alt,
        'screen': const AiAssistantPanel(),
        'color': const Color(0xFF7B1FA2), // Violet
      },
      {
        'title': 'Blood Donors',
        'icon': Icons.bloodtype,
        'screen': const BloodScreen(),
        'color': const Color(0xFFD32F2F), // Red
      },
      {
        'title': 'Elderly Care',
        'icon': Icons.elderly,
        'screen': const ElderlyScreen(),
        'color': const Color(0xFF388E3C), // Green
      },
      {
        'title': 'Lost & Found',
        'icon': Icons.find_in_page,
        'screen': const LostFoundScreen(),
        'color': const Color(0xFFF57C00), // Orange
      },
      {
        'title': 'SOS Panic',
        'icon': Icons.gpp_bad,
        'screen': const SOSScreen(),
        'color': const Color(0xFFE53935), // Red
      },
      {
        'title': 'Volunteers',
        'icon': Icons.volunteer_activism,
        'screen': const VolunteerScreen(),
        'color': const Color(0xFF6A1B9A), // Violet
      },
    ];

    return Scaffold(
      // THEME UPDATE: Sky Blue Background Canvas
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text(
          'HelpHub User Hub',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1), // Dark Blue AppBar
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings & Configuration',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out Account',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: GridView.builder(
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final f = features[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => f['screen']),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                // THEME UPDATE: Pure White Container Cards with soft background blending shadows
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.08), // Dark Blue subtle drop tint
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      f['icon'],
                      color: f['color'], // Injected multi-color accents
                      size: 40,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      f['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1), // Dark Blue Text labels for consistency
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}