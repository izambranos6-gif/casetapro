import 'package:flutter/foundation.dart';
import '../core/dates.dart';
import '../data/feed_repository.dart';
import '../models/feed_record.dart';

class FeedController extends ChangeNotifier {
  FeedController(this.repository);
  final FeedRepository repository;
  List<FeedRecord> _records = [];

  Future<void> load() async {
    _records = await repository.readAll();
    notifyListeners();
  }

  List<FeedRecord> forDay(int zone, DateTime date) {
    final key = dateKey(date);
    final list = _records
        .where((r) => r.zone == zone && dateKey(r.date) == key)
        .toList();
    list.sort((a, b) => a.pool.compareTo(b.pool));
    return list;
  }

  List<FeedRecord> allForZone(int zone) =>
      _records.where((r) => r.zone == zone).toList();

  FeedRecord? find(int zone, DateTime date, String pool) {
    for (final record in _records) {
      if (record.zone == zone && record.pool == pool &&
          dateKey(record.date) == dateKey(date)) {
        return record;
      }
    }
    return null;
  }

  Future<void> upsert(FeedRecord value) async {
    value.validate();
    final updated = [..._records]..removeWhere((r) => r.id == value.id);
    updated.add(value);
    await repository.writeAll(updated);
    _records = updated;
    notifyListeners();
  }

  Future<void> delete(FeedRecord record) async {
    final updated = [..._records]..removeWhere((r) => r.id == record.id);
    await repository.writeAll(updated);
    _records = updated;
    notifyListeners();
  }
}
