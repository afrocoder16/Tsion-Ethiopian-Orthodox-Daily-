import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/navigation_back.dart';
import '../../../app/route_paths.dart';
import '../../../core/strings/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => popOrGo(context, RoutePaths.today),
        ),
        title: const Text(AppStrings.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            AppStrings.settingsIntroduction,
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.tune,
            title: AppStrings.settingsPreferencesTitle,
            subtitle: AppStrings.settingsPreferencesDescription,
            onTap: () => context.push(RoutePaths.settingsPreferencesPath()),
          ),
          _SettingsTile(
            icon: Icons.schedule,
            title: AppStrings.settingsPrayerRemindersTitle,
            subtitle: AppStrings.settingsPrayerRemindersDescription,
            onTap: () => context.push(RoutePaths.settingsPrayerRemindersPath()),
          ),
          _SettingsTile(
            icon: Icons.notifications_none,
            title: AppStrings.settingsNotificationsTitle,
            subtitle: AppStrings.settingsNotificationsDescription,
            onTap: () => context.push(RoutePaths.settingsNotificationsPath()),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3E3E3)),
            ),
            child: const Text(
              AppStrings.settingsLocalDataNote,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
