import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apni Zaroorat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColor),
          primary: const Color(AppConstants.primaryColor),
          secondary: const Color(AppConstants.accentColor),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(AppConstants.mainBackground),
        fontFamily: 'Arial',
        textTheme: ThemeData().textTheme.apply(fontFamily: 'Arial'),
      ),
      home: const SplashScreen(),
    );
  }
}
