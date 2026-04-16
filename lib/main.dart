import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_learn/core/providers/auth_provider.dart';
import 'package:interactive_learn/core/providers/theme_provider.dart';
import 'package:interactive_learn/core/singleton.dart';
import 'package:interactive_learn/screens/auth/login.dart';
import 'package:interactive_learn/screens/tab_widget_tree.dart';
import 'package:interactive_learn/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intern Learn',
      theme: MainAppTheme.light,
      darkTheme: MainAppTheme.dark,
      themeMode: theme,
      home: const AuthGate(),
    );
  }
}

/// The `AuthGate` class is a Flutter widget that conditionally displays either a `TabWidgetTree` or a
/// `LoginPage` based on the authentication state, handling data loading and error cases.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    return authAsync.when(
      data: (state) {
        if (state.session != null) return const TabWidgetTree();
        return const LoginPage();
      },
      loading: () {
        // Use synchronous session to avoid a white flash on re-launch
        if (supabase.auth.currentSession != null) return const TabWidgetTree();
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (_, _) => const LoginPage(),
    );
  }
}
