import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/profile/profile_settings.dart';
import '../../../core/providers/profile_settings_providers.dart';
import '../../../core/providers/calendar_preferences_provider.dart';

class ProfilePreferencesScreen extends ConsumerStatefulWidget {
  const ProfilePreferencesScreen({super.key});

  @override
  ConsumerState<ProfilePreferencesScreen> createState() =>
      _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState
    extends ConsumerState<ProfilePreferencesScreen> {
  CalendarDisplayMode? _calendarDisplayMode;
  FeastCalculationMode? _feastCalculationMode;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('App Preferences')),
      body: settingsAsync.when(
        data: (settings) {
          _calendarDisplayMode ??= settings.calendarDisplayMode;
          _feastCalculationMode ??= settings.feastCalculationMode;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Choose how the calendar opens by default and which calendar system to use for feast calculations.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<CalendarDisplayMode>(
                initialValue: _calendarDisplayMode,
                decoration: const InputDecoration(
                  labelText: 'Default calendar display',
                ),
                items: const [
                  DropdownMenuItem(
                    value: CalendarDisplayMode.ethiopian,
                    child: Text('Ethiopian calendar'),
                  ),
                  DropdownMenuItem(
                    value: CalendarDisplayMode.gregorian,
                    child: Text('Gregorian calendar'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _calendarDisplayMode = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FeastCalculationMode>(
                initialValue: _feastCalculationMode,
                decoration: const InputDecoration(
                  labelText: 'Feast calculation calendar',
                ),
                items: const [
                  DropdownMenuItem(
                    value: FeastCalculationMode.ethiopian,
                    child: Text('Ethiopian calendar'),
                  ),
                  DropdownMenuItem(
                    value: FeastCalculationMode.gregorian,
                    child: Text('Gregorian calendar'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _feastCalculationMode = value),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed:
                    _calendarDisplayMode == null ||
                        _feastCalculationMode == null
                    ? null
                    : () async {
                        await ref
                            .read(appPreferencesProvider.notifier)
                            .save(
                              AppPreferencesSettings(
                                calendarDisplayMode: _calendarDisplayMode!,
                                feastCalculationMode: _feastCalculationMode!,
                              ),
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('App preferences updated'),
                            ),
                          );
                        }
                      },
                child: const Text('Save Preferences'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load: $error')),
      ),
    );
  }
}
