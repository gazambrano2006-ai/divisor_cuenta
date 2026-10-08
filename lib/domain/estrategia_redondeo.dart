/// Regla intercambiable que convierte una fracción individual a centavos.
abstract interface class EstrategiaRedondeo {
  /// Redondea el pago para separar esta regla del cálculo y del formato.
  ///
  /// Recibe un [numerador] no negativo y un [denominador] positivo. Devuelve
  /// centavos no negativos. No produce errores con esas precondiciones; una
  /// llamada que las incumpla es un error de programación, no de entrada.
  BigInt redondear(BigInt numerador, BigInt denominador);
}
