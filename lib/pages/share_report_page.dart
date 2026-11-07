import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/dates.dart';
import '../core/theme.dart';
import '../services/report_service.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';

class ShareReportPage extends StatefulWidget {
  const ShareReportPage({super.key, required this.zone,
    required this.date, this.preferPdf = false});
  final int zone;
  final DateTime date;
  final bool preferPdf;
  @override
  State<ShareReportPage> createState() => _ShareReportPageState();
}

class _ShareReportPageState extends State<ShareReportPage> {
  Uint8List? _png;
  bool _working = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_png == null && !_working && _error == null) _prepare();
  }

  Future<void> _prepare() async {
    setState(() => _working = true);
    try {
      final records = AppScope.of(context).forDay(widget.zone, widget.date);
      final png = await ReportService.createPng(context,
        zone: widget.zone, date: widget.date, records: records);
      if (mounted) setState(() => _png = png);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _run(Future<void> Function(Uint8List) action) async {
    if (_png == null || _working) return;
    setState(() => _working = true);
    try {
      await action(_png!);
    } catch (e) {
      if (mounted) showAppMessage(context, 'No se pudo completar la operación: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = ReportService.fileBase(widget.zone, widget.date);
    return AppFrame(title: 'Compartir Reporte',
      child: ListView(padding: const EdgeInsets.fromLTRB(14, 15, 14, 85), children: [
        ZoneBanner(zone: widget.zone),
        const SizedBox(height: 8),
        Text('Fecha: ${niceDate(widget.date)}', textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_working && _png == null) const Center(
          child: Padding(padding: EdgeInsets.all(25),
            child: CircularProgressIndicator())),
        if (_error != null) SectionCard(child: Column(children: [
          Text('Error al crear la imagen: $_error'),
          TextButton(onPressed: () { setState(() => _error = null); _prepare(); },
            child: const Text('Reintentar')),
        ])),
        if (_png != null) SectionCard(child: Column(children: [
          const Text('Vista previa del reporte que se compartirá',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
          const SizedBox(height: 10),
          Image.memory(_png!, fit: BoxFit.contain),
          const SizedBox(height: 10),
          const Text('El archivo NO lleva nombre de CasetaPro, '
            'AQUAPRO ni logotipo del camarón.',
            style: TextStyle(color: Colors.black54, fontSize: 11),
            textAlign: TextAlign.center),
        ])),
        const SizedBox(height: 14),
        _action('Compartir por WhatsApp', Icons.chat, const Color(0xFF11A83F),
          _png != null && !_working ? () => _run((png) =>
            ReportService.shareImage(context, png, '$base.png')) : null),
        _action('Guardar en galería', Icons.image_outlined, AppColors.violet,
          _png != null && !_working ? () => _run((png) async {
            await ReportService.saveImageToGallery(png);
            if (mounted) showAppMessage(context, 'Imagen guardada en la galería.');
          }) : null),
        _action('Exportar a PDF', Icons.picture_as_pdf, Colors.red,
          _png != null && !_working ? () => _run((png) async {
            final bytes = await ReportService.createPdf(png);
            if (mounted) await ReportService.sharePdf(context, bytes, '$base.pdf');
          }) : null),
        _action('Compartir con otras apps', Icons.share, AppColors.sea,
          _png != null && !_working ? () => _run((png) =>
            ReportService.shareImage(context, png, '$base.png')) : null),
        if (widget.preferPdf) const Padding(
          padding: EdgeInsets.all(10), child: Text(
            'Seleccionaste PDF: pulsa "Exportar a PDF" para compartir ese formato.',
            style: TextStyle(fontSize: 12, color: Colors.black54))),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child:
          Text('Para WhatsApp, selecciónalo en el menú de compartir del teléfono.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54))),
      ]),
    );
  }

  Widget _action(String title, IconData icon, Color color, VoidCallback? onPressed) =>
    Padding(padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: AppColors.stroke),
              boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(.045),
                blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Row(children: [
              Container(width: 43, height: 43,
                decoration: BoxDecoration(color: color.withOpacity(.11),
                  borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: color, size: 26)),
              const SizedBox(width: 13),
              Expanded(child: Text(title, style: const TextStyle(
                color: AppColors.ink, fontWeight: FontWeight.w800,
                fontSize: 14))),
              Icon(Icons.chevron_right_rounded,
                color: onPressed == null ? AppColors.stroke : AppColors.muted),
            ]),
          ),
        ),
      ),
    );
}
