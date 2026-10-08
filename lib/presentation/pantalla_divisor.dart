import 'package:flutter/material.dart';

import 'divisor_controller.dart';

class PantallaDivisor extends StatefulWidget {
  /// Recibe un controlador ya compuesto para mostrar el flujo en una pantalla.
  ///
  /// Crea la configuración del widget; no calcula ni produce errores de entrada.
  const PantallaDivisor({super.key, required this.controlador});

  final DivisorController controlador;

  /// Crea el estado local que exige Flutter para entradas y salidas editables.
  ///
  /// No recibe argumentos; devuelve el estado de la pantalla sin errores de entrada.
  @override
  State<PantallaDivisor> createState() => _EstadoPantallaDivisor();
}

class _EstadoPantallaDivisor extends State<PantallaDivisor> {
  String _monto = '';
  String _personas = '';
  String _propina = '';
  late String _modo = widget.controlador.modos.first;
  String? _resultado;
  String? _error;

  /// Pide una operación con las entradas vigentes y actualiza juntas sus salidas.
  ///
  /// No recibe argumentos ni devuelve valor. Los errores de entrada llegarán
  /// en la salida del controlador; no captura errores de programación.
  void _calcular() {
    final salida = widget.controlador.calcular(
      monto: _monto,
      personas: _personas,
      propina: _propina,
      modo: _modo,
    );
    setState(() {
      _resultado = salida.resultado;
      _error = salida.error;
    });
  }

  /// Dibuja el formulario y la salida para mantener todo el flujo en una pantalla.
  ///
  /// Recibe el contexto de Flutter y devuelve widgets; no valida ni calcula,
  /// y no produce errores de entrada.
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dividir la cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '¿Cuánto paga cada persona?',
                    style: tema.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Monto total',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.next,
                    // Guarda el texto recibido para Calcular; devuelve void sin validar.
                    onChanged: (texto) => _monto = texto,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Número de personas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    textInputAction: TextInputAction.next,
                    // Conserva las personas recibidas para el botón, sin validar ni devolver valor.
                    onChanged: (texto) => _personas = texto,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Propina (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    textInputAction: TextInputAction.done,
                    // Conserva el porcentaje recibido para Calcular; devuelve void sin errores.
                    onChanged: (texto) => _propina = texto,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('modo'),
                    initialValue: _modo,
                    decoration: const InputDecoration(
                      labelText: 'Redondeo',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final modo in widget.controlador.modos)
                        DropdownMenuItem(value: modo, child: Text(modo)),
                    ],
                    // Guarda la opción recibida mediante setState; devuelve void sin calcular.
                    onChanged: (modo) {
                      if (modo == null) return;
                      setState(() => _modo = modo);
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _calcular,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Calcular'),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        key: const ValueKey('error'),
                        style: tema.textTheme.bodyLarge?.copyWith(
                          color: tema.colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (_error == null && _resultado != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_resultado por persona',
                        key: const ValueKey('resultado'),
                        style: tema.textTheme.titleLarge?.copyWith(
                          color: tema.colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
