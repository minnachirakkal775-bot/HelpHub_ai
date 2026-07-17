import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'emergency_contacts_screen.dart';
import 'emergency_messages_screen.dart';
import 'emergency_history_screen.dart';
import 'language_screen.dart';
import 'features_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Configuration'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: ListView(
        children: [
          _buildHeader('ACCOUNT & PERSONALIZATION'),
          _buildTile(context, Icons.person_outline, 'User Profile', 'Edit info and medical data', const ProfileScreen()),
          _buildTile(context, Icons.language, 'Language / Locale', 'Change display language', const LanguageScreen()),
          const Divider(),
          _buildHeader('EMERGENCY CONFIGURATIONS'),
          _buildTile(context, Icons.contact_phone_outlined, 'Emergency Contacts', 'Manage SOS numbers', const EmergencyContactsScreen()),
          _buildTile(context, Icons.chat_bubble_outline, 'Emergency Messages', 'Customize SMS templates', const EmergencyMessagesScreen()),
          _buildTile(context, Icons.history, 'Emergency History', 'View past incidents', const EmergencyHistoryScreen()),
          const Divider(),
          _buildHeader('APPLICATION CONTROL'),
          _buildTile(context, Icons.tune, 'Features Settings', 'Configure hardware triggers', const FeaturesSettingsScreen()),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) => Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)));

  Widget _buildTile(BuildContext context, IconData icon, String title, String sub, Widget screen) => ListTile(
    leading: Icon(icon, color: Colors.redAccent),
    title: Text(title),
    subtitle: Text(sub),
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
  );
}