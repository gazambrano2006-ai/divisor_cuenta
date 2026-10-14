import 'cuenta.dart';
import 'estrategia_redondeo.dart';
import 'resultado.dart';

/// Calcula la parte individual sin validar entradas ni dar formato de moneda.
class CalcularDivision {
  /// Crea el cálculo sin dependencias ocultas, entradas ni errores de usuario.
  const CalcularDivision();

  /// Aplica la fórmula para separar el cálculo de la regla de redondeo.
  ///
  /// Recibe una [cuenta] validada y una [estrategia] sustituible. Devuelve los
  /// centavos finales en un [Resultado], sin errores con entradas válidas.
  Resultado ejecutar(Cuenta cuenta, EstrategiaRedondeo estrategia) {
    final factorEscalaMonto = BigInt.from(10).pow(cuenta.montoEscala);
    final factorEscalaPropina = BigInt.from(10).pow(cuenta.propinaEscala);
    final cien = BigInt.from(100);
    final numerador =
        cuenta.montoCoeficiente *
        (cien * factorEscalaPropina + cuenta.propinaCoeficiente);
    final denominador = factorEscalaMonto * cien * factorEscalaPropina * cuenta.personas;

    return Resultado(
      centavosPorPersona: estrategia.redondear(numerador, denominador),
    );
  }
}
