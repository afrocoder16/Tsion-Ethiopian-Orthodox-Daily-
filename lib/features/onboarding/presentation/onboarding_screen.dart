import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/auth/sign_in_guard.dart';
import '../../../core/onboarding/onboarding_schedule.dart';
import '../../../core/providers/onboarding_providers.dart';
import '../../../core/strings/app_strings.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  OnboardingPrayerPreset _preset = OnboardingPrayerPreset.fourTime;
  List<OnboardingPrayerSlot> _customSlots = List<OnboardingPrayerSlot>.from(
    fourTimePrayerPreset,
  );
  bool _checking = true;
  bool _saving = false;
  bool _showSignInPrompt = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfComplete());
  }

  Future<void> _redirectIfComplete() async {
    final complete = await ref.read(onboardingRepositoryProvider).isComplete();
    if (!mounted) {
      return;
    }
    if (complete) {
      context.go(RoutePaths.today);
      return;
    }
    setState(() => _checking = false);
  }

  Future<void> _completeOnboarding() async {
    setState(() => _saving = true);
    final slots = slotsForPreset(_preset, customSlots: _customSlots);
    await ref.read(onboardingRepositoryProvider).complete(slots);
    ref.invalidate(onboardingCompleteProvider);
    if (mounted) {
      context.go(RoutePaths.today);
    }
  }

  void _updateCustomSlot(OnboardingPrayerSlot slot) {
    setState(() {
      _customSlots = _customSlots
          .map((existing) => existing.slotId == slot.slotId ? slot : existing)
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              AppStrings.onboardingTitle,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.onboardingSubtitle,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 18),
            _PresetTile(
              title: AppStrings.onboardingFourTime,
              description: AppStrings.onboardingFourTimeDescription,
              selected: _preset == OnboardingPrayerPreset.fourTime,
              onTap: () {
                setState(() => _preset = OnboardingPrayerPreset.fourTime);
              },
            ),
            _PresetTile(
              title: AppStrings.onboardingSevenTime,
              description: AppStrings.onboardingSevenTimeDescription,
              selected: _preset == OnboardingPrayerPreset.sevenTime,
              onTap: () {
                setState(() => _preset = OnboardingPrayerPreset.sevenTime);
              },
            ),
            _PresetTile(
              title: AppStrings.onboardingCustom,
              description: AppStrings.onboardingCustomDescription,
              selected: _preset == OnboardingPrayerPreset.custom,
              onTap: () {
                setState(() => _preset = OnboardingPrayerPreset.custom);
              },
            ),
            if (_preset == OnboardingPrayerPreset.custom) ...[
              const SizedBox(height: 10),
              ..._customSlots.map(
                (slot) =>
                    _CustomSlotTile(slot: slot, onChanged: _updateCustomSlot),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              AppStrings.onboardingNotificationNote,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            if (_showSignInPrompt) ...[
              const SizedBox(height: 18),
              const Text(
                AppStrings.onboardingOptionalSignIn,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SignInUnlockPrompt(
                feature: SignInFeature.profile,
                onSignIn: () => context.push(RoutePaths.profileSignInPath()),
                onNotNow: () => setState(() => _showSignInPrompt = false),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _completeOnboarding,
              child: Text(
                _saving
                    ? AppStrings.onboardingContinue
                    : AppStrings.onboardingComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF6F3EE) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFB79C5E) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSlotTile extends StatelessWidget {
  const _CustomSlotTile({required this.slot, required this.onChanged});

  final OnboardingPrayerSlot slot;
  final ValueChanged<OnboardingPrayerSlot> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(slot.label),
      subtitle: Text(slot.timeLocal),
      leading: Switch(
        value: slot.isEnabled,
        onChanged: (value) => onChanged(slot.copyWith(isEnabled: value)),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.schedule),
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: _parseTime(slot.timeLocal),
          );
          if (picked == null) {
            return;
          }
          onChanged(slot.copyWith(timeLocal: _serializeTime(picked)));
        },
      ),
    );
  }
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    return const TimeOfDay(hour: 6, minute: 0);
  }
  return TimeOfDay(
    hour: int.tryParse(parts[0]) ?? 6,
    minute: int.tryParse(parts[1]) ?? 0,
  );
}

String _serializeTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
