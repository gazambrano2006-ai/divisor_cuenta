import 'package:flutter/material.dart';

import 'data/redondeo_exacto.dart';
import 'data/redondeo_hacia_arriba.dart';
import 'domain/calcular_division.dart';
import 'domain/estrategia_redondeo.dart';
import 'domain/validar_entrada.dart';
import 'presentation/divisor_controller.dart';
import 'presentation/formateador_moneda.dart';
import 'presentation/pantalla_divisor.dart';

/// Arranca la pantalla conectada para permitir dividir la cuenta.
/// No recibe entradas y devuelve void; los errores de usuario se tratan al calcular.
void main() {
  runApp(crearAplicacion());
}

/// Construye y conecta las dependencias de producción en un único lugar.
///
/// No recibe argumentos y devuelve la aplicación lista para Flutter o su arnés
/// de pruebas. No valida datos del usuario ni produce errores de entrada;
/// proporciona un registro de estrategias no vacío a la presentación.
Widget crearAplicacion() {
  const validador = ValidarEntrada();
  const calculo = CalcularDivision();
  const formateador = FormateadorMoneda();
  final estrategias = Map<String, EstrategiaRedondeo>.unmodifiable({
    'Exacto': const RedondeoExacto(),
    'Hacia arriba': const RedondeoHaciaArriba(),
  });
  final controlador = DivisorController(
    validarEntrada: validador.ejecutar,
    calcularDivision: calculo.ejecutar,
    formateadorMoneda: formateador,
    estrategias: estrategias,
  );

  return MaterialApp(
    title: 'Dividir la cuenta',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    home: PantallaDivisor(controlador: controlador),
  );
}
