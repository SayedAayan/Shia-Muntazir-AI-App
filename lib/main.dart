import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file could not be loaded: $e');
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MuntazirApp()));
}

class MuntazirApp extends ConsumerWidget {
  const MuntazirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return MaterialApp.router(
      title: 'Muntazir',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ur'), // Urdu
        Locale('hi'), // Hindi
        Locale('gu'), // Gujarati
      ],
      builder: (context, child) {
        // Global font scaling as required by accessibility specification
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(fontScale),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: const Color(0xFF1B2A3D),
        primary: const Color(0xFF1B2A3D),
        secondary: const Color(0xFFC27351), // Warm Terracotta
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFFBF9F4), // Warm Ivory Linen
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFBF9F4),
        elevation: 0,
        foregroundColor: Color(0xFF1B2A3D),
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF1B2A3D),
        primary: Colors.white,
        secondary: const Color(0xFFC27351), // Warm Terracotta
        surface: const Color(0xFF17202C), // Deep Navy Slate Card
      ),
      scaffoldBackgroundColor: const Color(0xFF10161E), // Dark Obsidian Slate
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF10161E),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }
}
