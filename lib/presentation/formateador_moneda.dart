import '../domain/resultado.dart';

/// Presenta los centavos finales sin elegir una regla de redondeo.
class FormateadorMoneda {
  /// Crea el formateador sin dependencias, estado ni errores de entrada.
  const FormateadorMoneda();

  /// Convierte un resultado válido en texto de unidades y dos cifras decimales.
  ///
  /// Recibe los centavos finales y devuelve, por ejemplo, "3.33" o "4.00".
  /// Separa la presentación del cálculo; no redondea ni produce errores
  /// mientras el resultado respete su contrato de centavos no negativos.
  String formatear(Resultado resultado) {
    final cien = BigInt.from(100);
    final unidades = resultado.centavosPorPersona ~/ cien;
    final centavos = (resultado.centavosPorPersona % cien).toString().padLeft(
      2,
      '0',
    );
    return '$unidades.$centavos';
  }
}
