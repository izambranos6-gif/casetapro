import 'package:flutter_test/flutter_test.dart';
import 'package:casetapro/core/pools.dart';

// Sustituye el widget_test.dart que Flutter genera con el ejemplo `MyApp`.
void main() {
  test('La primera zona tiene 24 piscinas y la segunda 22', () {
    expect(Pools.zone1.length, 24);
    expect(Pools.zone2.length, 22);
  });
}
