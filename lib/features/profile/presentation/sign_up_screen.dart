import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/models/calendar_display_mode.dart';
import '../../../core/providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

String? _validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty || !trimmed.contains('@')) {
    return 'Enter a valid email.';
  }
  return null;
}

String? _validatePassword(String? value) {
  if ((value ?? '').length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  CalendarDisplayMode _mode = CalendarDisplayMode.ethiopian;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CalendarDisplayMode>(
                  initialValue: _mode,
                  decoration: const InputDecoration(
                    labelText: 'Calendar display mode',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: CalendarDisplayMode.ethiopian,
                      child: Text('Ethiopian'),
                    ),
                    DropdownMenuItem(
                      value: CalendarDisplayMode.gregorian,
                      child: Text('Gregorian'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _mode = value);
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          final didSignUp = await ref
                              .read(authActionsControllerProvider.notifier)
                              .signUpWithEmail(
                                displayName: _displayNameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                calendarDisplayMode: _mode,
                              );
                          if (didSignUp && context.mounted) {
                            context.go(RoutePaths.profilePath());
                          }
                        },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              authState.errorMessage!,
              style: const TextStyle(color: Color(0xFFB00020)),
            ),
          ],
        ],
      ),
    );
  }
}
