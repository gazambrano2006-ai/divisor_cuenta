/// Datos numéricos de una cuenta validada, sin cálculo ni formato.
class Cuenta {
  /// Conserva coeficientes, escalas y personas para el cálculo exacto.
  ///
  /// Recibe valores ya validados y crea una cuenta inmutable. No produce
  /// errores de entrada: comprobar sus precondiciones corresponde al validador.
  const Cuenta({
    required this.montoCoeficiente,
    required this.montoEscala,
    required this.personas,
    required this.propinaCoeficiente,
    required this.propinaEscala,
  });

  /// Cifras del monto sin punto decimal; mayor o igual que cero.
  final BigInt montoCoeficiente;

  /// Cantidad de cifras decimales del monto; mayor o igual que cero.
  final int montoEscala;

  /// Cantidad entera de personas; mayor o igual que uno.
  final BigInt personas;

  /// Cifras del porcentaje de propina sin punto; mayor o igual que cero.
  final BigInt propinaCoeficiente;

  /// Cantidad de cifras decimales del porcentaje; mayor o igual que cero.
  final int propinaEscala;
}
