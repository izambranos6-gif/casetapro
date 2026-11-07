import 'package:flutter/material.dart';
import '../core/dates.dart';
import '../core/pools.dart';
import '../core/theme.dart';
import '../models/feed_record.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';
import 'entry_page.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key, required this.zone});
  final int zone;
  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 14)),
    end: DateTime.now(),
  );
  String? _pool;

  @override
  Widget build(BuildContext context) {
    final all = AppScope.of(context).allForZone(widget.zone);
    final matches = all.where((r) {
      final date = DateTime(r.date.year, r.date.month, r.date.day);
      final start = DateTime(_range.start.year, _range.start.month, _range.start.day);
      final end = DateTime(_range.end.year, _range.end.month, _range.end.day);
      return !date.isBefore(start) && !date.isAfter(end) &&
        (_pool == null || r.pool == _pool);
    }).toList();
    matches.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : a.pool.compareTo(b.pool);
    });

    return AppFrame(title: 'Consultas por Fecha',
      child: ListView(padding: const EdgeInsets.fromLTRB(14, 14, 14, 88), children: [
        ZoneBanner(zone: widget.zone),
        const SizedBox(height: 13),
        SectionCard(child: Column(children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text('${niceDate(_range.start)}  —  ${niceDate(_range.end)}'),
            onPressed: () async {
              final range = await showDateRangePicker(context: context,
                firstDate: DateTime(2020), lastDate: DateTime(2100),
                initialDateRange: _range,
                locale: const Locale('es'));
              if (range != null) setState(() => _range = range);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _pool, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Filtrar por piscina',
              prefixIcon: Icon(Icons.waves)),
            items: [
              const DropdownMenuItem<String?>(value: null,
                child: Text('Todas las piscinas')),
              ...Pools.forZone(widget.zone).map((p) => DropdownMenuItem<String?>(
                value: p, child: Text(p))),
            ],
            onChanged: (p) => setState(() => _pool = p),
          ),
        ])),
        const SizedBox(height: 15),
        Text('${matches.length} registros encontrados',
          style: const TextStyle(color: AppColors.navy,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (matches.isEmpty)
          const SectionCard(child: Text('No hay registros en el período seleccionado.')),
        ...matches.map((r) => Padding(padding: const EdgeInsets.only(bottom: 9),
          child: SectionCard(child: Column(children: [
            Row(children: [
              Expanded(child: Text('${r.pool} · ${niceDate(r.date)}',
                style: const TextStyle(fontWeight: FontWeight.w900,
                  fontSize: 15, color: AppColors.navy))),
              IconButton(tooltip: 'Editar', onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => EntryPage(zone: widget.zone,
                  initialRecord: r))), icon: const Icon(Icons.edit, color: AppColors.sea)),
            ]),
            Wrap(spacing: 15, runSpacing: 5, children: [
              Text('Anterior: ${r.previous}'), Text('Pedidos: ${r.requested}'),
              Text('Abastecidos: ${r.supplied}'), Text('Caseta: ${r.caseta}'),
            ]),
          ])),
        )),
      ]),
    );
  }
}
