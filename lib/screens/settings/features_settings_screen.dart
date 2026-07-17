import 'package:flutter/material.dart';

class FeaturesSettingsScreen extends StatefulWidget {
  const FeaturesSettingsScreen({super.key});

  @override
  State<FeaturesSettingsScreen> createState() => _FeaturesSettingsScreenState();
}

class _FeaturesSettingsScreenState extends State<FeaturesSettingsScreen> {
  bool _shakeSOS = true;
  bool _voiceWake = true;
  bool _bgTracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Controls'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Shake Phone to SOS', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Vigorously shaking the device initializes alerts.'),
            value: _shakeSOS,
            activeColor: Colors.white,
            activeTrackColor: Colors.redAccent,
            onChanged: (val) => setState(() => _shakeSOS = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('AI Voice Wake Word Activation', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Monitors background audio for phrase \'Help Hub Emergency\'.'),
            value: _voiceWake,
            activeColor: Colors.white,
            activeTrackColor: Colors.redAccent,
            onChanged: (val) => setState(() => _voiceWake = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Persistent Background Tracking', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Provides telemetry safety services continuously when app is hidden.'),
            value: _bgTracking,
            activeColor: Colors.white,
            activeTrackColor: Colors.redAccent,
            onChanged: (val) => setState(() => _bgTracking = val),
          ),
        ],
      ),
    );
  }
}