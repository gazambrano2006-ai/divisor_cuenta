import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/main.dart' as aplicacion;

/// Prueba la apertura y los seis casos mientras el arnés impide clientes HTTP.
void main() {
  const casos = [
    (
      id: 'CA-001',
      monto: '100.00',
      personas: '4',
      propina: '10',
      modo: 'Exacto',
      salida: '27.50',
      error: false,
    ),
    (
      id: 'CA-002',
      monto: '90.00',
      personas: '3',
      propina: '0',
      modo: 'Exacto',
      salida: '30.00',
      error: false,
    ),
    (
      id: 'CA-003',
      monto: '50.00',
      personas: '0',
      propina: '0',
      modo: 'Exacto',
      salida: 'Debe haber al menos una persona',
      error: true,
    ),
    (
      id: 'CA-004',
      monto: 'abc',
      personas: '3',
      propina: '0',
      modo: 'Exacto',
      salida: 'Monto inválido',
      error: true,
    ),
    (
      id: 'CA-005',
      monto: '10.00',
      personas: '3',
      propina: '0',
      modo: 'Exacto',
      salida: '3.33',
      error: false,
    ),
    (
      id: 'CA-006',
      monto: '10.00',
      personas: '3',
      propina: '0',
      modo: 'Hacia arriba',
      salida: '4.00',
      error: false,
    ),
  ];

  for (final caso in casos) {
    testWidgets('Sin conexión: ${caso.id}', (probador) async {
      var intentosHttp = 0;
      await HttpOverrides.runZoned(
        () async {
          await probador.pumpWidget(aplicacion.crearAplicacion());
          expect(find.byKey(const ValueKey('resultado')), findsNothing);
          await probador.enterText(find.byType(TextField).at(0), caso.monto);
          await probador.enterText(find.byType(TextField).at(1), caso.personas);
          await probador.enterText(find.byType(TextField).at(2), caso.propina);
          await probador.tap(find.byKey(const ValueKey('modo')));
          await probador.pumpAndSettle();
          await probador.tap(find.text(caso.modo).last);
          await probador.pumpAndSettle();
          await probador.ensureVisible(find.text('Calcular'));
          await probador.tap(find.text('Calcular'));
          await probador.pumpAndSettle();

          if (caso.error) {
            expect(find.text(caso.salida), findsOneWidget);
            expect(find.byKey(const ValueKey('resultado')), findsNothing);
          } else {
            expect(find.text('${caso.salida} por persona'), findsOneWidget);
            expect(find.byKey(const ValueKey('error')), findsNothing);
          }
          expect(intentosHttp, 0);
          expect(probador.takeException(), isNull);
        },
        // Recibe el contexto TLS del SDK; impide cualquier cliente de red y
        // produce un error de prueba si el flujo intenta crearlo.
        createHttpClient: (contexto) {
          intentosHttp++;
          throw StateError('La prueba impide crear clientes HTTP');
        },
      );
    });
  }
}
