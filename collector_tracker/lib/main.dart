import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

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

class CollectorTrackerApp extends StatefulWidget {
  const CollectorTrackerApp({super.key});

  @override
  State<CollectorTrackerApp> createState() => _CollectorTrackerAppState();
}

class _CollectorTrackerAppState extends State<CollectorTrackerApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    _router ??= createRouter(context.read<AuthProvider>());

    return MaterialApp.router(
      title: 'Collectiv',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF1E3A5F),
          onPrimaryContainer: Color(0xFFD4E4FF),
          secondary: Color(0xFF8B5CF6),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFF2D1F5E),
          onSecondaryContainer: Color(0xFFE8DDFF),
          tertiary: Color(0xFF10B981),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFF0A3D2A),
          onTertiaryContainer: Color(0xFFA7F3D0),
          error: Color(0xFFEF4444),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFF450A0A),
          onErrorContainer: Color(0xFFFECACA),
          surface: Color(0xFF09090B),
          onSurface: Color(0xFFF4F4F5),
          surfaceContainerHighest: Color(0xFF18181B),
          onSurfaceVariant: Color(0xFFA1A1AA),
          outline: Color(0xFF27272A),
          outlineVariant: Color(0xFF18181B),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            color: const Color(0xFFF4F4F5),
          ),
          displayMedium: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: const Color(0xFFF4F4F5),
          ),
          displaySmall: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: const Color(0xFFF4F4F5),
          ),
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF4F4F5),
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF4F4F5),
          ),
          headlineSmall: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF4F4F5),
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF4F4F5),
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF4F4F5),
          ),
          titleSmall: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF4F4F5),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA1A1AA),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA1A1AA),
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: const Color(0xFFF4F4F5),
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: const Color(0xFFA1A1AA),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF18181B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF27272A)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF18181B),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF27272A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF27272A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
          ),
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFFA1A1AA),
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF52525B),
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF18181B),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF27272A)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF27272A),
          contentTextStyle: GoogleFonts.inter(
            color: const Color(0xFFF4F4F5),
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF27272A),
          thickness: 1,
        ),
      ),
      routerConfig: _router!,
    );
  }
}
