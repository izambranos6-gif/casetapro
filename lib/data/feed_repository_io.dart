import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/feed_record.dart';
import 'feed_repository_contract.dart';

/// Android/iOS/desktop: conserva el almacenamiento JSON de la versión original.
class LocalJsonFeedRepository implements FeedRepository {
  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/consumo_caseta_registros.json');
  }

  @override
  Future<List<FeedRecord>> readAll() async {
    final file = await _file();
    if (!await file.exists()) return [];
    final parsed = jsonDecode(await file.readAsString()) as List<dynamic>;
    return parsed
        .map((item) => FeedRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> writeAll(List<FeedRecord> records) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(records.map((r) => r.toJson()).toList()), flush: true);
  }
}
