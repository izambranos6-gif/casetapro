import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'image_saver_mobile.dart'
    if (dart.library.js_interop) 'image_saver_web.dart' as image_saver;
import '../core/dates.dart';
import '../models/feed_record.dart';
import '../widgets/report_table.dart';

class ReportService {
  static final ScreenshotController _screenshot = ScreenshotController();

  /// Captura todas las filas, incluidas las que no caben en la pantalla móvil.
  static Future<Uint8List> createPng(BuildContext context, {
    required int zone,
    required DateTime date,
    required List<FeedRecord> records,
  }) async {
    final widget = InheritedTheme.captureAll(context,
      Material(color: Colors.white, child: ReportTable(
        zone: zone, date: date, records: records)));
    return _screenshot.captureFromLongWidget(widget,
      context: context, pixelRatio: 2.0,
      delay: const Duration(milliseconds: 150),
      constraints: const BoxConstraints(maxWidth: 860));
  }

  static Future<Uint8List> createPdf(Uint8List pngBytes) async {
    final document = pw.Document();
    document.addPage(pw.Page(pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(16),
      build: (context) => pw.Center(
        child: pw.Image(pw.MemoryImage(pngBytes), fit: pw.BoxFit.contain)),
    ));
    return document.save();
  }

  static String fileBase(int zone, DateTime date) =>
    'abastecimiento_zona${zone}_${dateKey(date)}';

  static Future<void> saveImageToGallery(Uint8List image) =>
      image_saver.save(image);

  static Future<void> _shareBytes(BuildContext context,
    Uint8List bytes, String fileName, String mimeType) async {
    if (!context.mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, name: fileName, mimeType: mimeType)],
      fileNameOverrides: [fileName],
      sharePositionOrigin: renderBox == null ? null :
        renderBox.localToGlobal(Offset.zero) & renderBox.size,
    ));
  }

  static Future<void> shareImage(BuildContext context,
    Uint8List bytes, String fileName) =>
      _shareBytes(context, bytes, fileName, 'image/png');

  static Future<void> sharePdf(BuildContext context,
    Uint8List pdfBytes, String fileName) =>
      _shareBytes(context, pdfBytes, fileName, 'application/pdf');
}
