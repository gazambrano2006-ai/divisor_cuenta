import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/main.dart' as aplicacion;

void main() {
  testWidgets(
    'una pantalla muestra tres entradas y no presenta salida inicial',
    (tester) async {
      await tester.pumpWidget(aplicacion.crearAplicacion());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Monto total'), findsOneWidget);
      expect(find.text('Número de personas'), findsOneWidget);
      expect(find.text('Propina (%)'), findsOneWidget);
      expect(find.text('Redondeo'), findsOneWidget);
      expect(find.text('Calcular'), findsOneWidget);
      expect(find.byKey(const ValueKey('resultado')), findsNothing);
      expect(find.byKey(const ValueKey('error')), findsNothing);
    },
  );

  final casos =
      <
        ({
          String nombre,
          String monto,
          String personas,
          String propina,
          String pago,
        })
      >[
        (
          nombre: 'CA-001 cuenta con propina',
          monto: '100.00',
          personas: '4',
          propina: '10',
          pago: '27.50',
        ),
        (
          nombre: 'CA-002 cuenta sin propina',
          monto: '90.00',
          personas: '3',
          propina: '0',
          pago: '30.00',
        ),
        (
          nombre: 'CA-005 división con sobrante',
          monto: '10.00',
          personas: '3',
          propina: '0',
          pago: '3.33',
        ),
        (
          nombre: 'una persona es válida',
          monto: '100.00',
          personas: '1',
          propina: '10',
          pago: '110.00',
        ),
        (
          nombre: 'monto cero es válido',
          monto: '0',
          personas: '3',
          propina: '10',
          pago: '0.00',
        ),
        (
          nombre: 'empate se redondea al centavo superior',
          monto: '1.005',
          personas: '1',
          propina: '0',
          pago: '1.01',
        ),
      ];

  for (final caso in casos) {
    testWidgets('Exacto: ${caso.nombre}', (tester) async {
      await tester.pumpWidget(aplicacion.crearAplicacion());
      await _ingresar(tester, caso.monto, caso.personas, caso.propina);

      expect(find.byKey(const ValueKey('resultado')), findsNothing);
      await tester.tap(find.text('Calcular'));
      await tester.pump();

      expect(find.text('${caso.pago} por persona'), findsOneWidget);
      expect(find.byKey(const ValueKey('error')), findsNothing);
    });
  }

  testWidgets('editar entradas conserva el pago hasta pulsar Calcular', (
    tester,
  ) async {
    await tester.pumpWidget(aplicacion.crearAplicacion());
    await _ingresar(tester, '100.00', '4', '10');
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('27.50 por persona'), findsOneWidget);

    await _ingresar(tester, '90.00', '3', '0');
    await tester.pump();
    expect(find.text('27.50 por persona'), findsOneWidget);
    expect(find.text('30.00 por persona'), findsNothing);

    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('30.00 por persona'), findsOneWidget);
    expect(find.text('27.50 por persona'), findsNothing);
  });

  final invalidos =
      <
        ({
          String nombre,
          String monto,
          String personas,
          String propina,
          String mensaje,
        })
      >[
        (
          nombre: 'CA-003',
          monto: '50.00',
          personas: '0',
          propina: '0',
          mensaje: 'Debe haber al menos una persona',
        ),
        (
          nombre: 'CA-004',
          monto: 'abc',
          personas: '3',
          propina: '0',
          mensaje: 'Monto inválido',
        ),
        (
          nombre: 'personas negativas',
          monto: '50.00',
          personas: '-1',
          propina: '0',
          mensaje: 'Debe haber al menos una persona',
        ),
        (
          nombre: 'personas vacías',
          monto: '50.00',
          personas: '',
          propina: '0',
          mensaje: 'Número de personas inválido',
        ),
        (
          nombre: 'personas no numéricas',
          monto: '50.00',
          personas: 'abc',
          propina: '0',
          mensaje: 'Número de personas inválido',
        ),
        (
          nombre: 'personas fraccionarias',
          monto: '50.00',
          personas: '1.5',
          propina: '0',
          mensaje: 'Número de personas inválido',
        ),
        (
          nombre: 'monto vacío',
          monto: '',
          personas: '3',
          propina: '0',
          mensaje: 'Monto inválido',
        ),
        (
          nombre: 'monto negativo',
          monto: '-1',
          personas: '3',
          propina: '0',
          mensaje: 'Monto inválido',
        ),
        (
          nombre: 'monto NaN',
          monto: 'NaN',
          personas: '3',
          propina: '0',
          mensaje: 'Monto inválido',
        ),
        (
          nombre: 'monto infinito',
          monto: 'Infinity',
          personas: '3',
          propina: '0',
          mensaje: 'Monto inválido',
        ),
        (
          nombre: 'propina vacía',
          monto: '50.00',
          personas: '3',
          propina: '',
          mensaje: 'Propina inválida',
        ),
        (
          nombre: 'propina no numérica',
          monto: '50.00',
          personas: '3',
          propina: 'abc',
          mensaje: 'Propina inválida',
        ),
        (
          nombre: 'propina negativa',
          monto: '50.00',
          personas: '3',
          propina: '-1',
          mensaje: 'Propina inválida',
        ),
        (
          nombre: 'propina NaN',
          monto: '50.00',
          personas: '3',
          propina: 'NaN',
          mensaje: 'Propina inválida',
        ),
        (
          nombre: 'propina infinita',
          monto: '50.00',
          personas: '3',
          propina: 'Infinity',
          mensaje: 'Propina inválida',
        ),
      ];
  for (final caso in invalidos) {
    final situaciones = caso.nombre.startsWith('CA-') ? [false, true] : [true];
    for (final despuesDeResultado in situaciones) {
      testWidgets('${caso.nombre}, resultado previo: $despuesDeResultado', (
        tester,
      ) async {
        await tester.pumpWidget(aplicacion.crearAplicacion());
        if (despuesDeResultado) {
          await _ingresar(tester, '100.00', '4', '10');
          await tester.tap(find.text('Calcular'));
          await tester.pump();
          expect(find.text('27.50 por persona'), findsOneWidget);
        }

        await _ingresar(tester, caso.monto, caso.personas, caso.propina);
        await tester.tap(find.text('Calcular'));
        await tester.pump();

        expect(find.text(caso.mensaje), findsOneWidget);
        expect(find.byKey(const ValueKey('error')), findsOneWidget);
        expect(find.byKey(const ValueKey('resultado')), findsNothing);
        expect(find.text('27.50 por persona'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'corregir y pulsar Calcular reemplaza el error por un resultado',
    (tester) async {
      await tester.pumpWidget(aplicacion.crearAplicacion());
      await _ingresar(tester, 'abc', '4', '10');
      await tester.tap(find.text('Calcular'));
      await tester.pump();
      expect(find.text('Monto inválido'), findsOneWidget);
      expect(find.byKey(const ValueKey('resultado')), findsNothing);

      await _ingresar(tester, '100.00', '4', '10');
      await tester.pump();
      expect(find.text('Monto inválido'), findsOneWidget);
      expect(find.byKey(const ValueKey('resultado')), findsNothing);

      await tester.tap(find.text('Calcular'));
      await tester.pump();
      expect(find.text('27.50 por persona'), findsOneWidget);
      expect(find.byKey(const ValueKey('error')), findsNothing);
      expect(find.text('Monto inválido'), findsNothing);
    },
  );

  final haciaArriba =
      <
        ({
          String nombre,
          String monto,
          String personas,
          String propina,
          String pago,
        })
      >[
        (
          nombre: 'CA-006',
          monto: '10.00',
          personas: '3',
          propina: '0',
          pago: '4.00',
        ),
        (
          nombre: 'entero no aumenta',
          monto: '90.00',
          personas: '3',
          propina: '0',
          pago: '30.00',
        ),
        (
          nombre: 'cociente original sin redondeo previo',
          monto: '3.001',
          personas: '1',
          propina: '0',
          pago: '4.00',
        ),
        (
          nombre: 'una persona',
          monto: '10.01',
          personas: '1',
          propina: '10',
          pago: '12.00',
        ),
        (
          nombre: 'monto cero',
          monto: '0',
          personas: '3',
          propina: '10',
          pago: '0.00',
        ),
      ];
  for (final caso in haciaArriba) {
    testWidgets('Hacia arriba: ${caso.nombre}', (tester) async {
      await tester.pumpWidget(aplicacion.crearAplicacion());
      await _ingresar(tester, caso.monto, caso.personas, caso.propina);
      await _elegirModo(tester, 'Hacia arriba');
      expect(find.byKey(const ValueKey('resultado')), findsNothing);

      await tester.tap(find.text('Calcular'));
      await tester.pump();

      expect(find.text('${caso.pago} por persona'), findsOneWidget);
      expect(find.byKey(const ValueKey('error')), findsNothing);
    });
  }

  testWidgets('alternar modos conserva el resultado hasta pulsar Calcular', (
    tester,
  ) async {
    await tester.pumpWidget(aplicacion.crearAplicacion());
    await _ingresar(tester, '10.00', '3', '0');
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('3.33 por persona'), findsOneWidget);

    await _elegirModo(tester, 'Hacia arriba');
    expect(find.text('3.33 por persona'), findsOneWidget);
    expect(find.text('4.00 por persona'), findsNothing);
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('4.00 por persona'), findsOneWidget);
    expect(find.text('3.33 por persona'), findsNothing);

    await _elegirModo(tester, 'Exacto');
    expect(find.text('4.00 por persona'), findsOneWidget);
    expect(find.text('3.33 por persona'), findsNothing);
    await tester.tap(find.text('Calcular'));
    await tester.pump();
    expect(find.text('3.33 por persona'), findsOneWidget);
    expect(find.text('4.00 por persona'), findsNothing);
  });
}

Future<void> _ingresar(
  WidgetTester tester,
  String monto,
  String personas,
  String propina,
) async {
  await tester.enterText(find.byType(TextField).at(0), monto);
  await tester.enterText(find.byType(TextField).at(1), personas);
  await tester.enterText(find.byType(TextField).at(2), propina);
}

Future<void> _elegirModo(WidgetTester tester, String modo) async {
  await tester.tap(find.byKey(const ValueKey('modo')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(modo).last);
  await tester.pumpAndSettle();
}
