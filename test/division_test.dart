import 'package:matcher/expect.dart';
import 'package:test_api/scaffolding.dart' show test;

import '../lib/data/redondeo_exacto.dart';
import '../lib/data/redondeo_hacia_arriba.dart';
import '../lib/domain/calcular_division.dart';
import '../lib/domain/estrategia_redondeo.dart';
import '../lib/domain/resultado.dart';
import '../lib/domain/validar_entrada.dart';
import 'casos_de_prueba.dart';

/// Registra los casos del dominio y comprueba sustitución de estrategias.
/// No recibe argumentos ni usa Flutter; los fallos se notifican como assertions.
void main() {
  const validador = ValidarEntrada();
  const calculo = CalcularDivision();
  const estrategias = <String, EstrategiaRedondeo>{
    'exacto': RedondeoExacto(),
    'arriba': RedondeoHaciaArriba(),
  };

  for (final caso in casos) {
    test(caso.nombre, () {
      var calculosEjecutados = 0;
      Resultado? resultado;

      /// Valida antes de calcular para impedir operaciones con entrada inválida.
      /// Usa el caso actual y guarda el resultado; propaga el error del validador.
      void validarYCalcular() {
        final cuenta = validador.ejecutar(
          monto: caso.monto.toString(),
          personas: caso.personas.toString(),
          propina: caso.propina.toString(),
        );
        calculosEjecutados++;
        resultado = calculo.ejecutar(cuenta, estrategias[caso.modo]!);
      }

      if (caso.errorEsperado != null) {
        expect(
          validarYCalcular,
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'mensaje exacto',
              equals(caso.errorEsperado),
            ),
          ),
        );
        expect(calculosEjecutados, 0);
        expect(resultado, isNull);
      } else {
        expect(caso.esperado, isNotNull);
        validarYCalcular();
        expect(calculosEjecutados, 1);
        expect(
          resultado!.centavosPorPersona.toDouble() / 100,
          closeTo(caso.esperado!, 0.001),
        );
      }
    });
  }

  test('propina de 150% devuelve el mensaje exacto del límite', () {
    expect(
      () => validador.ejecutar(monto: '100', personas: '4', propina: '150'),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'mensaje exacto',
          equals('La propina no puede superar el 100%'),
        ),
      ),
    );
  });

  test('propina de 100% se permite sin error', () {
    expect(
      () => validador.ejecutar(monto: '100', personas: '4', propina: '100'),
      returnsNormally,
    );
  });

  test('LSP: el mismo cálculo admite Exacto y Hacia arriba', () {
    final cuenta = validador.ejecutar(
      monto: '10.00',
      personas: '3',
      propina: '0',
    );
    const EstrategiaRedondeo exacto = RedondeoExacto();
    const EstrategiaRedondeo haciaArriba = RedondeoHaciaArriba();

    final resultadoExacto = calculo.ejecutar(cuenta, exacto);
    final resultadoHaciaArriba = calculo.ejecutar(cuenta, haciaArriba);

    expect(
      resultadoExacto.centavosPorPersona.toDouble() / 100,
      closeTo(3.33, 0.001),
    );
    expect(
      resultadoHaciaArriba.centavosPorPersona.toDouble() / 100,
      closeTo(4.00, 0.001),
    );
  });
}
