import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Console activity logger string
  String _lastSystemAction = "System fully operational. Standing by for incoming user request payloads...";

  List<Map<String, dynamic>> _userBloodRequests = [];
  List<Map<String, dynamic>> _allRegisteredProfiles = [];
  bool _isLoadingRequests = true;

  // Visibility State Toggle for the user profile section
  bool _showProfiles = false;

  final TextEditingController _messagePayloadController = TextEditingController();
  String _selectedBroadcastTarget = 'All Active Registered Volunteers';

  @override
  void initState() {
    super.initState();
    _fetchIncomingUserRequests();
    _loadAllRegisteredProfiles();
  }

  @override
  void dispose() {
    _messagePayloadController.dispose();
    super.dispose();
  }

  /// FEATURE: Scans SharedPreferences to index ALL unique registered user profiles
  Future<void> _loadAllRegisteredProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    List<Map<String, dynamic>> tempProfiles = [];
    Set<String> uniqueUserIds = {};

    for (String key in keys) {
      if (key.startsWith('profile_name_')) {
        uniqueUserIds.add(key.replaceFirst('profile_name_', ''));
      } else if (key.startsWith('registered_role_')) {
        uniqueUserIds.add(key.replaceFirst('registered_role_', ''));
      }
    }

    for (String id in uniqueUserIds) {
      final String name = prefs.getString('profile_name_$id') ?? 'Unnamed Profile';
      final String phone = prefs.getString('profile_phone_$id') ?? 'No Phone';
      final String role = prefs.getString('registered_role_$id') ?? 'user';
      final String blood = prefs.getString('profile_blood_$id') ?? 'Unknown';

      tempProfiles.add({
        'userId': id,
        'name': name,
        'phone': phone,
        'role': role == 'admin' ? 'Command Admin' : 'Public User',
        'blood': blood,
      });
    }

    // Direct local compatibility mock sync array if storage hasn't been written yet
    if (tempProfiles.isEmpty) {
      tempProfiles.addAll([
        {'userId': 'suji', 'name': 'suji', 'phone': '9847613949', 'role': 'Public User', 'blood': 'AB+'},
        {'userId': 'Minna', 'name': 'Unnamed Profile', 'phone': 'No Phone', 'role': 'Public User', 'blood': 'Unknown'},
        {'userId': 'minna', 'name': 'minna', 'phone': '7894561233', 'role': 'Command Admin', 'blood': 'B-'},
        {'userId': 'vcs', 'name': 'vaishnavi', 'phone': '9876543210', 'role': 'Public User', 'blood': 'B-'}
      ]);
    }

    setState(() {
      _allRegisteredProfiles = tempProfiles;
    });
  }

  /// EMERGENCY PIPELINE: Loads data requests, overriding them dynamically using profile matches
  Future<void> _fetchIncomingUserRequests() async {
    setState(() => _isLoadingRequests = true);
    final prefs = await SharedPreferences.getInstance();
    final String? storedRegistryJson = prefs.getString('persistent_blood_registry');
    final String baselineUserId = prefs.getString('current_user_id') ?? 'sujikumar';

    if (storedRegistryJson != null) {
      final List<dynamic> decodedList = json.decode(storedRegistryJson);
      final List<Map<String, dynamic>> rawRequests = List<Map<String, dynamic>>.from(decodedList)
          .where((element) => element['isUrgentRequest'] == true)
          .toList();

      for (var request in rawRequests) {
        final String requestUserId = request['userId'] ?? baselineUserId;
        final String? registeredName = prefs.getString('profile_name_$requestUserId');
        final String? registeredRole = prefs.getString('registered_role_$requestUserId');
        final String? registeredPhone = prefs.getString('profile_phone_$requestUserId');

        request['displayUserId'] = requestUserId;
        request['userType'] = registeredRole == 'admin' ? 'Command Admin' : 'Public User';

        if (registeredName != null && registeredName.isNotEmpty) request['name'] = registeredName;
        if (registeredPhone != null && registeredPhone.isNotEmpty) request['phone'] = registeredPhone;
      }

      setState(() {
        _userBloodRequests = rawRequests;
        _isLoadingRequests = false;
      });
    } else {
      setState(() {
        _userBloodRequests = [
          {'name': 'suji', 'group': 'A-', 'phone': '9847613949', 'isUrgentRequest': true, 'location': 'null', 'displayUserId': 'sujikumar', 'userType': 'Command Admin'},
          {'name': 'suji', 'group': 'AB+', 'phone': '9847613949', 'isUrgentRequest': true, 'location': 'null', 'displayUserId': 'sujikumar', 'userType': 'Command Admin'}
        ];
        _isLoadingRequests = false;
      });
    }
  }

  /// MASS SMS CONFIG SHEET CONTROL PANEL
  void _openBroadcastDispatchPanel(BuildContext context, String nodeTitle, String defaultTemplate) {
    setState(() { _messagePayloadController.text = defaultTemplate; });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sms_failed, color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Text('Gateway Signal: $nodeTitle', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1))),
                    ],
                  ),
                  const Divider(height: 24, color: Colors.blueGrey),
                  DropdownButtonFormField<String>(
                    value: _selectedBroadcastTarget,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12), border: OutlineInputBorder()),
                    items: ['All Active Registered Volunteers', 'Blood Donor Registry Hub (O- / A+ Target)', 'Sector 4 Local Responder Cells']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) => setModalState(() => _selectedBroadcastTarget = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messagePayloadController,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Message Body...'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() { _lastSystemAction = "Broadcast sent to '$_selectedBroadcastTarget':\n\"${_messagePayloadController.text}\""; });
                      },
                      child: const Text('Execute Broadcast Trigger'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// DIRECT INDIVIDUAL RESPOND SMS SHEETS
  void _openDirectSmsGateway(BuildContext context, String targetUser, String targetPhone) {
    _messagePayloadController.text = "Hello $targetUser, HelpHub Command Center resources are en route.";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SMS Gateway to: $targetUser', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D47A1))),
              const SizedBox(height: 12),
              TextField(controller: _messagePayloadController, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() { _lastSystemAction = "Direct Outbound SMS Dispatched to $targetPhone"; });
                },
                child: const Text('Send Emergency SMS'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_role');
    if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // THEME UPDATE: Soft Light Blue Workspace Background
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Command Center (Admin)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1), // Royal Blue Title bar
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _fetchIncomingUserRequests();
                _loadAllRegisteredProfiles();
              },
              tooltip: 'Sync Hub Data'
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= FEATURE SECTION 1: SYSTEM OVERRIDES =================
              const Text('System Metrics & Node Status Override', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              const SizedBox(height: 8),
              _buildMetricCard(
                icon: Icons.track_changes, iconColor: Colors.redAccent, title: 'Active Emergency Triggers', subtitle: '4 Active Dynamic Broadcast Signals Running',
                onOverrideTap: () => _openBroadcastDispatchPanel(context, 'Emergency Triggers', 'CRITICAL ALERT: Emergency operations center requests status updates.'),
              ),
              _buildMetricCard(
                icon: Icons.hub, iconColor: Colors.purple, title: 'Volunteer Network Nodes', subtitle: '142 Enrolled Dispatch Responders Available',
                onOverrideTap: () => _openBroadcastDispatchPanel(context, 'Network Nodes', 'DEPLOYMENT REQ: Dispatch crews needed at Sector 4 centers.'),
              ),
              _buildMetricCard(
                icon: Icons.dns, iconColor: Colors.blue, title: 'Global Registry Metrics', subtitle: 'Database Core Load Status: Optimal (99.8%)',
                onOverrideTap: () => _openBroadcastDispatchPanel(context, 'Registry Metrics', 'BLOOD DONOR SEEKING: Shortages detected for O- negative lines.'),
              ),
              _buildMetricCard(
                icon: Icons.settings_cell, iconColor: Colors.green, title: 'Broadcast Gateway Logs', subtitle: 'SMS Relay Pipeline Securely Active',
                onOverrideTap: () => _openBroadcastDispatchPanel(context, 'Gateway Logs', 'SYSTEM UPDATE: Cellular channels text streams completed.'),
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.blueGrey),
              const SizedBox(height: 12),

              // ================= FEATURE SECTION 2: COLLAPSIBLE REGISTERED PROFILE INDEX =================
              InkWell(
                onTap: () {
                  setState(() {
                    _showProfiles = !_showProfiles;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.supervised_user_circle, color: Color(0xFF1565C0)),
                          SizedBox(width: 8),
                          Text('All Registered User Profiles View', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                        ],
                      ),
                      Icon(
                        _showProfiles ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF1565C0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              if (_showProfiles) ...[
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allRegisteredProfiles.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.blue.shade50),
                    itemBuilder: (context, index) {
                      final profile = _allRegisteredProfiles[index];
                      final bool isAdmin = profile['role'] == 'Command Admin';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: isAdmin ? Colors.purple.shade50 : Colors.blue.shade50,
                          child: Icon(Icons.person, color: isAdmin ? Colors.purple : Colors.blue, size: 20),
                        ),
                        title: Row(
                          children: [
                            Text(profile['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                  color: isAdmin ? Colors.purple.shade50 : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isAdmin ? Colors.purple.shade100 : Colors.blue.shade100)
                              ),
                              child: Text(profile['role'], style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isAdmin ? Colors.purple : Colors.blue)),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User ID: ${profile['userId']}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 11)),
                            Text('Phone: ${profile['phone']}  •  Blood: ${profile['blood']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(color: Colors.blueGrey),
              const SizedBox(height: 12),

              // ================= SECTION 3: LIVE REQS PIPELINE =================
              const Row(
                children: [
                  Icon(Icons.gpp_maybe, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Live Incoming Emergency Requests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                ],
              ),
              const SizedBox(height: 10),
              _isLoadingRequests
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userBloodRequests.length,
                itemBuilder: (context, index) {
                  final request = _userBloodRequests[index];
                  final String userType = request['userType'] ?? 'Public User';
                  final bool isAdminType = userType == 'Command Admin';

                  return Card(
                    color: Colors.white, // Clean white card layout override
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade100, width: 1.5)),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.red, child: Text(request['group'] ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                      title: Row(
                        children: [
                          Text(request['name'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: isAdminType ? Colors.purple.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text(userType, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isAdminType ? Colors.purple : Colors.blue)),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${request['displayUserId']}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 11)),
                          Text('Phone: ${request['phone']}  •  Zone: ${request['location']}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.forward_to_inbox, color: Color(0xFF1565C0), size: 22),
                        onPressed: () => _openDirectSmsGateway(context, request['name']!, request['phone']!),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0D47A1), borderRadius: BorderRadius.circular(8)),
                child: Text(_lastSystemAction, style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace', fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onOverrideTap}) {
    return Card(
      color: Colors.white, // Clean White base configuration
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade50)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.1), child: Icon(icon, color: iconColor, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        trailing: IconButton(icon: const Icon(Icons.tune, color: Color(0xFF1565C0), size: 20), onPressed: onOverrideTap),
      ),
    );
  }
}