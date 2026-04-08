import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/app_locale.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/network_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = kDebugMode;
  // Ensure system UI (status/navigation bars) stay visible to avoid layout jumps
  // when platform sheets (e.g., share sheet) appear/disappear.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: const [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AppBootstrapper());
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 4));
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupLoadingScreen();
        }
        return const MyApp();
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppTheme.primaryBlueDark,
        body: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLocale>(
      create: (_) => AppLocale(),
      child: Consumer<AppLocale>(
        builder: (_, appLocale, child) {
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
