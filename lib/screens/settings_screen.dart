import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support Service'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact us at:'),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.email, size: 16),
              SizedBox(width: 8),
              Text('support@workly.com')
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.phone, size: 16),
              SizedBox(width: 8),
              Text('+1 555 123 4567')
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: ['English', 'Русский'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedLanguage = newValue);
                }
              },
            ),
          ),
          const Divider(),

          // Theme
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeManager(),
              builder: (context, mode, _) {
                String text = 'System';
                if (mode == ThemeMode.light) text = 'Light';
                if (mode == ThemeMode.dark) text = 'Dark';
                return Text(text);
              },
            ),
            trailing: PopupMenuButton<ThemeMode>(
              onSelected: (mode) {
                ThemeManager().setThemeMode(mode);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                const PopupMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                const PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Support
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Support Service'),
            onTap: _showSupportDialog,
          ),
          const Divider(),

          // Logout
          Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
