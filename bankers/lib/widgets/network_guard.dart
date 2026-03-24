import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';

/// Wraps the whole app so offline UI stays on top after any navigation.
class NetworkGuard extends StatefulWidget {
  const NetworkGuard({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkGuard> createState() => _NetworkGuardState();
}

class _NetworkGuardState extends State<NetworkGuard> {
  /// Wait this long before showing the offline UI so startup / flaky checks
  /// do not flash the dialog when the connection is actually fine.
  static const Duration _offlineShowDelay = Duration(milliseconds: 1200);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool _isChecking = false;
  int _checkSeq = 0;

  Timer? _offlineDebounceTimer;
  int _offlineDebounceGen = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_connectivity.checkConnectivity().then(_applyConnectivity));
    _subscription =
        _connectivity.onConnectivityChanged.listen(_applyConnectivity);
  }

  @override
  void dispose() {
    _offlineDebounceTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _scheduleOfflineOverlay() {
    if (!_isConnected) return;
    _offlineDebounceTimer?.cancel();
    final gen = ++_offlineDebounceGen;
    _offlineDebounceTimer = Timer(_offlineShowDelay, () {
      _offlineDebounceTimer = null;
      if (!mounted) return;
      if (gen != _offlineDebounceGen) return;
      setState(() {
        _isConnected = false;
        _isChecking = false;
      });
    });
  }

  void _cancelOfflineOverlaySchedule({bool updateUi = true}) {
    _offlineDebounceTimer?.cancel();
    _offlineDebounceTimer = null;
    _offlineDebounceGen++;
    if (updateUi && mounted) {
      setState(() {
        _isConnected = true;
        _isChecking = false;
      });
    }
  }

  bool _isLinkDown(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  /// Link down / ping fail → debounced offline UI. Link up + ping ok → online immediately.
  Future<void> _applyConnectivity(List<ConnectivityResult> results) async {
    final seq = ++_checkSeq;

    if (_isLinkDown(results)) {
      if (mounted) setState(() => _isChecking = false);
      _scheduleOfflineOverlay();
      return;
    }

    if (mounted) {
      setState(() => _isChecking = true);
    }

    final hasInternet = await _pingInternet();
    if (!mounted || seq != _checkSeq) return;

    if (hasInternet) {
      _cancelOfflineOverlaySchedule();
    } else {
      if (mounted) setState(() => _isChecking = false);
      _scheduleOfflineOverlay();
    }
  }

  Future<bool> _pingInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 204 ||
          (response.statusCode >= 200 && response.statusCode < 400);
    } catch (_) {
      return false;
    }
  }

  Future<void> _retry() async {
    final seq = ++_checkSeq;
    if (mounted) setState(() => _isChecking = true);

    final results = await _connectivity.checkConnectivity();
    if (!mounted || seq != _checkSeq) return;

    if (_isLinkDown(results)) {
      if (mounted) setState(() => _isChecking = false);
      _scheduleOfflineOverlay();
      return;
    }

    final hasInternet = await _pingInternet();
    if (!mounted || seq != _checkSeq) return;

    if (hasInternet) {
      _cancelOfflineOverlaySchedule();
    } else {
      if (mounted) setState(() => _isChecking = false);
      _scheduleOfflineOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Above [MaterialApp], so no ambient [Directionality] yet — [Stack] defaults need it.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topLeft,
        children: [
          PopScope(
            canPop: _isConnected,
            child: AbsorbPointer(
              absorbing: !_isConnected,
              child: widget.child,
            ),
          ),
          if (!_isConnected)
            _OfflineBlocker(onRetry: _retry, isChecking: _isChecking),
        ],
      ),
    );
  }
}

class _OfflineBlocker extends StatelessWidget {
  const _OfflineBlocker({
    required this.onRetry,
    required this.isChecking,
  });

  final VoidCallback onRetry;
  final bool isChecking;

  @override
  Widget build(BuildContext context) {
    // [NetworkGuard] sits above [MaterialApp], so no inherited app [Theme] here.
    final overlayTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryBlue,
        brightness: Brightness.light,
      ),
    );

    return Theme(
      data: overlayTheme,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            const ModalBarrier(
              dismissible: false,
              color: Color(0x99000000),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2F2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD6D6),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 40,
                          color: AppTheme.error,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Something went wrong',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryText,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No internet connection. Check your network and try again.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.secondaryText,
                            ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isChecking ? null : onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Try again'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
