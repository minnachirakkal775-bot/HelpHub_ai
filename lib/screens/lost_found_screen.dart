import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  static const String _storageKey = 'persistent_lost_found_items';

  // Base list that shows on first run if local storage is empty
  List<Map<String, String>> _items = [
    {
      'title': 'Black Leather Wallet',
      'type': 'Lost',
      'location': 'Central Park Metro Station',
      'date': 'June 09, 2026'
    },
    {
      'title': 'Keys with Red Fob',
      'type': 'Found',
      'location': 'Library Cafeteria',
      'date': 'June 07, 2026'
    },
  ];

  // Dialog Form Controllers
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoredItems(); // Automatically load saved data on startup
  }

  // Load items from local storage
  Future<void> _loadStoredItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? serializedData = prefs.getString(_storageKey);

      if (serializedData != null) {
        final List<dynamic> decodedList = jsonDecode(serializedData);
        setState(() {
          _items = decodedList.map((item) => Map<String, String>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading persistent data: $e");
    }
  }

  // Save items to local storage
  Future<void> _saveItemsToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String serializedData = jsonEncode(_items);
      await prefs.setString(_storageKey, serializedData);
    } catch (e) {
      debugPrint("Error saving data to disk: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Opens a styled modal matching the app architecture
  void _showReportItemDialog() {
    String selectedType = 'Lost';

    // Set default date to today's date placeholder
    _dateController.text = "June 17, 2026";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF9F5), // Matches orange theme background
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.assignment_outlined, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(
                    'Report Item',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Segmented selection for Lost vs Found
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Lost')),
                            selected: selectedType == 'Lost',
                            selectedColor: Colors.red.shade100,
                            labelStyle: TextStyle(
                              color: selectedType == 'Lost' ? Colors.red.shade800 : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (bool selected) {
                              if (selected) setModalState(() => selectedType = 'Lost');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Found')),
                            selected: selectedType == 'Found',
                            selectedColor: Colors.green.shade100,
                            labelStyle: TextStyle(
                              color: selectedType == 'Found' ? Colors.green.shade800 : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (bool selected) {
                              if (selected) setModalState(() => selectedType = 'Found');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Item Name / Description',
                        hintText: 'e.g., iPhone 13 Pro',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., Cafeteria Second Floor',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                TextButton(
                  onPressed: () {
                    _titleController.clear();
                    _locationController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty &&
                        _locationController.text.trim().isNotEmpty) {

                      setState(() {
                        _items.insert(0, {
                          'title': _titleController.text.trim(),
                          'type': selectedType,
                          'location': _locationController.text.trim(),
                          'date': _dateController.text.trim(),
                        });
                      });

                      _saveItemsToDisk(); // Save to local storage

                      _titleController.clear();
                      _locationController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Lost & Found Board', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.orange, // Standardized theme color mapping
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No items reported yet.', style: TextStyle(color: Colors.black45)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final isLost = item['type'] == 'Lost';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDFB), // Soft item container background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF5EFEA), width: 1),
            ),
            child: Row(
              children: [
                // Status Circle Indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLost ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLost ? Icons.search : Icons.check_circle_outline,
                    color: isLost ? Colors.red : Colors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Content Fields
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${item['location']}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Date: ${item['date']}',
                        style: const TextStyle(color: Colors.black45, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Status Label Tag Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLost ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['type']!,
                    style: TextStyle(
                      color: isLost ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange, // Matches lower actionable target button configuration
        onPressed: _showReportItemDialog,
        tooltip: 'Report Item',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}