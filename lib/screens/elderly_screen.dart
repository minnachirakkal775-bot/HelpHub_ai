import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ElderlyScreen extends StatefulWidget {
  const ElderlyScreen({super.key});

  @override
  State<ElderlyScreen> createState() => _ElderlyScreenState();
}

class _ElderlyScreenState extends State<ElderlyScreen> {
  // Local storage mapping identifier key
  static const String _storageKey = 'persistent_medication_list';

  // Base list layout data that shows up on first app launch if storage is empty
  List<Map<String, dynamic>> _medications = [
    {
      'name': 'Aspirin Cardio',
      'time': '08:00 AM',
      'isCompleted': true,
    },
    {
      'name': 'Metformin HCl',
      'time': '01:30 PM',
      'isCompleted': false,
    },
    {
      'name': 'Multivitamin Complex',
      'time': '09:00 PM',
      'isCompleted': false,
    },
  ];

  final _medicationNameController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadStoredMedications(); // Read data on screen initialization boot pipeline
  }

  // Reads the saved JSON array string from local memory cache
  Future<void> _loadStoredMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? serializedJson = prefs.getString(_storageKey);

      if (serializedJson != null) {
        final List<dynamic> decodedList = jsonDecode(serializedJson);
        setState(() {
          _medications = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error parsing locally stored entries: $e");
    }
  }

  // Commits the modified operational list data elements back down to internal storage
  Future<void> _saveMedicationsToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String serializedJson = jsonEncode(_medications);
      await prefs.setString(_storageKey, serializedJson);
    } catch (e) {
      debugPrint("Failed to execute local storage save operation: $e");
    }
  }

  // NEW FEATURE: Removes a medication item by index and commits changes to disk
  void _deleteMedication(int index) {
    final String removedItemName = _medications[index]['name'];
    setState(() {
      _medications.removeAt(index);
    });
    _saveMedicationsToDisk();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$removedItemName removed from schedule.'),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context, StateSetter setModalState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setModalState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String formattedTime = _selectedTime.format(context);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.add_task, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Schedule Medication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _medicationNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      hintText: 'e.g., Vitamin D3',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medication),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: const Icon(Icons.access_time, color: Colors.green),
                    title: const Text('Dispatch Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                      formattedTime,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade800,
                        elevation: 0,
                      ),
                      onPressed: () => _pickTime(context, setModalState),
                      child: const Text('Pick'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _medicationNameController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_medicationNameController.text.trim().isNotEmpty) {
                      setState(() {
                        _medications.add({
                          'name': _medicationNameController.text.trim(),
                          'time': formattedTime,
                          'isCompleted': false,
                        });
                      });

                      // Save immediately after modification
                      _saveMedicationsToDisk();

                      _medicationNameController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Task'),
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
        title: const Text('Elderly Care Hub', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF4CAF50), // Matches mockup theme layout tone
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        backgroundColor: const Color(0xFF4CAF50), // Lower button style color configuration
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Medical Operations Monitor',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _medications.isEmpty
                  ? const Center(
                child: Text(
                  'No medications scheduled. Tap + to add.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final item = _medications[index];
                  final bool isDone = item['isCompleted'];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFFE8F5E9) : Colors.white, // Conditional verification styling status background
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone ? Colors.transparent : const Color(0xFFEEEEEE),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDone ? Colors.black54 : Colors.black87,
                                    decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none, // Striking text line layout check
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Scheduled Dispatch Time: ${item['time']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDone ? Colors.black45 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // NEW UPDATED ACTION AREA: Row housing Delete option alongside check validation toggles
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _deleteMedication(index),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    item['isCompleted'] = !item['isCompleted'];
                                  });

                                  // Write state mutation safely to permanent disk index file
                                  _saveMedicationsToDisk();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isDone ? const Color(0xFF4CAF50) : Colors.transparent, // Active checkbox frame fill tint
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isDone ? const Color(0xFF4CAF50) : Colors.black54,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isDone
                                      ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}