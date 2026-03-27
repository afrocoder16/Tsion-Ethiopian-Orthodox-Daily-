import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

String? _validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty || !trimmed.contains('@')) {
    return 'Enter a valid email.';
  }
  return null;
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authActionsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Enter your email and we will send a password reset link.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: _validateEmail,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: authState.isLoading
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final didSend = await ref
                        .read(authActionsControllerProvider.notifier)
                        .sendPasswordResetEmail(_emailController.text.trim());
                    if (!didSend || !context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent'),
                      ),
                    );
                  },
            child: const Text('Send Reset Email'),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              authState.errorMessage!,
              style: const TextStyle(color: Color(0xFFB00020)),
            ),
          ],
          if (authState.successMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              authState.successMessage!,
              style: const TextStyle(color: Color(0xFF1B5E20)),
            ),
          ],
        ],
      ),
    );
  }
}
