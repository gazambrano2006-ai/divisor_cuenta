import '../domain/estrategia_redondeo.dart';

/// Eleva la fracción original a la unidad entera más cercana hacia arriba.
class RedondeoHaciaArriba implements EstrategiaRedondeo {
  /// Crea la regla independiente, sin recibir valores ni producir errores.
  const RedondeoHaciaArriba();

  /// Obtiene el techo entero para separar esta regla del cálculo y formato.
  ///
  /// Recibe [numerador] no negativo y [denominador] positivo; devuelve centavos
  /// no negativos. No produce errores cuando se cumplen esas precondiciones.
  @override
  BigInt redondear(BigInt numerador, BigInt denominador) {
    final cociente = numerador ~/ denominador;
    final residuo = numerador % denominador;
    final enteroSuperior = residuo > BigInt.zero
        ? cociente + BigInt.one
        : cociente;

    return enteroSuperior * BigInt.from(100);
  }
}
