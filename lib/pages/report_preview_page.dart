import 'package:flutter/material.dart';
import '../core/dates.dart';
import '../core/theme.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';
import '../widgets/report_table.dart';
import 'share_report_page.dart';

class ReportPreviewPage extends StatelessWidget {
  const ReportPreviewPage({super.key, required this.zone,
    required this.date, this.preferPdf = false});
  final int zone;
  final DateTime date;
  final bool preferPdf;

  @override
  Widget build(BuildContext context) {
    final records = AppScope.of(context).forDay(zone, date);
    return AppFrame(title: 'Reporte de Balanceado',
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(
          'Zona $zone · ${niceDate(date)} · Vista previa sin marca',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy))),
        Expanded(child: InteractiveViewer(
          minScale: .3, maxScale: 3,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(70),
          child: ReportTable(zone: zone, date: date, records: records),
        )),
        SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: SizedBox(width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ShareReportPage(
                  zone: zone, date: date, preferPdf: preferPdf))),
              icon: const Icon(Icons.share),
              label: const Text('Compartir / Guardar reporte'))),
        )),
      ]),
    );
  }
}
