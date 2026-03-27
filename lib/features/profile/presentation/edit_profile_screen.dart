import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/models/calendar_display_mode.dart';
import '../../../core/providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _didSeed = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).asData?.value;
    final profileState = ref.watch(accountProfileControllerProvider);
    final currentCalendarMode =
        session?.preferences?.calendarDisplayMode ??
        CalendarDisplayMode.ethiopian;

    if (!_didSeed && session?.isSignedIn == true) {
      _didSeed = true;
      _displayNameController.text = session!.user?.displayName ?? '';
    }

    if (session?.isSignedIn != true) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(
          child: Text('You need to sign in before editing your profile.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(labelText: 'Display name'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Enter a display name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: profileState.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          final didSave = await ref
                              .read(accountProfileControllerProvider.notifier)
                              .updateProfile(
                                displayName: _displayNameController.text.trim(),
                                calendarDisplayMode: currentCalendarMode,
                              );
                          if (didSave && context.mounted) {
                            context.go(RoutePaths.profilePath());
                          }
                        },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
          if (profileState.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              profileState.errorMessage!,
              style: const TextStyle(color: Color(0xFFB00020)),
            ),
          ],
        ],
      ),
    );
  }
}
