import '../core/dates.dart';
import '../core/pools.dart';

/// Modelo de registro, independiente de la interfaz de Flutter.
class FeedRecord {
  const FeedRecord({
    required this.zone,
    required this.pool,
    required this.date,
    required this.previous,
    required this.requested,
    required this.supplied,
    required this.caseta,
    this.differenceReason = '',
    this.observation = '',
  });

  final int zone;
  final String pool;
  final DateTime date;
  final int previous;
  final int requested;
  final int supplied;
  final int caseta;
  final String differenceReason;
  final String observation;

  String get id => '${dateKey(date)}|$zone|$pool';

  static int suggestedCaseta(int previous, int requested, int supplied) =>
      previous + requested - supplied;

  int get calculatedCaseta => suggestedCaseta(previous, requested, supplied);
  int get difference => caseta - calculatedCaseta;
  bool get hasDifference => difference != 0;

  void validate() {
    if (!Pools.belongsTo(zone, pool)) {
      throw ArgumentError('La piscina $pool no pertenece a la Zona $zone.');
    }
    if ([previous, requested, supplied, caseta].any((value) => value < 0)) {
      throw ArgumentError('Los sacos no pueden ser negativos.');
    }
    if (hasDifference && differenceReason.trim().isEmpty) {
      throw ArgumentError('Debes indicar el motivo de la diferencia.');
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
        'differenceReason': differenceReason,
        'observation': observation,
      };

  factory FeedRecord.fromJson(Map<String, dynamic> json) {
    final previous = (json['previous'] as num).toInt();
    final requested = (json['requested'] as num).toInt();
    final supplied = (json['supplied'] as num).toInt();
    final caseta = (json['caseta'] as num).toInt();
    final computed = suggestedCaseta(previous, requested, supplied);
    // Compatibilidad: registros anteriores sin motivo siguen siendo legibles.
    final storedReason = (json['differenceReason'] as String?)?.trim() ?? '';
    final reason = storedReason.isNotEmpty
        ? storedReason
        : (caseta != computed ? 'Registro anterior sin motivo' : '');
    return FeedRecord(
      zone: (json['zone'] as num).toInt(),
      pool: json['pool'] as String,
      date: DateTime.parse(json['date'] as String),
      previous: previous,
      requested: requested,
      supplied: supplied,
      caseta: caseta,
      differenceReason: reason,
      observation: (json['observation'] as String?) ?? '',
    )..validate();
  }
}
