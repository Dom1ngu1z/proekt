import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_history_provider.dart';
import 'providers/social_provider.dart';
import 'repositories/supabase_auth_repository.dart';
import 'repositories/supabase_social_repository.dart';
import 'views/setup_required_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4))),
        home: const SetupRequiredView(),
      );
    }

    SupabaseClient? client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4))),
        home: const SetupRequiredView(),
      );
    }

    final authRepository = SupabaseAuthRepository(client);
    final socialRepository = SupabaseSocialRepository(client);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider<SocialProvider>(
          create: (_) => SocialProvider(socialRepository),
        ),
        ChangeNotifierProvider<NavigationHistoryProvider>(
          create: (_) => NavigationHistoryProvider(),
        ),
      ],
      child: const AppBootstrap(),
    );
  }
}
