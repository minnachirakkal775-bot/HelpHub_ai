import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyHistoryScreen extends StatefulWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  State<EmergencyHistoryScreen> createState() => _EmergencyHistoryScreenState();
}

class _EmergencyHistoryScreenState extends State<EmergencyHistoryScreen> {
  static const String _storageKey = 'saved_emergency_history_log';
  List<Map<String, String>> _historyLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryLogs();
  }

  // Fetch the stored event snapshots from disk memory
  Future<void> _loadHistoryLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? serializedData = prefs.getString(_storageKey);
      if (serializedData != null) {
        final List<dynamic> decodedList = jsonDecode(serializedData);
        setState(() {
          _historyLogs = decodedList.map((item) => Map<String, String>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error reading emergency history logs: $e");
      setState(() => _isLoading = false);
    }
  }

  // Persists the log state collection back down to disk storage
  Future<void> _saveHistoryLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String serializedData = jsonEncode(_historyLogs);
      await prefs.setString(_storageKey, serializedData);
    } catch (e) {
      debugPrint("Error writing emergency history logs: $e");
    }
  }

  // Clear all log files securely
  Future<void> _clearAllLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will permanently delete all records of triggered SOS events.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _historyLogs.clear());
      await _saveHistoryLogs();
    }
  }

  // Utility method to simulate adding a log entry
  void _injectMockEmergencyAlert(String type, String detail) {
    final now = DateTime.now();
    final timestamp = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      _historyLogs.insert(0, {
        'type': type,
        'timestamp': timestamp,
        'details': detail,
        'status': 'Dispatched',
      });
    });
    _saveHistoryLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('Emergency History', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFF44336), // Solid red header
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _historyLogs.isNotEmpty
            ? [IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clearAllLogs, tooltip: 'Clear All Log History')]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF44336))))
          : _historyLogs.isEmpty
          ? _buildEmptyStateWidget()
          : _buildHistoryLogListWidget(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _injectMockEmergencyAlert(
            'SOS Button Pressed',
            'Coordinate beacon dispatched to local network responders.'
        ),
        backgroundColor: const Color(0xFFF44336),
        label: const Text('Simulate Panic Trigger', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(24.0),
        children: const [
          Icon(Icons.assignment_turned_in, size: 64, color: Colors.black26), // Essential placeholder asset layout
          SizedBox(height: 16),
          Text(
            'No emergency alerts triggered yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLogListWidget() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _historyLogs.length,
      itemBuilder: (context, index) {
        final log = _historyLogs[index];
        final isPanicTrigger = log['type'] == 'SOS Button Pressed';

        return Card(
          elevation: 0.5,
          color: const Color(0xFFFFF5F4),
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFEECEB), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPanicTrigger ? Icons.gpp_maybe : Icons.bloodtype,
                          color: const Color(0xFFF44336),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          log['type'] ?? 'Unknown Event',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log['status']?.toUpperCase() ?? 'PENDING',
                        style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFFEECEB), height: 1),
                ),
                Text(
                  log['details'] ?? '',
                  style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.3), // Fixed compiler error here
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 14, color: Colors.black38),
                        SizedBox(width: 4),
                        Text('Captured Target Metric Location Attached', style: TextStyle(fontSize: 11, color: Colors.black38)),
                      ],
                    ),
                    Text(
                      log['timestamp'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}