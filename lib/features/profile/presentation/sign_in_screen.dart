import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/calendar_preferences_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionsControllerProvider);
    final calendarMode = ref.watch(calendarDisplayModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
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
                FilledButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          final didSignIn = await ref
                              .read(authActionsControllerProvider.notifier)
                              .signInWithEmail(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                fallbackMode: calendarMode,
                              );
                          if (didSignIn && context.mounted) {
                            context.go(RoutePaths.profilePath());
                          }
                        },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          final didSignIn = await ref
                              .read(authActionsControllerProvider.notifier)
                              .signInWithGoogle(fallbackMode: calendarMode);
                          if (didSignIn && context.mounted) {
                            context.go(RoutePaths.profilePath());
                          }
                        },
                  icon: const Icon(Icons.login),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      context.push(RoutePaths.profileForgotPasswordPath()),
                  child: const Text('Forgot password?'),
                ),
                TextButton(
                  onPressed: () => context.push(RoutePaths.profileSignUpPath()),
                  child: const Text('Need an account? Sign up'),
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
