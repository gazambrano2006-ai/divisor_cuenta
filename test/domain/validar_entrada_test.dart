import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/domain/validar_entrada.dart';

void main() {
  const validador = ValidarEntrada();

  group('ValidarEntrada: entradas válidas', () {
    test('interpreta monto y propina sin perder sus cifras decimales', () {
      final cuenta = validador.ejecutar(
        monto: '100.00',
        personas: '4',
        propina: '10',
      );

      expect(cuenta.montoCoeficiente, BigInt.from(10000));
      expect(cuenta.montoEscala, 2);
      expect(cuenta.personas, BigInt.from(4));
      expect(cuenta.propinaCoeficiente, BigInt.from(10));
      expect(cuenta.propinaEscala, 0);
    });

    test('quita espacios externos de las tres entradas', () {
      final cuenta = validador.ejecutar(
        monto: ' \t90.00 \n',
        personas: ' 3 ',
        propina: ' 0.25 ',
      );

      expect(cuenta.montoCoeficiente, BigInt.from(9000));
      expect(cuenta.montoEscala, 2);
      expect(cuenta.personas, BigInt.from(3));
      expect(cuenta.propinaCoeficiente, BigInt.from(25));
      expect(cuenta.propinaEscala, 2);
    });

    test('admite una persona, monto cero y propina cero', () {
      final cuenta = validador.ejecutar(
        monto: '0.00',
        personas: '1',
        propina: '0',
      );

      expect(cuenta.montoCoeficiente, BigInt.zero);
      expect(cuenta.montoEscala, 2);
      expect(cuenta.personas, BigInt.one);
      expect(cuenta.propinaCoeficiente, BigInt.zero);
      expect(cuenta.propinaEscala, 0);
    });

    test('conserva ceros decimales sin redondear previamente', () {
      final cuenta = validador.ejecutar(
        monto: '0001.0050',
        personas: '2',
        propina: '0.123400',
      );

      expect(cuenta.montoCoeficiente, BigInt.from(10050));
      expect(cuenta.montoEscala, 4);
      expect(cuenta.propinaCoeficiente, BigInt.from(123400));
      expect(cuenta.propinaEscala, 6);
    });

    test('no impone límites máximos ni precisión de double', () {
      final cuenta = validador.ejecutar(
        monto: '123456789012345678901234567890.12345678901234567890',
        personas: '123456789012345678901234567890',
        propina: '987654321098765432109876543210.00000000000000000001',
      );

      expect(
        cuenta.montoCoeficiente,
        BigInt.parse('12345678901234567890123456789012345678901234567890'),
      );
      expect(cuenta.montoEscala, 20);
      expect(cuenta.personas, BigInt.parse('123456789012345678901234567890'));
      expect(
        cuenta.propinaCoeficiente,
        BigInt.parse('98765432109876543210987654321000000000000000000001'),
      );
      expect(cuenta.propinaEscala, 20);
    });
  });

  group('ValidarEntrada: monto inválido', () {
    for (final monto in [
      '',
      '   ',
      'abc',
      '-1',
      '-0.01',
      'NaN',
      'Infinity',
      '-Infinity',
    ]) {
      test('rechaza "$monto" con el mensaje exacto', () {
        expect(
          () => validador.ejecutar(monto: monto, personas: '3', propina: '0'),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'message',
              'Monto inválido',
            ),
          ),
        );
      });
    }
  });

  group('ValidarEntrada: personas inválidas', () {
    for (final personas in ['0', '-1', '-999999999999999999999999999999']) {
      test('rechaza "$personas" con el mensaje obligatorio', () {
        expect(
          () => validador.ejecutar(
            monto: '50.00',
            personas: personas,
            propina: '0',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'message',
              'Debe haber al menos una persona',
            ),
          ),
        );
      });
    }

    for (final personas in [
      '',
      '   ',
      'abc',
      '1.5',
      '3.0',
      'NaN',
      'Infinity',
    ]) {
      test('rechaza el entero inválido "$personas"', () {
        expect(
          () => validador.ejecutar(
            monto: '50.00',
            personas: personas,
            propina: '0',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'message',
              'Número de personas inválido',
            ),
          ),
        );
      });
    }
  });

  group('ValidarEntrada: propina inválida', () {
    for (final propina in [
      '',
      '   ',
      'abc',
      '-1',
      '-0.01',
      'NaN',
      'Infinity',
      '-Infinity',
    ]) {
      test('rechaza "$propina" con el mensaje del contrato', () {
        expect(
          () => validador.ejecutar(
            monto: '50.00',
            personas: '3',
            propina: propina,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'message',
              'Propina inválida',
            ),
          ),
        );
      });
    }
  });

  group('ValidarEntrada: orden de comprobación', () {
    test('comunica el error de monto antes que personas y propina', () {
      expect(
        () => validador.ejecutar(monto: 'abc', personas: '0', propina: 'abc'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Monto inválido',
          ),
        ),
      );
    });

    test('comunica el error de personas antes que propina', () {
      expect(
        () => validador.ejecutar(monto: '50.00', personas: '0', propina: 'abc'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Debe haber al menos una persona',
          ),
        ),
      );
    });

    test('valida propina después de monto y personas válidos', () {
      expect(
        () => validador.ejecutar(monto: '50.00', personas: '1', propina: 'abc'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Propina inválida',
          ),
        ),
      );
    });
  });
}
