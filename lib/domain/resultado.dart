/// Pago individual numérico después de aplicar la estrategia de redondeo.
class Resultado {
  /// Conserva los centavos finales para que presentación pueda formatearlos.
  ///
  /// Recibe centavos no negativos y crea un valor inmutable; no valida entradas
  /// ni produce sus errores, porque el cálculo recibe una cuenta válida.
  const Resultado({required this.centavosPorPersona});

  /// Importe individual final en centavos, mayor o igual que cero.
  final BigInt centavosPorPersona;
}
