import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'bootstrap/app_startup.dart';
import 'core/l10n/app_locale.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/network_guard.dart';
import 'features/splash/splash_screen.dart';
import 'services/api_client.dart';
import 'services/api_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

  await prepareAppBeforeFirstFrame();
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
