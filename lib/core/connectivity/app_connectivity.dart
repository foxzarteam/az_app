import 'package:flutter/foundation.dart';

/// App-wide online/offline signal (updated by [NetworkGuard]).
class AppConnectivity extends ChangeNotifier {
  bool isOnline = true;

  void reportOffline() {
    if (!isOnline) return;
    isOnline = false;
    notifyListeners();
  }

  void reportOnline() {
    if (isOnline) return;
    isOnline = true;
    notifyListeners();
  }
}
