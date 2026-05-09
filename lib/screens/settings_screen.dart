import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';
import '../theme/language_manager.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _showSupportDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.supportContact),
            const SizedBox(height: 8),
            const Row(children: [
              Icon(Icons.email, size: 16),
              SizedBox(width: 8),
              Text('support@workly.com')
            ]),
            const SizedBox(height: 8),
            const Row(children: [
              Icon(Icons.phone, size: 16),
              SizedBox(width: 8),
              Text('+1 555 123 4567')
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.closeButton),
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Language
          ValueListenableBuilder<Locale>(
            valueListenable: LanguageManager(),
            builder: (context, locale, _) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.languageLabel),
                trailing: DropdownButton<String>(
                  value: locale.languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      LanguageManager().setLocale(Locale(newValue));
                    }
                  },
                ),
              );
            },
          ),
          const Divider(),

          // Theme
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.themeLabel),
            subtitle: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeManager(),
              builder: (context, mode, _) {
                String text = l10n.themeSystem;
                if (mode == ThemeMode.light) text = l10n.themeLight;
                if (mode == ThemeMode.dark) text = l10n.themeDark;
                return Text(text);
              },
            ),
            trailing: PopupMenuButton<ThemeMode>(
              onSelected: (mode) {
                ThemeManager().setThemeMode(mode);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.themeSystem),
                ),
                PopupMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.themeLight),
                ),
                PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
          const Divider(),

          // Support
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.supportLabel),
            onTap: _showSupportDialog,
          ),
          const Divider(),

          // Logout
          Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(l10n.logoutButton),
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
