import 'dart:typed_data';
import 'package:gal/gal.dart';

Future<void> save(Uint8List bytes) =>
    Gal.putImageBytes(bytes, name: 'Reporte de abastecimiento');
