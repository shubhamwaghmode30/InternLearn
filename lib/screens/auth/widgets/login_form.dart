import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/services/auth_service.dart';
import 'package:interactive_learn/core/singleton.dart';
import 'package:interactive_learn/screens/auth/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final obscurePassword = useState(true);

    Future<void> handleLogin() async {
      if (!formKey.currentState!.validate()) return;

      final email = emailController.text.trim();
      final password = passwordController.text;

      isLoading.value = true;
      errorMessage.value = null;

      try {
        await AuthService.login(email, password);
      } on AuthException catch (e) {
        errorMessage.value = e.message;
      } catch (e) {
        errorMessage.value = 'Something went wrong.';
        logger.e('Login error', error: e);
      } finally {
        isLoading.value = false;
      }
    }

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back',
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

          /// PASSWORD
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword.value,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => handleLogin(),
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

          const SizedBox(height: 20),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading.value ? null : handleLogin,
              child: isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupPage(),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}