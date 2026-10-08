import '../domain/contratos_divisor.dart';
import '../domain/cuenta.dart';
import '../domain/estrategia_redondeo.dart';
import 'formateador_moneda.dart';

/// Coordina las dependencias recibidas sin construir servicios de otras capas.
class DivisorController {
  /// Conserva colaboradores explícitos para coordinar el flujo sin acoplar capas.
  ///
  /// Recibe contratos, formateador y registro; crea un controlador configurado.
  /// Un registro vacío produce [ArgumentError] por composición inválida.
  DivisorController({
    required ValidacionEntrada validarEntrada,
    required DivisionCuenta calcularDivision,
    required FormateadorMoneda formateadorMoneda,
    required Map<String, EstrategiaRedondeo> estrategias,
  }) : _validarEntrada = validarEntrada,
       _calcularDivision = calcularDivision,
       _formateadorMoneda = formateadorMoneda,
       _estrategias = Map.unmodifiable(estrategias) {
    if (_estrategias.isEmpty) {
      throw ArgumentError('Debe registrarse al menos una estrategia');
    }
  }

  final ValidacionEntrada _validarEntrada;
  final DivisionCuenta _calcularDivision;
  final FormateadorMoneda _formateadorMoneda;
  final Map<String, EstrategiaRedondeo> _estrategias;

  /// Expone las etiquetas inyectadas para construir el selector sin conocer data.
  ///
  /// Lee el registro y devuelve una lista de solo lectura; no produce errores
  /// cuando el controlador tiene una composición válida.
  List<String> get modos => List.unmodifiable(_estrategias.keys);

  /// Coordina validación, selección, cálculo y formato del pago individual.
  ///
  /// Recibe los tres textos y el modo; devuelve solo resultado o solo el mensaje
  /// de entrada inválida, sin prefijos, para mostrar una salida excluyente.
  /// Una clave ausente produce [StateError], pues indica composición inválida.
  /// Los errores de programación de los colaboradores se propagan.
  ({String? resultado, String? error}) calcular({
    required String monto,
    required String personas,
    required String propina,
    required String modo,
  }) {
    final Cuenta cuenta;
    try {
      cuenta = _validarEntrada(
        monto: monto,
        personas: personas,
        propina: propina,
      );
    } on ArgumentError catch (error) {
      return (resultado: null, error: error.message as String);
    }
    final estrategia = _estrategias[modo];
    if (estrategia == null) {
      throw StateError('El modo no está registrado: $modo');
    }
    final resultado = _calcularDivision(cuenta, estrategia);
    return (resultado: _formateadorMoneda.formatear(resultado), error: null);
  }
}
