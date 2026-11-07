import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';

/// En web se utiliza el mecanismo de descarga/compartir del navegador.
Future<void> save(Uint8List bytes) async {
  await SharePlus.instance.share(ShareParams(
    files: [XFile.fromData(bytes,
      name: 'reporte_abastecimiento.png', mimeType: 'image/png')],
    fileNameOverrides: ['reporte_abastecimiento.png'],
  ));
}
