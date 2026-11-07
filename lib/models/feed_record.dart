import '../core/dates.dart';
import '../core/pools.dart';

/// Modelo libre de UI/Flutter: preparado para repositorio REST en el futuro.
class FeedRecord {
  const FeedRecord({
    required this.zone,
    required this.pool,
    required this.date,
    required this.previous,
    required this.requested,
    required this.supplied,
    required this.caseta,
  });

  final int zone;
  final String pool;
  final DateTime date;
  final int previous;
  final int requested;
  final int supplied;
  final int caseta;

  String get id => '${dateKey(date)}|$zone|$pool';

  static int suggestedCaseta(int previous, int requested, int supplied) =>
      previous + requested - supplied;

  void validate() {
    if (!Pools.belongsTo(zone, pool)) {
      throw ArgumentError('La piscina $pool no pertenece a la Zona $zone.');
    }
    if ([previous, requested, supplied, caseta].any((v) => v < 0)) {
      throw ArgumentError('Los sacos no pueden ser negativos.');
    }
  }

  Map<String, dynamic> toJson() => {
    'zone': zone,
    'pool': pool,
    'date': dateKey(date),
    'previous': previous,
    'requested': requested,
    'supplied': supplied,
    'caseta': caseta,
  };

  factory FeedRecord.fromJson(Map<String, dynamic> json) {
    return FeedRecord(
      zone: (json['zone'] as num).toInt(),
      pool: json['pool'] as String,
      date: DateTime.parse(json['date'] as String),
      previous: (json['previous'] as num).toInt(),
      requested: (json['requested'] as num).toInt(),
      supplied: (json['supplied'] as num).toInt(),
      caseta: (json['caseta'] as num).toInt(),
    )..validate();
  }
}
