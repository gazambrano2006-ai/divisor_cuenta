import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/main.dart' as aplicacion;

/// Comprueba las tres interacciones pedidas sobre la pantalla real.
void main() {
  testWidgets('100, 4 y 10 muestran 27.50 por persona', (tester) async {
    await tester.pumpWidget(aplicacion.crearAplicacion());
    await tester.enterText(find.byType(TextField).at(0), '100');
    await tester.enterText(find.byType(TextField).at(1), '4');
    await tester.enterText(find.byType(TextField).at(2), '10');

    await tester.ensureVisible(find.text('Calcular'));
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('27.50 por persona'), findsOneWidget);
  });

  testWidgets('cero personas muestra el error sin ningún resultado', (
    tester,
  ) async {
    await tester.pumpWidget(aplicacion.crearAplicacion());
    await tester.enterText(find.byType(TextField).at(0), '50');
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.enterText(find.byType(TextField).at(2), '0');

    await tester.ensureVisible(find.text('Calcular'));
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('Debe haber al menos una persona'), findsOneWidget);
    expect(find.byKey(const ValueKey('resultado')), findsNothing);
  });

  testWidgets('abc en el monto muestra Monto inválido', (tester) async {
    await tester.pumpWidget(aplicacion.crearAplicacion());
    await tester.enterText(find.byType(TextField).at(0), 'abc');
    await tester.enterText(find.byType(TextField).at(1), '3');
    await tester.enterText(find.byType(TextField).at(2), '0');

    await tester.ensureVisible(find.text('Calcular'));
    await tester.tap(find.text('Calcular'));
    await tester.pump();

    expect(find.text('Monto inválido'), findsOneWidget);
    expect(find.byKey(const ValueKey('resultado')), findsNothing);
  });
}
