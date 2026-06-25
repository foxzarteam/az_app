import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/active_service.dart';

/// Disk cache for product catalog (stale-while-revalidate — fintech norm).
class ServicesLocalCache {
  ServicesLocalCache._();

  static const _itemsKey = 'services_catalog_v1';
  static const _updatedAtKey = 'services_catalog_updated_v1';

  static Future<List<ActiveService>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_itemsKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final out = <ActiveService>[];
      for (final row in decoded) {
        if (row is Map) {
          final map = row.map((k, v) => MapEntry(k.toString(), v));
          final item = ActiveService.fromMap(map);
          if (item.slug.isNotEmpty) out.add(item);
        }
      }
      out.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return out;
    } catch (_) {
      return const [];
    }
  }

  static Future<DateTime?> lastUpdatedAt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt(_updatedAtKey);
      if (ms == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(List<ActiveService> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = items.map((e) => e.toMap()).toList(growable: false);
      await prefs.setString(_itemsKey, jsonEncode(payload));
      await prefs.setInt(
        _updatedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // Cache write failure must not break the app.
    }
  }
}
