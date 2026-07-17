import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  static const String _storageKey = 'persistent_volunteer_drives';

  // Core base array configuration matching image_545c4b.png mock data
  List<Map<String, dynamic>> _drives = [
    {
      'title': 'Sector 4 Emergency Relief Food Drive',
      'proximity': '1.2 km away',
      'iconCode': Icons.fastfood.codePoint,
      'isDeployed': false,
    },
    {
      'title': 'First Aid Support Station - Civic Center',
      'proximity': '3.4 km away',
      'iconCode': Icons.medical_services.codePoint,
      'isDeployed': false,
    },
  ];

  // Text asset capture controllers
  final _titleController = TextEditingController();
  final _proximityController = TextEditingController();
  IconData _selectedIcon = Icons.volunteer_activism;

  @override
  void initState() {
    super.initState();
    _loadVolunteerDrives(); // Load state records on widget initialization
  }

  // Reads the saved volunteer drives list string from local memory cache
  Future<void> _loadVolunteerDrives() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? serializedData = prefs.getString(_storageKey);
      if (serializedData != null) {
        final List<dynamic> decodedList = jsonDecode(serializedData);
        setState(() {
          _drives = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error rehydrating drive assets: $e");
    }
  }

  // Commits the modified list configuration array down to disk storage
  Future<void> _saveVolunteerDrives() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String serializedData = jsonEncode(_drives);
      await prefs.setString(_storageKey, serializedData);
    } catch (e) {
      debugPrint("Failed to execute background local storage commit: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _proximityController.dispose();
    super.dispose();
  }

  // Toggles deployment participation and saves state updates
  void _toggleDeployment(int index) {
    setState(() {
      _drives[index]['isDeployed'] = !(_drives[index]['isDeployed'] ?? false);
    });
    _saveVolunteerDrives();

    final bool status = _drives[index]['isDeployed'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status ? 'Successfully joined deployment node!' : 'Deployment deployment terminated.'),
        backgroundColor: status ? Colors.green : Colors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Opens an intuitive input dialog overlay to append custom missions
  void _showAddDriveDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF9FA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.add_location_alt, color: Colors.purple),
                  SizedBox(width: 10),
                  Text('Host New Relief Drive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Drive Mission Name',
                        hintText: 'e.g., Flood Water Distribution',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _proximityController,
                      decoration: const InputDecoration(
                        labelText: 'Proximity / Distance Info',
                        hintText: 'e.g., 2.5 km away',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<IconData>(
                      value: _selectedIcon,
                      decoration: const InputDecoration(labelText: 'Operation Sector Category', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: Icons.fastfood, child: Row(children: [Icon(Icons.fastfood, color: Colors.purple, size: 20), SizedBox(width: 8), Text('Food Drive')])),
                        DropdownMenuItem(value: Icons.medical_services, child: Row(children: [Icon(Icons.medical_services, color: Colors.purple, size: 20), SizedBox(width: 8), Text('Medical Station')])),
                        DropdownMenuItem(value: Icons.volunteer_activism, child: Row(children: [Icon(Icons.volunteer_activism, color: Colors.purple, size: 20), SizedBox(width: 8), Text('General Relief')])),
                      ],
                      onChanged: (val) => setModalState(() => _selectedIcon = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _titleController.clear();
                    _proximityController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty && _proximityController.text.trim().isNotEmpty) {
                      setState(() {
                        _drives.add({
                          'title': _titleController.text.trim(),
                          'proximity': _proximityController.text.trim(),
                          'iconCode': _selectedIcon.codePoint,
                          'isDeployed': false,
                        });
                      });
                      _saveVolunteerDrives(); // Persist changes locally
                      _titleController.clear();
                      _proximityController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Launch Drive', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('Volunteer Networks', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.purple, // Purple signature background theme
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _showAddDriveDialog,
        tooltip: 'Launch Mission Event',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: _drives.isEmpty
          ? const Center(child: Text('No volunteer drives registered at this time.', style: TextStyle(color: Colors.black38)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _drives.length,
        itemBuilder: (context, index) {
          final drive = _drives[index];
          final bool activeDeployment = drive['isDeployed'] ?? false;
          final IconData iconData = IconData(drive['iconCode'], fontFamily: 'MaterialIcons');

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9FA), // Matched card background coloring profile
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF5EFEB), width: 1.5),
            ),
            child: Row(
              children: [
                // Circular Icon Avatar Group Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E5F5), // Pastel inner purple container mask color profile
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: Colors.purple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Content Segment Metadata Strings
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drive['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Proximity Radius: ${drive['proximity']}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action Trigger Execution Button Element
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeDeployment ? Colors.green : Colors.purple, // Dynamic toggled tint
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () => _toggleDeployment(index),
                    child: Text(
                      activeDeployment ? 'Active' : 'Deploy',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}