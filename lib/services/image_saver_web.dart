
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

/// Descarga el PNG directamente desde Flutter Web.
Future<void> save(Uint8List bytes) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );

  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = 'reporte_abastecimiento.png';

  anchor.click();

  // Se libera la URL temporal después de iniciar la descarga.
  web.URL.revokeObjectURL(url);
}
