import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/data/redondeo_hacia_arriba.dart';

void main() {
  const estrategia = RedondeoHaciaArriba();

  group('RedondeoHaciaArriba: fracción a centavos', () {
    test('CA-006: diez entre tres produce 400 centavos', () {
      expect(
        estrategia.redondear(BigInt.from(10), BigInt.from(3)),
        BigInt.from(400),
      );
    });

    test('90 entre tres conserva 3000 centavos porque ya es entero', () {
      expect(
        estrategia.redondear(BigInt.from(90), BigInt.from(3)),
        BigInt.from(3000),
      );
    });

    test('3.001 se eleva a cuatro desde la fracción original', () {
      expect(
        estrategia.redondear(BigInt.from(3001), BigInt.from(1000)),
        BigInt.from(400),
      );
    });

    test('cero permanece en cero centavos', () {
      expect(estrategia.redondear(BigInt.zero, BigInt.one), BigInt.zero);
    });

    test('una persona con importe entero no aumenta su pago', () {
      expect(
        estrategia.redondear(BigInt.from(50), BigInt.one),
        BigInt.from(5000),
      );
    });

    test('una persona con 12.50 paga 1300 centavos', () {
      expect(
        estrategia.redondear(BigInt.from(1250), BigInt.from(100)),
        BigInt.from(1300),
      );
    });

    test('un importe positivo menor a un centavo se eleva a una unidad', () {
      expect(
        estrategia.redondear(BigInt.one, BigInt.from(2000)),
        BigInt.from(100),
      );
    });

    test('conserva la unidad superior de un importe grande con decimales', () {
      expect(
        estrategia.redondear(
          BigInt.parse('900719925474099301'),
          BigInt.from(100),
        ),
        BigInt.parse('900719925474099400'),
      );
    });

    test('un importe entero grande permanece sin aumento', () {
      expect(
        estrategia.redondear(BigInt.parse('9007199254740993'), BigInt.one),
        BigInt.parse('900719925474099300'),
      );
    });
  });
}
