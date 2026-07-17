import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyMessagesScreen extends StatefulWidget {
  const EmergencyMessagesScreen({super.key});

  @override
  State<EmergencyMessagesScreen> createState() => _EmergencyMessagesScreenState();
}

class _EmergencyMessagesScreenState extends State<EmergencyMessagesScreen> {
  static const String _storageKey = 'saved_sos_sms_template';
  late final TextEditingController _msgController;
  bool _isLoading = true;

  // Baseline fallback template string seen in image_53e4ea.png
  final String _defaultTemplate =
      "EMERGENCY! I need immediate help. HelpHub AI has registered my distress. "
      "My dynamic location tracker details will follow shortly.";

  @override
  void initState() {
    super.initState();
    _msgController = TextEditingController();
    _loadSavedTemplate();
  }

  // Reads the custom template out of device cache memory
  Future<void> _loadSavedTemplate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String savedText = prefs.getString(_storageKey) ?? _defaultTemplate;

      setState(() {
        _msgController.text = savedText;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load message string data: $e");
      setState(() {
        _msgController.text = _defaultTemplate;
        _isLoading = false;
      });
    }
  }

  // Writes customized values back down to system cache keys
  Future<void> _saveTemplate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, _msgController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS Template Updated.'), // Custom snackbar notification
            backgroundColor: Color(0xFF322F2E),
          ),
        );
      }
    } catch (e) {
      debugPrint("Failed to save background message data: $e");
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        title: const Text('SOS Message Templates', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.redAccent, // Red identity layout banner from image_53e4ea.png
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent)))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Dispatch SMS Text',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            const Text(
              'This message will instantly send out to all contacts when you trigger an SOS step.',
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Primary Multi-line Input Box Element Container
            TextField(
              controller: _msgController,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black26), // Fixed: compiler bug resolved here
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              style: const TextStyle(height: 1.4, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Warning Alert Badge Container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF0C7), // Amber yellow background card
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.location_on, color: Colors.orange, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Note: GPS coordinates are appended automatically to the end of your custom text package.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB54708), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Bottom Docked Update Button Panel
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Rounded button capsule
                  ),
                  onPressed: _saveTemplate,
                  child: const Text(
                    'Update Template',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}