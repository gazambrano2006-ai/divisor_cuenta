import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/data/redondeo_exacto.dart';

void main() {
  const estrategia = RedondeoExacto();

  group('RedondeoExacto: fracción a centavos', () {
    test('10 entre tres produce 333 centavos sin redistribuir sobrantes', () {
      expect(
        estrategia.redondear(BigInt.from(10), BigInt.from(3)),
        BigInt.from(333),
      );
    });

    test('1.005 redondea el empate al centavo superior', () {
      expect(
        estrategia.redondear(BigInt.from(1005), BigInt.from(1000)),
        BigInt.from(101),
      );
    });

    test('1.004 elige el centavo inferior más cercano', () {
      expect(
        estrategia.redondear(BigInt.from(1004), BigInt.from(1000)),
        BigInt.from(100),
      );
    });

    test('1.006 elige el centavo superior más cercano', () {
      expect(
        estrategia.redondear(BigInt.from(1006), BigInt.from(1000)),
        BigInt.from(101),
      );
    });

    test('1.015 también redondea el empate hacia arriba', () {
      expect(
        estrategia.redondear(BigInt.from(1015), BigInt.from(1000)),
        BigInt.from(102),
      );
    });

    test('cero produce cero centavos', () {
      expect(estrategia.redondear(BigInt.zero, BigInt.one), BigInt.zero);
    });

    test('el valor entero 90 entre tres permanece en 3000 centavos', () {
      expect(
        estrategia.redondear(BigInt.from(90), BigInt.from(3)),
        BigInt.from(3000),
      );
    });

    test('un importe menor a medio centavo produce cero', () {
      expect(estrategia.redondear(BigInt.one, BigInt.from(2000)), BigInt.zero);
    });

    test('un redondeo puede completar la unidad siguiente', () {
      expect(
        estrategia.redondear(BigInt.from(19999), BigInt.from(10000)),
        BigInt.from(200),
      );
    });

    test('conserva todos los centavos de un importe grande', () {
      expect(
        estrategia.redondear(
          BigInt.parse('900719925474099301'),
          BigInt.from(100),
        ),
        BigInt.parse('900719925474099301'),
      );
    });
  });
}
