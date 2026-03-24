import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/app_locale.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/network_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLocale>(
      create: (_) => AppLocale(),
      child: Consumer<AppLocale>(
        builder: (_, appLocale, __) {
          final inter = GoogleFonts.interTextTheme();
          return NetworkGuard(
            child: MaterialApp(
              title: appLocale.t('appName'),
              debugShowCheckedModeBanner: false,
              locale: Locale(appLocale.locale),
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppTheme.primaryBlue,
                  primary: AppTheme.primaryBlue,
                  secondary: AppTheme.accentOrange,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: AppTheme.mainBackground,
                fontFamily: GoogleFonts.inter().fontFamily,
                textTheme: inter.apply(
                  bodyColor: AppTheme.primaryText,
                  displayColor: AppTheme.primaryText,
                ),
              ),
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
