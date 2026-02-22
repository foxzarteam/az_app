import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final inter = GoogleFonts.interTextTheme();
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColor),
          primary: const Color(AppConstants.primaryColor),
          secondary: const Color(AppConstants.accentColor),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(AppConstants.mainBackground),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: inter.apply(
          bodyColor: AppTheme.primaryText,
          displayColor: AppTheme.primaryText,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
