import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connectivity/app_connectivity.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../../services/network_reachability_service.dart';

/// Full-screen offline blocker when there is no real internet.
class NetworkGuard extends StatefulWidget {
  const NetworkGuard({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkGuard> createState() => _NetworkGuardState();
}

class _NetworkGuardState extends State<NetworkGuard>
    with WidgetsBindingObserver {
  /// Brief debounce only for “Wi‑Fi on but no internet” to avoid one flaky ping flash.
  static const Duration _probeFailDebounce = Duration(milliseconds: 350);

  /// Wait before hiding modal after internet is back (reduces flicker).
  static const Duration _onlineHideDelay = Duration(milliseconds: 600);

  static const Duration _periodicCheckInterval = Duration(seconds: 4);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicTimer;
  Timer? _offlineDebounceTimer;
  Timer? _onlineHideTimer;
  int _offlineDebounceGen = 0;
  int _checkSeq = 0;

  bool _isConnected = true;
  bool _isChecking = false;
  bool _foreground = true;

  AppConnectivity? _appConnectivity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapMonitoring());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appConnectivity ??= context.read<AppConnectivity>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      unawaited(_runConnectivityCheck());
      _startPeriodicCheck();
    } else {
      _stopPeriodicCheck();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _offlineDebounceTimer?.cancel();
    _onlineHideTimer?.cancel();
    _stopPeriodicCheck();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _bootstrapMonitoring() async {
    if (!mounted) return;
    await _runConnectivityCheck();
    _subscription ??=
        _connectivity.onConnectivityChanged.listen((results) {
      unawaited(_applyConnectivity(results));
    });
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    if (!_foreground) return;
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_periodicCheckInterval, (_) {
      if (!_foreground || !mounted) return;
      unawaited(_runConnectivityCheck());
    });
  }

  void _stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<void> _runConnectivityCheck() async {
    final results = await _connectivity.checkConnectivity();
    if (!mounted) return;
    await _applyConnectivity(results);
  }

  bool _isLinkDown(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  void _showOfflineNow() {
    if (!_isConnected) return;
    _onlineHideTimer?.cancel();
    _offlineDebounceTimer?.cancel();
    _offlineDebounceGen++;
    if (!mounted) return;
    setState(() {
      _isConnected = false;
      _isChecking = false;
    });
    _appConnectivity?.reportOffline();
  }

  void _scheduleOfflineAfterProbeFail() {
    if (!_isConnected) return;
    _onlineHideTimer?.cancel();
    _offlineDebounceTimer?.cancel();
    final gen = ++_offlineDebounceGen;
    _offlineDebounceTimer = Timer(_probeFailDebounce, () {
      _offlineDebounceTimer = null;
      if (!mounted || gen != _offlineDebounceGen) return;
      _showOfflineNow();
    });
  }

  void _scheduleOnlineHide() {
    _offlineDebounceTimer?.cancel();
    _offlineDebounceGen++;
    _onlineHideTimer?.cancel();
    _onlineHideTimer = Timer(_onlineHideDelay, () {
      _onlineHideTimer = null;
      if (!mounted) return;
      setState(() {
        _isConnected = true;
        _isChecking = false;
      });
      _appConnectivity?.reportOnline();
    });
  }

  Future<void> _applyConnectivity(List<ConnectivityResult> results) async {
    final seq = ++_checkSeq;

    if (_isLinkDown(results)) {
      _showOfflineNow();
      return;
    }

    if (mounted) setState(() => _isChecking = true);

    final hasInternet =
        await NetworkReachabilityService.instance.hasInternet();
    if (!mounted || seq != _checkSeq) return;

    if (hasInternet) {
      if (!_isConnected) {
        _scheduleOnlineHide();
      } else {
        if (mounted) setState(() => _isChecking = false);
      }
    } else {
      if (_isConnected) {
        _scheduleOfflineAfterProbeFail();
      } else if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _retry() async {
    final seq = ++_checkSeq;
    if (mounted) setState(() => _isChecking = true);

    final results = await _connectivity.checkConnectivity();
    if (!mounted || seq != _checkSeq) return;

    if (_isLinkDown(results)) {
      _showOfflineNow();
      return;
    }

    final hasInternet =
        await NetworkReachabilityService.instance.hasInternet();
    if (!mounted || seq != _checkSeq) return;

    if (hasInternet) {
      _offlineDebounceTimer?.cancel();
      _offlineDebounceGen++;
      _onlineHideTimer?.cancel();
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isChecking = false;
        });
      }
      _appConnectivity?.reportOnline();
    } else {
      _showOfflineNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
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
                        AppConstants.networkOfflineTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryText,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.networkOfflineBody,
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
                              : const Text(AppConstants.networkTryAgain),
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
