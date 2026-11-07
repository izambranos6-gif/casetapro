import '../models/feed_record.dart';

/// Abstracción de persistencia para una futura API.
abstract class FeedRepository {
  Future<List<FeedRecord>> readAll();
  Future<void> writeAll(List<FeedRecord> records);
}
