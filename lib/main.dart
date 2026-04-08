import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'config/app_assets.dart';
import 'core/l10n/app_locale.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/network_guard.dart';
import 'features/splash/splash_screen.dart';
import 'services/api_client.dart';
import 'services/api_service.dart';
import 'services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  // Warm the splash animation in [sharedLottieCache] so the first Flutter frame
  // does not wait on asset read + JSON parse (that delay looked like a late Lottie).
  await AssetLottie(AppAssets.rupeesLottie).load();
  // Do not await: phone auth still calls [FirebaseBootstrap.ensureInitialized] before use.
  unawaited(FirebaseBootstrap.ensureInitialized());
  runAppWithApi(ApiService.instance);
}

void runAppWithApi(ApiClient api) {
  runApp(
    MultiProvider(
      providers: createAppProviders(api),
      child: const AzMaterialApp(),
    ),
  );
}

class AzMaterialApp extends StatelessWidget {
  const AzMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLocale>(
      builder: (_, appLocale, _) {
        // NetworkGuard must wrap MaterialApp, not MaterialApp.builder's child — when
        // [child] is null the route (splash) never mounts and only the native blue window shows.
        return NetworkGuard(
          child: MaterialApp(
            title: appLocale.t('appName'),
            debugShowCheckedModeBanner: false,
            locale: Locale(appLocale.locale),
            theme: AppTheme.materialTheme(),
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
