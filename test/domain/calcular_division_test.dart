import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/data/redondeo_exacto.dart';
import 'package:participacion7/domain/calcular_division.dart';
import 'package:participacion7/domain/cuenta.dart';
import 'package:participacion7/domain/estrategia_redondeo.dart';

void main() {
  const calculador = CalcularDivision();
  const exacto = RedondeoExacto();

  group('CalcularDivision con redondeo Exacto', () {
    test('CA-001: 100.00, cuatro personas y 10% produce 2750 centavos', () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.from(10000),
        montoEscala: 2,
        personas: BigInt.from(4),
        propinaCoeficiente: BigInt.from(10),
        propinaEscala: 0,
      );

      final resultado = calculador.ejecutar(cuenta, exacto);

      expect(resultado.centavosPorPersona, BigInt.from(2750));
    });

    test('CA-002: 90.00, tres personas y 0% produce 3000 centavos', () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.from(9000),
        montoEscala: 2,
        personas: BigInt.from(3),
        propinaCoeficiente: BigInt.zero,
        propinaEscala: 0,
      );

      final resultado = calculador.ejecutar(cuenta, exacto);

      expect(resultado.centavosPorPersona, BigInt.from(3000));
    });

    test('CA-005: 10.00, tres personas y 0% produce 333 centavos', () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.from(1000),
        montoEscala: 2,
        personas: BigInt.from(3),
        propinaCoeficiente: BigInt.zero,
        propinaEscala: 0,
      );

      final resultado = calculador.ejecutar(cuenta, exacto);

      expect(resultado.centavosPorPersona, BigInt.from(333));
    });

    test('12.50 con 12.5% entre dos personas produce 703 centavos', () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.from(1250),
        montoEscala: 2,
        personas: BigInt.from(2),
        propinaCoeficiente: BigInt.from(125),
        propinaEscala: 1,
      );

      final resultado = calculador.ejecutar(cuenta, exacto);

      expect(resultado.centavosPorPersona, BigInt.from(703));
    });

    test('una persona recibe todo el monto con su propina', () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.from(10000),
        montoEscala: 2,
        personas: BigInt.one,
        propinaCoeficiente: BigInt.from(10),
        propinaEscala: 0,
      );

      final resultado = calculador.ejecutar(cuenta, exacto);

      expect(resultado.centavosPorPersona, BigInt.from(11000));
    });

    test('monto cero permanece cero incluso con propina decimal', () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.zero,
        montoEscala: 2,
        personas: BigInt.one,
        propinaCoeficiente: BigInt.from(125),
        propinaEscala: 1,
      );

      final resultado = calculador.ejecutar(cuenta, exacto);

      expect(resultado.centavosPorPersona, BigInt.zero);
    });

    test('conserva centavos de un importe fuera de la precisión de double', () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.parse('900719925474099301'),
        montoEscala: 2,
        personas: BigInt.one,
        propinaCoeficiente: BigInt.zero,
        propinaEscala: 0,
      );

      final resultado = calculador.ejecutar(cuenta, exacto);

      expect(resultado.centavosPorPersona, BigInt.parse('900719925474099301'));
    });
  });

  test(
    'delega la fracción original y conserva los centavos de la estrategia',
    () {
      final cuenta = Cuenta(
        montoCoeficiente: BigInt.from(12345),
        montoEscala: 2,
        personas: BigInt.from(3),
        propinaCoeficiente: BigInt.from(75),
        propinaEscala: 1,
      );
      final estrategia = _EstrategiaDePrueba(BigInt.from(98765));

      final resultado = calculador.ejecutar(cuenta, estrategia);

      expect(estrategia.numeradorRecibido, BigInt.from(13270875));
      expect(estrategia.denominadorRecibido, BigInt.from(300000));
      expect(estrategia.invocaciones, 1);
      expect(resultado.centavosPorPersona, BigInt.from(98765));
    },
  );
}

/// Captura la delegación para comprobarla sin repetir la fórmula de la cuenta.
class _EstrategiaDePrueba implements EstrategiaRedondeo {
  /// Recibe los centavos esperados y crea el sustituto sin producir errores.
  _EstrategiaDePrueba(this.centavos);

  final BigInt centavos;
  BigInt? numeradorRecibido;
  BigInt? denominadorRecibido;
  int invocaciones = 0;

  /// Recibe la fracción, la registra y devuelve los centavos sin errores.
  @override
  BigInt redondear(BigInt numerador, BigInt denominador) {
    numeradorRecibido = numerador;
    denominadorRecibido = denominador;
    invocaciones += 1;
    return centavos;
  }
}
