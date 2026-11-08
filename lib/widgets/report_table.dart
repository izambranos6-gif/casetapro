import 'package:flutter/material.dart';
import '../core/dates.dart';
import '../core/pools.dart';
import '../models/feed_record.dart';

/// Esta es la ÚNICA plantilla que se exporta a imagen y a PDF.
/// IMPORTANTE: no debe mostrar marca, logotipo, nombre de técnico ni camarón.
class ReportTable extends StatelessWidget {
  const ReportTable({
    super.key,
    required this.zone,
    required this.date,
    required this.records,
  });

  final int zone;
  final DateTime date;
  final List<FeedRecord> records;

  static const Color green = Color(0xFF15841E);
  static const Color titleColor = Color(0xFF18364C);

  @override
  Widget build(BuildContext context) {
    final data = {for (final record in records) record.pool: record};

    final sums = [
      records.fold<int>(0, (sum, r) => sum + r.previous),
      records.fold<int>(0, (sum, r) => sum + r.requested),
      records.fold<int>(0, (sum, r) => sum + r.supplied),
      records.fold<int>(0, (sum, r) => sum + r.caseta),
    ];

    final pools = Pools.forZone(zone);

    return Container(
      width: 1040,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'REPORTE DE ABASTECIMIENTO DE BALANCEADO',
                  style: TextStyle(
                    fontSize: 24,
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'FECHA: ${niceDate(date)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ZONA $zone',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Table(
            border: TableBorder.all(
              color: Colors.black87,
              width: 1.0,
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.10),
              1: FlexColumnWidth(1.22),
              2: FlexColumnWidth(1.22),
              3: FlexColumnWidth(1.20),
              4: FlexColumnWidth(1.20),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: green),
                children: const [
                  _HeaderCell('PISCINAS'),
                  _HeaderCell('SACOS DEL DÍA\nANTERIOR'),
                  _HeaderCell('SACOS PEDIDOS\nA BODEGA'),
                  _HeaderCell('SACOS\nABASTECIDOS'),
                  _HeaderCell('SACOS\nCASETA'),
                ],
              ),
              ...pools.map((pool) {
                final record = data[pool];
                return TableRow(
                  children: [
                    _DataCell(
                      pool,
                      bold: true,
                      fontSize: 23,
                    ),
                    _DataCell(
                      record == null ? '' : '${record.previous}',
                      fontSize: 26,
                    ),
                    _DataCell(
                      record == null ? '' : '${record.requested}',
                      fontSize: 26,
                    ),
                    _DataCell(
                      record == null ? '' : '${record.supplied}',
                      fontSize: 26,
                    ),
                    _DataCell(
                      record == null ? '' : '${record.caseta}',
                      fontSize: 26,
                    ),
                  ],
                );
              }),
              TableRow(
                decoration: const BoxDecoration(color: green),
                children: [
                  const _DataCell(
                    'TOTALES',
                    bold: true,
                    inverse: true,
                    fontSize: 26,
                  ),
                  ...sums.map(
                    (sum) => _DataCell(
                      '$sum',
                      bold: true,
                      inverse: true,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${records.length} de ${pools.length} piscinas registradas',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _DataCell extends StatelessWidget {
  const _DataCell(
    this.text, {
    this.bold = false,
    this.inverse = false,
    this.fontSize = 15,
  });

  final String text;
  final bool bold;
  final bool inverse;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: inverse ? Colors.white : Colors.black,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}