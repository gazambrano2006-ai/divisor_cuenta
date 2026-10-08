import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/domain/resultado.dart';
import 'package:participacion7/presentation/formateador_moneda.dart';

/// Comprueba el texto de centavos finales sin repetir un cálculo o redondeo.
void main() {
  const formateador = FormateadorMoneda();
  const casos = {
    '2750': '27.50',
    '3000': '30.00',
    '333': '3.33',
    '400': '4.00',
    '0': '0.00',
    '1': '0.01',
    '105': '1.05',
    '100000000000000000000001': '1000000000000000000000.01',
  };

  for (final caso in casos.entries) {
    test('formatea ${caso.key} centavos como ${caso.value}', () {
      final resultado = Resultado(centavosPorPersona: BigInt.parse(caso.key));
      expect(formateador.formatear(resultado), caso.value);
    });
  }
}
