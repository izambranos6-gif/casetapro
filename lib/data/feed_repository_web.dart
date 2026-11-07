import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_record.dart';
import 'feed_repository_contract.dart';

/// Navegador: persistencia local del navegador; no sincroniza otros dispositivos.
class LocalJsonFeedRepository implements FeedRepository {
  static const _key = 'casetapro.registros.v1';

  @override
  Future<List<FeedRecord>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final parsed = jsonDecode(raw) as List<dynamic>;
    return parsed
        .map((item) => FeedRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> writeAll(List<FeedRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(_key,
      jsonEncode(records.map((r) => r.toJson()).toList()));
    if (!ok) throw StateError('No se pudieron guardar los registros.');
  }
}
