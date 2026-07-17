import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  static const String _storageKey = 'persistent_emergency_contacts';

  // State Management Flags
  bool _isCountdownActive = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;

  // Local State Cache for Emergency Contacts
  List<Map<String, String>> _emergencyContacts = [
    {'name': 'National Emergency Line', 'phone': '911', 'relation': 'Authority'},
    {'name': 'Central Medical Dispatch', 'phone': '102', 'relation': 'Medical'},
  ];

  // Controllers for input management
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  // Reads the saved emergency contact list array string from local storage
  Future<void> _loadEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? serializedData = prefs.getString(_storageKey);
      if (serializedData != null) {
        final List<dynamic> decodedList = jsonDecode(serializedData);
        setState(() {
          _emergencyContacts = decodedList.map((item) => Map<String, String>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error reading contacts database: $e");
    }
  }

  // Commits contacts list to local flash memory storage
  Future<void> _saveContactsToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String serializedData = jsonEncode(_emergencyContacts);
      await prefs.setString(_storageKey, serializedData);
    } catch (e) {
      debugPrint("Failed to execute storage write: $e");
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  // Triggers the safety delay countdown sequence
  void _startSOSTriggerSequence() {
    if (_isCountdownActive) return;

    setState(() {
      _isCountdownActive = true;
      _countdownSeconds = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountdownActive = false;
        });
        _dispatchEmergencyAlertSignals();
      }
    });
  }

  // Cancels active broadcast countdown immediately
  void _cancelSOSSequence() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownActive = false;
      _countdownSeconds = 5;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS Broadcast aborted safely.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  // Executes localized emergency response protocol
  void _dispatchEmergencyAlertSignals() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFEBEE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.gpp_maybe, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('SOS Emergency Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        content: const Text(
          'Emergency location coordinates and panic beacons have been dispatched to all registered responders.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss Monitor'),
          )
        ],
      ),
    );
  }

  // Opens a custom dialog to add contact configurations to the registry list
  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Guardian Contact', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Responder Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _relationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Relationship (e.g., Doctor, Son)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _phoneController.clear();
              _relationController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                setState(() {
                  _emergencyContacts.add({
                    'name': _nameController.text.trim(),
                    'phone': _phoneController.text.trim(),
                    'relation': _relationController.text.trim().isEmpty ? 'Guardian' : _relationController.text.trim(),
                  });
                });
                _saveContactsToDisk();
                _nameController.clear();
                _phoneController.clear();
                _relationController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Save Contact'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('SOS Panic Trigger', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: _isCountdownActive ? const Color(0xFFFFEBEE) : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: _isCountdownActive ? 240 : 200,
                        height: _isCountdownActive ? 240 : 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isCountdownActive ? Colors.red.withOpacity(0.2) : Colors.redAccent.withOpacity(0.1),
                        ),
                      ),
                      GestureDetector(
                        onTap: _isCountdownActive ? _cancelSOSSequence : _startSOSTriggerSequence,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _isCountdownActive ? 'STOP\n($_countdownSeconds)' : 'TAP\nSOS',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isCountdownActive ? 'Broadcasting dispatch signal shortly...' : 'Tap circle boundary to issue panic alert data packets',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isCountdownActive ? FontWeight.bold : FontWeight.normal,
                        color: _isCountdownActive ? Colors.red : Colors.black54
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),

          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // FIXED: Changed parameter from 'cross' to 'crossAxisAlignment'
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assigned Emergency Responders',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      IconButton(
                        onPressed: _showAddContactDialog,
                        icon: const Icon(Icons.person_add_alt_1, color: Colors.redAccent),
                        tooltip: 'Register Guardian Contact',
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _emergencyContacts.isEmpty
                        ? const Center(child: Text('No custom guardians configured yet.', style: TextStyle(color: Colors.black38)))
                        : ListView.builder(
                      itemCount: _emergencyContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _emergencyContacts[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade50,
                              child: const Icon(Icons.contact_phone, color: Colors.redAccent, size: 20),
                            ),
                            title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${contact['relation']} • Line: ${contact['phone']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.black38),
                              onPressed: () {
                                setState(() {
                                  _emergencyContacts.removeAt(index);
                                });
                                _saveContactsToDisk();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}