import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../../core/connectivity/app_connectivity.dart';
import '../../models/active_service.dart';
import '../../services/services_local_cache.dart';
import '../../services/services_service.dart';

/// Product catalog loader — fintech stale-while-revalidate, not aggressive polling.
class ServicesController extends ChangeNotifier {
  ServicesController({
    required ServicesService services,
    required AppConnectivity connectivity,
  })  : _services = services,
        _connectivity = connectivity {
    _connectivity.addListener(_onConnectivityChanged);
    unawaited(startup());
  }

  final ServicesService _services;
  final AppConnectivity _connectivity;

  Timer? _softPollTimer;
  bool _appInForeground = false;
  bool _refreshInFlight = false;
  bool _pendingSilentRefresh = false;
  DateTime? _lastFetchAt;
  bool _hydrated = false;

  bool loading = false;
  String? errorKey;
  List<ActiveService> items = const [];

  bool get hasData => items.isNotEmpty;

  /// App start: disk cache first, then network if stale.
  Future<void> startup() async {
    await hydrateFromDisk();
    if (_connectivity.isOnline) {
      await revalidateIfStale(force: !hasData);
    }
  }

  /// Load cached catalog for instant first paint (SWR).
  Future<void> hydrateFromDisk() async {
    if (_hydrated) return;
    _hydrated = true;
    final cached = await ServicesLocalCache.load();
    final cachedAt = await ServicesLocalCache.lastUpdatedAt();
    if (cached.isEmpty) return;
    items = cached;
    _lastFetchAt = cachedAt;
    notifyListeners();
  }

  /// Screen opened (Home / Add Lead) — refresh only if catalog is stale.
  void onScreenVisible() {
    if (!_connectivity.isOnline) return;
    unawaited(revalidateIfStale());
  }

  /// Pull-to-refresh — user explicitly wants latest data.
  Future<void> pullToRefresh() => refresh(userInitiated: true);

  Future<void> ensureLoaded() async => onScreenVisible();

  void setForeground(bool inForeground) {
    if (_appInForeground == inForeground) return;
    _appInForeground = inForeground;
    if (inForeground) {
      if (_connectivity.isOnline) {
        unawaited(revalidateIfStale());
        _maybeStartSoftPoll();
      }
    } else {
      _stopSoftPoll();
    }
  }

  @override
  void dispose() {
    _stopSoftPoll();
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline) {
      unawaited(revalidateIfStale(force: !hasData));
      if (_appInForeground) _maybeStartSoftPoll();
    } else {
      _stopSoftPoll();
    }
  }

  bool _isStale() {
    final last = _lastFetchAt;
    if (last == null) return true;
    return DateTime.now().difference(last) > AppConfig.servicesStaleAfter;
  }

  bool _shouldSkipFetch({required bool silent, bool userInitiated = false}) {
    if (userInitiated) return false;
    if (!silent) return false;
    final last = _lastFetchAt;
    if (last == null) return false;
    if (_isStale()) return false;
    return DateTime.now().difference(last) < AppConfig.servicesMinRefreshGap;
  }

  Future<void> revalidateIfStale({bool force = false}) async {
    if (!force && !_isStale()) return;
    await refresh(silent: hasData);
  }

  void _maybeStartSoftPoll() {
    _stopSoftPoll();
    if (!AppConfig.servicesEnableSoftBackgroundPoll) return;
    if (!_appInForeground || !_connectivity.isOnline) return;

    _softPollTimer = Timer.periodic(AppConfig.servicesSoftPollInterval, (_) {
      if (!_appInForeground || !_connectivity.isOnline || _refreshInFlight) {
        return;
      }
      unawaited(revalidateIfStale());
    });
  }

  void _stopSoftPoll() {
    _softPollTimer?.cancel();
    _softPollTimer = null;
  }

  /// [silent] = background revalidate (no blocking spinner if cache exists).
  /// [userInitiated] = pull-to-refresh (always hits network).
  Future<void> refresh({
    bool silent = false,
    bool userInitiated = false,
  }) async {
    final background = silent && !userInitiated;
    if (background && _shouldSkipFetch(silent: true)) return;

    if (_refreshInFlight) {
      if (silent || userInitiated) _pendingSilentRefresh = true;
      return;
    }
    _refreshInFlight = true;

    final showLoadingUi = !silent && !hasData;
    if (showLoadingUi) {
      loading = true;
      errorKey = null;
      notifyListeners();
    }

    try {
      final next = await _services.fetchActiveServices(background: background);
      _lastFetchAt = DateTime.now();
      final changed = !activeServicesListEquals(items, next);
      items = next;
      errorKey = null;
      if (next.isNotEmpty) {
        unawaited(ServicesLocalCache.save(next));
      }
      if (changed || showLoadingUi) {
        loading = false;
        notifyListeners();
      }
    } catch (_) {
      errorKey = 'msgErrorTryAgain';
      if (!silent && !hasData) {
        items = const [];
        loading = false;
        notifyListeners();
      }
    } finally {
      _refreshInFlight = false;
      if (_pendingSilentRefresh) {
        _pendingSilentRefresh = false;
        if (_connectivity.isOnline) {
          unawaited(refresh(silent: hasData));
        }
      }
    }
  }
}
