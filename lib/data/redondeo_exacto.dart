import '../domain/estrategia_redondeo.dart';

/// Escoge el centavo más cercano y resuelve sus empates hacia arriba.
class RedondeoExacto implements EstrategiaRedondeo {
  /// Crea la regla independiente, sin recibir valores ni producir errores.
  const RedondeoExacto();

  /// Redondea la fracción para mantener esta regla fuera del cálculo y formato.
  ///
  /// Recibe [numerador] no negativo y [denominador] positivo; devuelve centavos
  /// no negativos. No produce errores cuando se cumplen esas precondiciones.
  @override
  BigInt redondear(BigInt numerador, BigInt denominador) {
    final centavosNumerador = numerador * BigInt.from(100);
    final cociente = centavosNumerador ~/ denominador;
    final residuo = centavosNumerador % denominador;

    return residuo * BigInt.from(2) >= denominador
        ? cociente + BigInt.one
        : cociente;
  }
}
