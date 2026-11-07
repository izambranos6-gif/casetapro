import 'package:flutter/material.dart';
import '../core/dates.dart';
import '../core/pools.dart';
import '../models/feed_record.dart';

/// Esta es la ÚNICA plantilla que se exporta a imagen y a PDF.
/// IMPORTANTE: no debe mostrar marca, logotipo, nombre de técnico ni camarón.
class ReportTable extends StatelessWidget {
  const ReportTable({super.key, required this.zone,
    required this.date, required this.records});
  final int zone;
  final DateTime date;
  final List<FeedRecord> records;

  @override
  Widget build(BuildContext context) {
    final data = {for (final record in records) record.pool: record};
    const green = Color(0xFF15841E);
    final sums = [
      records.fold<int>(0, (sum, r) => sum + r.previous),
      records.fold<int>(0, (sum, r) => sum + r.requested),
      records.fold<int>(0, (sum, r) => sum + r.supplied),
      records.fold<int>(0, (sum, r) => sum + r.caseta),
    ];
    return Container(
      width: 840, padding: const EdgeInsets.all(18), color: Colors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('REPORTE DE ABASTECIMIENTO DE BALANCEADO',
            style: TextStyle(fontSize: 17, color: Color(0xFF18364C),
              fontWeight: FontWeight.w900)),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('FECHA: ${niceDate(date)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text('ZONA $zone', style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w900, color: green)),
          ]),
        ]),
        const SizedBox(height: 15),
        Table(border: TableBorder.all(color: Colors.black87, width: .85),
          columnWidths: const {
            0: FlexColumnWidth(1.15),
            1: FlexColumnWidth(1.25),
            2: FlexColumnWidth(1.25),
            3: FlexColumnWidth(1.25),
            4: FlexColumnWidth(1.25),
          },
          children: [
            TableRow(decoration: const BoxDecoration(color: green), children: [
              _head('PISCINAS'), _head('SACOS DEL DÍA\nANTERIOR'),
              _head('SACOS PEDIDOS\nA BODEGA'),
              _head('SACOS\nABASTECIDOS'), _head('SACOS\nCASETA'),
            ]),
            ...Pools.forZone(zone).map((pool) {
              final record = data[pool];
              return TableRow(children: [
                _cell(pool, bold: true),
                _cell(record == null ? '' : '${record.previous}'),
                _cell(record == null ? '' : '${record.requested}'),
                _cell(record == null ? '' : '${record.supplied}'),
                _cell(record == null ? '' : '${record.caseta}'),
              ]);
            }),
            TableRow(decoration: const BoxDecoration(color: green),
              children: [
                _cell('TOTALES', bold: true, inverse: true),
                ...sums.map((sum) => _cell('$sum', bold: true, inverse: true)),
              ]),
          ],
        ),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight,
          child: Text('${records.length} de ${Pools.forZone(zone).length} piscinas registradas',
            style: const TextStyle(color: Colors.black54, fontSize: 12))),
      ]),
    );
  }

  Widget _head(String text) => SizedBox(height: 50,
    child: Center(child: Padding(padding: const EdgeInsets.all(5),
      child: Text(text, textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 12,
          fontWeight: FontWeight.w900, height: 1.1)))));

  Widget _cell(String text, {bool bold = false, bool inverse = false}) =>
    SizedBox(height: 32, child: Center(child: Text(text,
      style: TextStyle(color: inverse ? Colors.white : Colors.black,
        fontSize: 13, fontWeight: bold ? FontWeight.w900 : FontWeight.w500))));
}
