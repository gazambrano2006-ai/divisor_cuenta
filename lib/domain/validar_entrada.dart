import 'cuenta.dart';

/// Comprueba y analiza textos sin calcular, redondear ni formatear pagos.
class ValidarEntrada {
  /// Crea el servicio que protege las precondiciones del cálculo.
  ///
  /// No recibe dependencias, conserva estado ni produce errores de entrada.
  const ValidarEntrada();

  static final RegExp _patronDecimal = RegExp(r'^[0-9]+(?:\.[0-9]+)?$');
  static final RegExp _patronPersonas = RegExp(r'^-?[0-9]+$');

  /// Valida los textos en orden monto, personas y propina para crear la cuenta.
  ///
  /// Recibe las tres entradas y devuelve una [Cuenta] válida, conservando todas
  /// las cifras. Lanza [ArgumentError] con el mensaje del primer campo inválido;
  /// así ninguna entrada incorrecta llega al cálculo.
  Cuenta ejecutar({
    required String monto,
    required String personas,
    required String propina,
  }) {
    final montoAnalizado = _analizarDecimal(monto, 'Monto inválido');
    final personasAnalizadas = _analizarPersonas(personas);
    final propinaAnalizada = _analizarDecimal(propina, 'Propina inválida');

    return Cuenta(
      montoCoeficiente: montoAnalizado.coeficiente,
      montoEscala: montoAnalizado.escala,
      personas: personasAnalizadas,
      propinaCoeficiente: propinaAnalizada.coeficiente,
      propinaEscala: propinaAnalizada.escala,
    );
  }

  /// Analiza un decimal no negativo para reutilizar la validación de dos campos.
  ///
  /// Recibe el texto y su mensaje de error; devuelve coeficiente y escala sin
  /// conversión a double ni límites arbitrarios. Lanza [ArgumentError] con
  /// [mensaje] si el texto vacío o no numérico incumple el formato decimal.
  ({BigInt coeficiente, int escala}) _analizarDecimal(
    String texto,
    String mensaje,
  ) {
    final entrada = texto.trim();
    if (!_patronDecimal.hasMatch(entrada)) {
      throw ArgumentError(mensaje);
    }

    final posicionPunto = entrada.indexOf('.');
    final escala = posicionPunto == -1 ? 0 : entrada.length - posicionPunto - 1;
    final coeficiente = BigInt.parse(entrada.replaceAll('.', ''));

    return (coeficiente: coeficiente, escala: escala);
  }

  /// Analiza personas en base diez para asegurar un divisor entero positivo.
  ///
  /// Recibe el texto y devuelve un [BigInt] mayor que cero. Lanza [ArgumentError]
  /// con "Debe haber al menos una persona" para cero o negativos; usa
  /// "Número de personas inválido" para los demás textos incorrectos.
  BigInt _analizarPersonas(String texto) {
    final entrada = texto.trim();
    if (!_patronPersonas.hasMatch(entrada)) {
      throw ArgumentError('Número de personas inválido');
    }

    final personas = BigInt.parse(entrada);
    if (personas <= BigInt.zero) {
      throw ArgumentError('Debe haber al menos una persona');
    }

    return personas;
  }
}
