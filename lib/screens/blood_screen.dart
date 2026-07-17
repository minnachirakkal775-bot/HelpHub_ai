import 'package:flutter/material.dart';

class BloodScreen extends StatefulWidget {
  const BloodScreen({super.key});

  @override
  State<BloodScreen> createState() => _BloodScreenState();
}

class _BloodScreenState extends State<BloodScreen> {
  String _filterBloodGroup = 'All';

  // Base static donor registry list
  final List<Map<String, String>> _donors = [
    {'name': 'Rahul Sharma', 'group': 'O+', 'phone': '9845123456', 'status': 'Available'},
    {'name': 'Ananya Das', 'group': 'B+', 'phone': '9744112233', 'status': 'Available'},
    {'name': 'John Doe', 'group': 'A-', 'phone': '9112345678', 'status': 'Busy'},
    {'name': 'Sujith Kumar', 'group': 'B+', 'phone': '9961009121', 'status': 'Available'},
  ];

  // In-memory collection holding your newly registered live requests
  final List<Map<String, dynamic>> _urgentRequests = [];

  // Form Field text controllers
  final _hospitalController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _hospitalController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  // Opens the pop-up modal panel configured to look exactly like the mockup
  void _openUrgentRequestDialog() {
    String dialogGroupSelection = 'O+';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF6F4), // Matches prompt background layout color tint
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: const [
                  Icon(Icons.report_problem, color: Color(0xFFF44336)),
                  SizedBox(width: 10),
                  Text(
                    'Urgent Request',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Broadcast an immediate priority alert notification beacon to matching local network donors.',
                      style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
                    ),
                    const SizedBox(height: 20),

                    // Blood Group Selection Field Dropdown
                    DropdownButtonFormField<String>(
                      value: dialogGroupSelection,
                      decoration: const InputDecoration(
                        labelText: 'Blood Group Required',
                        labelStyle: TextStyle(color: Colors.redAccent, fontSize: 13),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((g) {
                        return DropdownMenuItem(value: g, child: Text(g));
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          dialogGroupSelection = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Hospital / Location Entry Box
                    TextField(
                      controller: _hospitalController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Hospital Name / Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital_outlined, size: 22),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact phone number entry box
                    TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                TextButton(
                  onPressed: () {
                    _hospitalController.clear();
                    _contactController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336), // Solid matching confirmation bright red
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (_hospitalController.text.isNotEmpty && _contactController.text.isNotEmpty) {
                      // CRITICAL FIX: Live state modification notifies the parent tree immediately
                      this.setState(() {
                        _urgentRequests.insert(0, {
                          'group': dialogGroupSelection,
                          'hospital': _hospitalController.text.trim(),
                          'phone': _contactController.text.trim(),
                        });
                      });

                      _hospitalController.clear();
                      _contactController.clear();
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Urgent $dialogGroupSelection Request Broadcasted Live!'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text('Broadcast SOS', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final filtered = _filterBloodGroup == 'All'
        ? _donors
        : _donors.where((d) => d['group'] == _filterBloodGroup).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('Blood Donors Network', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFF44336), // Title header tone
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUrgentRequestDialog,
        backgroundColor: const Color(0xFFB71C1C), // Deep Red Floating Action style
        icon: const Icon(Icons.campaign, color: Colors.white),
        label: const Text('Request Urgent Blood', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ======================================================================
          // 1. LIVE URGENT BROADCAST FEED SECTION (Visible right when added!)
          // ======================================================================
          if (_urgentRequests.isNotEmpty) ...[
            Container(
              width: double.infinity,
              color: const Color(0xFFFFEBEE), // Subtle red alert banner area block background
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE URGENT REQUESTS (${_urgentRequests.length})',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80, // Height bound constraint containing horizontal item cards safely
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _urgentRequests.length,
                      itemBuilder: (context, index) {
                        final request = _urgentRequests[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade200, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFF44336),
                                radius: 20,
                                child: Text(
                                  request['group']!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request['hospital']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Call: ${request['phone']}',
                                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 2. DROPDOWN SEARCH FILTER INTERFACE ROW
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: DropdownButtonFormField<String>(
              value: _filterBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Filter by Blood Group',
                labelStyle: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(),
              ),
              items: ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (val) => setState(() => _filterBloodGroup = val!),
            ),
          ),

          // 3. DONOR REGISTRY DIRECTORY LIST VIEW CONTAINER
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No matching registered donors found.', style: TextStyle(color: Colors.black45)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final d = filtered[index];
                final bool isAvailable = d['status'] == 'Available';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F6), // Matches visual layout container design pink/red background overlay tint
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          d['group']!,
                          style: const TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${d['phone']}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          d['status']!,
                          style: TextStyle(
                            color: isAvailable ? Colors.green.shade700 : Colors.orange.shade700,
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
          ),
        ],
      ),
    );
  }
}