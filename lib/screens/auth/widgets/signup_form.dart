import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/services/auth_service.dart';
import 'package:interactive_learn/core/singleton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupForm extends HookConsumerWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final emailController = useTextEditingController();
    final nameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final successMessage = useState<String?>(null);
    final obscurePassword = useState(true);

    Future<void> handleSignup() async {
      if (!formKey.currentState!.validate()) return;

      final email = emailController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      isLoading.value = true;
      errorMessage.value = null;
      successMessage.value = null;

      try {
        await AuthService.signUp(
          AccountFilledDetails(
            name: name,
            email: email,
            password: password,
          ),
        );

        successMessage.value =
            'Account created! Login To Continue.';
      } on AuthException catch (e) {
        errorMessage.value = e.message;
      } catch (e) {
        errorMessage.value = 'Something went wrong.';
        logger.e('Signup error', error: e);
      } finally {
        isLoading.value = false;
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          /// EMAIL
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email required';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Invalid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          /// NAME
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name required';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          /// PASSWORD
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword.value,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    obscurePassword.value = !obscurePassword.value,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password required';
              }
              if (value.length < 6) {
                return 'Minimum 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          /// CONFIRM PASSWORD
          TextFormField(
            controller: confirmPasswordController,
            obscureText: obscurePassword.value,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => handleSignup(),
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (value) {
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          if (errorMessage.value != null) ...[
            const SizedBox(height: 10),
            Text(
              errorMessage.value!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],

          if (successMessage.value != null) ...[
            const SizedBox(height: 10),
            Text(
              successMessage.value!,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading.value ? null : handleSignup,
              child: isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}