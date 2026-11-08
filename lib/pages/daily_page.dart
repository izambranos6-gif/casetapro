
import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/pools.dart';
import '../core/theme.dart';
import '../models/feed_record.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';
import 'entry_page.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({
    super.key,
    required this.zone,
  });

  final int zone;

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  DateTime _date = DateTime.now();
  String _search = '';

  Future<void> _delete(FeedRecord record) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text(
          '¿Eliminar el registro de ${record.pool} '
          'del ${niceDate(record.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (yes != true || !mounted) return;

    try {
      await AppScope.of(context).delete(record);

      if (mounted) {
        showAppMessage(context, 'Registro eliminado.');
      }
    } catch (e) {
      if (mounted) {
        showAppMessage(context, 'No se pudo eliminar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    final records = controller.forDay(
      widget.zone,
      _date,
    );

    final byPool = {
      for (final record in records) record.pool: record,
    };

    final poolList = Pools.forZone(widget.zone)
        .where(
          (pool) => pool.toLowerCase().contains(
            _search.toLowerCase(),
          ),
        )
        .toList();

    final totals = _Totals.of(records);

    return AppFrame(
      title: 'Registros del Día',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          12,
          14,
          12,
          80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ZONA SELECCIONADA
            ZoneBanner(zone: widget.zone),

            const SizedBox(height: 12),

            // FILTROS
            SectionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _date = _date.subtract(
                              const Duration(days: 1),
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await selectRecordDate(
                              context,
                              _date,
                            );

                            if (date != null) {
                              setState(() => _date = date);
                            }
                          },
                          icon: const Icon(
                            Icons.calendar_month,
                          ),
                          label: Text(niceDate(_date)),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _date = _date.add(
                              const Duration(days: 1),
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),

//-------------------------------------------------;;;
const SizedBox(height: 12),

                  TextField(
                    onChanged: (text) {
                      setState(() => _search = text);
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar piscina...',
                      isDense: true,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${records.length} de '
                          '${Pools.forZone(widget.zone).length} '
                          'piscinas registradas',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // TABLA MÁS ANCHA
            SectionCard(
              padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: 18,
                        horizontalMargin: 10,
                        headingRowHeight: 56,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 52,
                        headingRowColor:
                            WidgetStateProperty.all(
                          AppColors.navy,
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('Piscina'),
                          ),
                          DataColumn(
                            label: Text('Ant.'),
                          ),
                          DataColumn(
                            label: Text('Pedido'),
                          ),
                          DataColumn(
                            label: Text('Abast.'),
                          ),
                          DataColumn(
                            label: Text('Caseta'),
                          ),
                          DataColumn(
                            label: Text('Acción'),
                          ),
                        ],
                        rows: poolList.map((pool) {
                          final record = byPool[pool];

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  pool,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  record == null
                                      ? '—'
                                      : '${record.previous}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  record == null
                                      ? '—'
                                      : '${record.requested}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  record == null
                                      ? '—'
                                      : '${record.supplied}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  record == null
                                      ? '—'
                                      : '${record.caseta}',
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: record == null
                                          ? 'Registrar'
                                          : 'Editar',
                                      visualDensity:
                                          VisualDensity.compact,
                                      icon: Icon(
                                        record == null
                                            ? Icons.add_circle_outline
                                            : Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EntryPage(
                                              zone: widget.zone,
                                              initialRecord: record,
                                              initialPool: pool,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (record != null)
                                      IconButton(
                                        tooltip: 'Eliminar',
                                        visualDensity:
                                            VisualDensity.compact,
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _delete(record),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // TOTALES
            SectionCard(
              child: Column(
                children: [
                  const Text(
                    'Totales registrados del día',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _total(
                        'Día anterior',
                        totals.previous,
                      ),
                      _total(
                        'Pedidos',
                        totals.requested,
                      ),
                      _total(
                        'Abastecidos',
                        totals.supplied,
                      ),
                      _total(
                        'Caseta',
                        totals.caseta,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            

  Widget _total(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 21,
            color: AppColors.navy,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Totals {
  const _Totals(
    this.previous,
    this.requested,
    this.supplied,
    this.caseta,
  );

  final int previous;
  final int requested;
  final int supplied;
  final int caseta;

  factory _Totals.of(List<FeedRecord> rows) {
    return _Totals(
      rows.fold<int>(
        0,
        (sum, item) => sum + item.previous,
      ),
      rows.fold<int>(
        0,
        (sum, item) => sum + item.requested,
      ),
      rows.fold<int>(
        0,
        (sum, item) => sum + item.supplied,
      ),
      rows.fold<int>(
        0,
        (sum, item) => sum + item.caseta,
      ),
    );
  }
}
