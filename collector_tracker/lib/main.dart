import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/item_provider.dart';
import 'providers/stats_provider.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: const CollectorTrackerApp(),
    ),
  );
}

class CollectorTrackerApp extends StatelessWidget {
  const CollectorTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final router = createRouter(authProvider);

    return MaterialApp.router(
      title: 'Collector Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101416), // background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBDC2FF),
          onPrimary: Color(0xFF1B247F),
          primaryContainer: Color(0xFF1A237E),
          onPrimaryContainer: Color(0xFF8690EE),
          secondary: Color(0xFF40E56C),
          onSecondary: Color(0xFF003912),
          secondaryContainer: Color(0xFF02C953),
          onSecondaryContainer: Color(0xFF004D1B),
          tertiary: Color(0xFFCDBDFF),
          onTertiary: Color(0xFF370096),
          tertiaryContainer: Color(0xFF360094),
          onTertiaryContainer: Color(0xFFA084FF),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          background: Color(0xFF101416),
          onBackground: Color(0xFFE0E3E5),
          surface: Color(0xFF101416),
          onSurface: Color(0xFFE0E3E5),
          surfaceVariant: Color(0xFF313537),
          onSurfaceVariant: Color(0xFFC6C5D4),
          outline: Color(0xFF908F9D),
          outlineVariant: Color(0xFF454652),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.96, color: const Color(0xFFE0E3E5)),
          headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w600, color: const Color(0xFFE0E3E5)),
          headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFFE0E3E5)),
          headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFFE0E3E5)),
          titleLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFE0E3E5)),
          titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFFE0E3E5)),
          titleSmall: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFE0E3E5)),
          bodyLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: const Color(0xFFC6C5D4)),
          bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFFC6C5D4)),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.14, color: const Color(0xFFE0E3E5)),
          labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFC6C5D4)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF181C1E), // surfaceContainerLow
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF454652)), // outlineVariant
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF181C1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF454652)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF454652)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFBDC2FF), width: 2), // primary
          ),
          labelStyle: const TextStyle(color: Color(0xFFE0E3E5)),
          hintStyle: const TextStyle(color: Color(0xFF908F9D)), // outline
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E), // primaryContainer
            foregroundColor: const Color(0xFF8690EE), // onPrimaryContainer
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
