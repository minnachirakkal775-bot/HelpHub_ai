import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLang = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Language Selection'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: Column(
        children: [
          RadioListTile<String>(
            title: const Text('English', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Default system layout language'),
            value: 'en',
            groupValue: _selectedLang,
            activeColor: Colors.redAccent,
            onChanged: (val) => setState(() => _selectedLang = val!),
          ),
          RadioListTile<String>(
            title: const Text('Español (Spanish)', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Configuración en Español'),
            value: 'es',
            groupValue: _selectedLang,
            activeColor: Colors.redAccent,
            onChanged: (val) => setState(() => _selectedLang = val!),
          ),
          RadioListTile<String>(
            title: const Text('हिन्दी (Hindi)', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('हिंदी भाषा चयन करें'),
            value: 'hi',
            groupValue: _selectedLang,
            activeColor: Colors.redAccent,
            onChanged: (val) => setState(() => _selectedLang = val!),
          ),
        ],
      ),
    );
  }
}