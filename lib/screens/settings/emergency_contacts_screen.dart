import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  static const String _storageKey = 'saved_emergency_contacts_list';

  List<Map<String, String>> _contacts = [
    {'name': 'Mom', 'relation': 'Mother', 'phone': '+1 987 654 3210'},
    {'name': 'Alex Smith', 'relation': 'Friend', 'phone': '+1 555 019 2834'},
  ];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? serializedData = prefs.getString(_storageKey);
      if (serializedData != null) {
        final List<dynamic> decodedList = jsonDecode(serializedData);
        setState(() {
          _contacts = decodedList.map((item) => Map<String, String>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading emergency contacts: $e");
    }
  }

  Future<void> _saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String serializedData = jsonEncode(_contacts);
      await prefs.setString(_storageKey, serializedData);
    } catch (e) {
      debugPrint("Error saving emergency contacts: $e");
    }
  }

  void _showAddDialog() {
    final nameBox = TextEditingController(text: "Sujikumar");
    final relBox = TextEditingController(text: "father");
    final phoneBox = TextEditingController(text: "9961009121");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6ECEB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add SOS Contact', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameBox,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Contact Name'),
            ),
            TextField(
              controller: relBox,
              textCapitalization: TextCapitalization.none, // Fixed compiler bug here
              decoration: const InputDecoration(labelText: 'Relationship'),
            ),
            TextField(
              controller: phoneBox,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.redAccent))),
          TextButton(
            onPressed: () {
              if (nameBox.text.trim().isNotEmpty && phoneBox.text.trim().isNotEmpty) {
                setState(() {
                  _contacts.add({
                    'name': nameBox.text.trim(),
                    'relation': relBox.text.trim().toLowerCase(), // Securely forces absolute lowercase text handling here
                    'phone': phoneBox.text.trim(),
                  });
                });
                _saveContacts();
              }
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('No emergency contacts added yet.', style: TextStyle(color: Colors.black38)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final c = _contacts[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFEECEB), width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: Colors.redAccent.withOpacity(0.8),
                child: const Icon(Icons.contact_phone, color: Colors.white, size: 20),
              ),
              title: Text(
                c['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${c['relation']} • ${c['phone']}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    _contacts.removeAt(index);
                  });
                  _saveContacts();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _showAddDialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}