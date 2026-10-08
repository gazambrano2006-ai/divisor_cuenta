import 'cuenta.dart';
import 'estrategia_redondeo.dart';
import 'resultado.dart';

/// Valida tres textos sin que presentación conozca una implementación concreta.
///
/// Recibe monto, personas y porcentaje de propina; devuelve una cuenta válida.
/// Ante entradas inválidas lanza [ArgumentError] con un mensaje de tipo String.
typedef ValidacionEntrada = Cuenta Function({
  required String monto,
  required String personas,
  required String propina,
});

/// Calcula mediante un contrato inyectable, independiente de implementaciones.
///
/// Recibe una cuenta válida y una estrategia; devuelve los centavos finales.
/// No produce errores cuando se cumplen las precondiciones de ambos valores.
typedef DivisionCuenta = Resultado Function(
  Cuenta cuenta,
  EstrategiaRedondeo estrategia,
);
