
import 'package:flutter/material.dart';

import '../core/dates.dart';
import '../core/theme.dart';
import '../services/report_service.dart';
import '../state/app_scope.dart';
import '../widgets/app_frame.dart';
import '../widgets/report_table.dart';

class ReportPreviewPage extends StatefulWidget {
  const ReportPreviewPage({
    super.key,
    required this.zone,
    required this.date,
    this.preferPdf = false,
  });

  final int zone;
  final DateTime date;
  final bool preferPdf;

  @override
  State<ReportPreviewPage> createState() =>
      _ReportPreviewPageState();
}

class _ReportPreviewPageState
    extends State<ReportPreviewPage> {

  bool _processing = false;

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // GUARDAR IMAGEN DIRECTAMENTE
  Future<void> _saveImage() async {
    if (_processing) return;

    setState(() => _processing = true);

    try {
      final records = AppScope.of(context)
          .forDay(widget.zone, widget.date);

      final png = await ReportService.createPng(
        context,
        zone: widget.zone,
        date: widget.date,
        records: records,
      );

      await ReportService.saveImageToGallery(png);

      if (!mounted) return;

      _message(
        'Reporte guardado correctamente.',
      );

    } catch (e) {
      _message('No se pudo guardar la imagen: $e');
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  // COMPARTIR IMAGEN
  Future<void> _shareImage() async {
    if (_processing) return;

    setState(() => _processing = true);

    try {
      final records = AppScope.of(context)
          .forDay(widget.zone, widget.date);

      final png = await ReportService.createPng(
        context,
        zone: widget.zone,
        date: widget.date,
        records: records,
      );

      if (!mounted) return;

      final fileName =
          '${ReportService.fileBase(
            widget.zone,
            widget.date,
          )}.png';

      await ReportService.shareImage(
        context,
        png,
        fileName,
      );

    } catch (e) {
      _message('No se pudo compartir: $e');
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  // EXPORTAR A PDF
  Future<void> _exportPdf() async {
    if (_processing) return;

    setState(() => _processing = true);

    try {
      final records = AppScope.of(context)
          .forDay(widget.zone, widget.date);

      final png = await ReportService.createPng(
        context,
        zone: widget.zone,
        date: widget.date,
        records: records,
      );

      final pdf = await ReportService.createPdf(png);

      if (!mounted) return;

      final fileName =
          '${ReportService.fileBase(
            widget.zone,
            widget.date,
          )}.pdf';

      await ReportService.sharePdf(
        context,
        pdf,
        fileName,
      );

    } catch (e) {
      _message('No se pudo exportar el PDF: $e');
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = AppScope.of(context)
        .forDay(widget.zone, widget.date);

    return AppFrame(
      title: 'Reporte de Balanceado',
      child: Column(
        children: [

          // INFORMACIÓN DEL REPORTE
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Zona ${widget.zone} · '
              '${niceDate(widget.date)} · '
              'Vista previa sin marca',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
                fontSize: 12,
              ),
            ),
          ),

          // VISTA PREVIA CON ZOOM
          Expanded(
            child: InteractiveViewer(
              minScale: 0.3,
              maxScale: 4,
              constrained: false,
              boundaryMargin:
                  const EdgeInsets.all(70),
              child: ReportTable(
                zone: widget.zone,
                date: widget.date,
                records: records,
              ),
            ),
          ),

          // BOTONES INFERIORES
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                14, 10, 14, 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // GUARDAR
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _processing ? null : _saveImage,
                      icon: const Icon(
                        Icons.download_rounded,
                      ),
                      label: const Text(
                        'Guardar imagen',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF159B78),
                        foregroundColor: Colors.white,
                        minimumSize:
                            const Size.fromHeight(48),
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // COMPARTIR
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _processing ? null : _shareImage,
                      icon: const Icon(
                        Icons.share_rounded,
                      ),
                      label: const Text(
                        'Compartir reporte',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.navy,
                        minimumSize:
                            const Size.fromHeight(46),
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  // PDF
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _processing ? null : _exportPdf,
                      icon: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFD84848),
                      ),
                      label: const Text(
                        'Exportar PDF',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.navy,
                        minimumSize:
                            const Size.fromHeight(46),
                      ),
                    ),
                  ),

                  if (_processing) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 5),
                    const Text(
                      'Preparando reporte...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
