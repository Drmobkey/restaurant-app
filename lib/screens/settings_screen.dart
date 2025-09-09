import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle('Tampilan'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Mode Gelap'),
                subtitle: const Text('Aktifkan tema gelap'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                },
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              );
            },
          ),
          const Divider(),
          _buildSectionTitle('Notifikasi'),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return SwitchListTile(
                title: const Text('Pengingat Harian'),
                subtitle: const Text('Notifikasi makan siang pukul 11:00'),
                value: settingsProvider.isDailyReminderEnabled,
                onChanged: (value) {
                  settingsProvider.setDailyReminder(value);
                },
                secondary: const Icon(Icons.notifications),
              );
            },
          ),
          const Divider(),
          _buildSectionTitle('Tentang'),
          ListTile(
            title: const Text('Versi Aplikasi'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}