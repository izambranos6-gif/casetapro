import 'package:flutter_test/flutter_test.dart';
import 'package:casetapro/core/pools.dart';
import 'package:casetapro/core/dates.dart';
import 'package:casetapro/models/feed_record.dart';

void main() {
  test('Piscinas: 24 en Zona 1 y 22 en Zona 2', () {
    expect(Pools.zone1.length, 24);
    expect(Pools.zone2.length, 22);
    expect({...Pools.zone1, ...Pools.zone2}.length, 46);
    expect(Pools.belongsTo(1, 'IS001'), isTrue);
    expect(Pools.belongsTo(2, 'IS006'), isTrue);
    expect(Pools.belongsTo(2, 'IS001'), isFalse);
  });

  test('Registro: almacena los valores tal como se ingresan', () {
    final record = FeedRecord(
      zone: 2, pool: 'IS048', date: DateTime(2026, 11, 6),
      previous: 86, requested: 83, supplied: 89, caseta: 86,
    );
    record.validate();
    expect(FeedRecord.fromJson(record.toJson()).caseta, 86);
    expect(record.id, '2026-11-06|2|IS048');
    expect(dateKey(record.date), '2026-11-06');
  });

  test('Un registro no puede asignarse a otra zona', () {
    final bad = FeedRecord(zone: 1, pool: 'IS006',
      date: DateTime.now(), previous: 1, requested: 1,
      supplied: 1, caseta: 1);
    expect(() => bad.validate(), throwsArgumentError);
  });
}
