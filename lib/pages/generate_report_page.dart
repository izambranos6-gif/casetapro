import 'package:flutter/material.dart';
import '../core/dates.dart';
import '../core/theme.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';
import 'report_preview_page.dart';

class GenerateReportPage extends StatefulWidget {
  const GenerateReportPage({super.key, required this.zone});
  final int zone;
  @override
  State<GenerateReportPage> createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  DateTime _date = DateTime.now();
  bool _pdf = false;

  @override
  Widget build(BuildContext context) {
    final count = AppScope.of(context).forDay(widget.zone, _date).length;
    return AppFrame(title: 'Generar Reporte',
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 95),
        children: [
          const SectionHeading(label: 'Preparar reporte',
            icon: Icons.description_outlined),
          const SizedBox(height: 14),
          SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Zona del reporte', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ZoneBanner(zone: widget.zone),
              const SizedBox(height: 21),
              const Text('Fecha del reporte', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await selectRecordDate(context, _date);
                  if (date != null) setState(() => _date = date);
                },
                icon: const Icon(Icons.calendar_month_rounded, color: AppColors.sea),
                label: Text(niceDate(_date), style: const TextStyle(
                  fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 13),
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFE9F7F3),
                  borderRadius: BorderRadius.circular(13)),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.green, size: 20),
                  const SizedBox(width: 9),
                  Expanded(child: Text('$count piscinas registradas en esta fecha',
                    style: const TextStyle(color: AppColors.ink,
                      fontSize: 12, fontWeight: FontWeight.w700))),
                ]),
              ),
            ],
          )),
          const SizedBox(height: 20),
          const SectionHeading(label: 'Formato de salida',
            icon: Icons.file_copy_outlined, color: AppColors.violet),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: _choice(false, Icons.image_outlined, 'Imagen PNG')),
            const SizedBox(width: 12),
            Expanded(child: _choice(true, Icons.picture_as_pdf_outlined, 'PDF')),
          ]),
          const SizedBox(height: 21),
          FilledButton.icon(
            onPressed: count == 0 ? null : () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ReportPreviewPage(
                zone: widget.zone, date: _date, preferPdf: _pdf))),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Generar reporte'),
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Icon(Icons.shield_outlined, color: AppColors.muted, size: 17),
            SizedBox(width: 8),
            Expanded(child: Text('El archivo exportado solo contendrá fecha, '
              'zona, tabla y totales. No llevará marca ni logotipo.',
              style: TextStyle(color: AppColors.muted, fontSize: 11.5))),
          ]),
          if (count == 0) const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Registra al menos una piscina de esa fecha.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    );
  }

  Widget _choice(bool isPdf, IconData icon, String label) {
    final selected = _pdf == isPdf;
    final accent = isPdf ? const Color(0xFFCF6262) : AppColors.sea;
    return Material(color: Colors.transparent, child: InkWell(
      onTap: () => setState(() => _pdf = isPdf),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF5FA) : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: selected ? AppColors.sea : AppColors.stroke,
            width: selected ? 2 : 1),
          boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(.045),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(width: 48, height: 48,
              decoration: BoxDecoration(color: accent.withOpacity(.11),
                borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, size: 29, color: accent)),
            if (selected) const Positioned(right: -13, top: -7,
              child: Icon(Icons.check_circle_rounded,
                color: AppColors.green, size: 22)),
          ]),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(
            color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
        ]),
      ),
    ));
  }
}
