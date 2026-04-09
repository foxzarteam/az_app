import 'package:lottie/lottie.dart';

import '../config/app_assets.dart';
import '../services/firebase_bootstrap.dart';

/// Heavy work before [runApp] while the native splash is preserved.
Future<void> prepareAppBeforeFirstFrame() async {
  await Future.wait<void>([
    AssetLottie(AppAssets.rupeesLottie).load(),
    FirebaseBootstrap.ensureInitialized(),
  ]);
}
