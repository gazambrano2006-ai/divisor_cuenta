import 'package:flutter_test/flutter_test.dart';
import 'package:participacion7/domain/cuenta.dart';
import 'package:participacion7/domain/estrategia_redondeo.dart';
import 'package:participacion7/domain/resultado.dart';
import 'package:participacion7/presentation/divisor_controller.dart';
import 'package:participacion7/presentation/formateador_moneda.dart';

void main() {
  test('valida, calcula y formatea usando las dependencias inyectadas', () {
    final llamadas = <String>[];
    final cuenta = _crearCuenta();
    final resultado = Resultado(centavosPorPersona: BigInt.from(2750));
    const estrategia = _EstrategiaPrueba();
    final controlador = DivisorController(
      validarEntrada: ({required monto, required personas, required propina}) {
        llamadas.add('validar');
        expect((monto, personas, propina), ('100.00', '4', '10'));
        return cuenta;
      },
      calcularDivision: (entrada, regla) {
        llamadas.add('calcular');
        expect(entrada, same(cuenta));
        expect(regla, same(estrategia));
        return resultado;
      },
      formateadorMoneda: _FormateadorRegistrador(llamadas, resultado),
      estrategias: {'Exacto': estrategia},
    );

    final salida = controlador.calcular(
      monto: '100.00',
      personas: '4',
      propina: '10',
      modo: 'Exacto',
    );

    expect(llamadas, ['validar', 'calcular', 'formatear']);
    expect(salida, (resultado: '27.50', error: null));
  });

  test('obtiene opciones del registro y conserva una copia inmutable', () {
    final registro = <String, EstrategiaRedondeo>{
      'Regla inyectada': const _EstrategiaPrueba(),
    };
    final controlador = _crearControlador(registro);

    registro.clear();

    expect(controlador.modos, ['Regla inyectada']);
    expect(() => controlador.modos.add('Otra'), throwsUnsupportedError);
    expect(
      controlador.calcular(
        monto: '100',
        personas: '4',
        propina: '10',
        modo: 'Regla inyectada',
      ),
      (resultado: '27.50', error: null),
    );
  });

  test('selecciona por clave sin depender de clases concretas de data', () {
    const primera = _EstrategiaPrueba(1);
    const segunda = _EstrategiaPrueba(2);
    EstrategiaRedondeo? seleccionada;
    final controlador = DivisorController(
      validarEntrada: ({required monto, required personas, required propina}) =>
          _crearCuenta(),
      calcularDivision: (cuenta, estrategia) {
        seleccionada = estrategia;
        return Resultado(centavosPorPersona: BigInt.from(2750));
      },
      formateadorMoneda: const FormateadorMoneda(),
      estrategias: {'Primera': primera, 'Segunda': segunda},
    );

    controlador.calcular(
      monto: '100',
      personas: '4',
      propina: '10',
      modo: 'Segunda',
    );

    expect(seleccionada, same(segunda));
    expect(controlador.modos, ['Primera', 'Segunda']);
  });

  test('rechaza una composición sin estrategias', () {
    expect(() => _crearControlador({}), throwsArgumentError);
  });

  test('una clave ausente es un error de programación', () {
    final controlador = _crearControlador({
      'Exacto': const _EstrategiaPrueba(),
    });

    expect(
      () => controlador.calcular(
        monto: '100',
        personas: '4',
        propina: '10',
        modo: 'Ausente',
      ),
      throwsStateError,
    );
  });

  final invalidos =
      <({String monto, String personas, String propina, String mensaje})>[
        (monto: 'abc', personas: '3', propina: '0', mensaje: 'Monto inválido'),
        (monto: '', personas: '3', propina: '0', mensaje: 'Monto inválido'),
        (monto: '-1', personas: '3', propina: '0', mensaje: 'Monto inválido'),
        (monto: 'NaN', personas: '3', propina: '0', mensaje: 'Monto inválido'),
        (
          monto: 'Infinity',
          personas: '3',
          propina: '0',
          mensaje: 'Monto inválido',
        ),
        (
          monto: '50.00',
          personas: '0',
          propina: '0',
          mensaje: 'Debe haber al menos una persona',
        ),
        (
          monto: '50.00',
          personas: '-1',
          propina: '0',
          mensaje: 'Debe haber al menos una persona',
        ),
        (
          monto: '50.00',
          personas: '',
          propina: '0',
          mensaje: 'Número de personas inválido',
        ),
        (
          monto: '50.00',
          personas: 'abc',
          propina: '0',
          mensaje: 'Número de personas inválido',
        ),
        (
          monto: '50.00',
          personas: '1.5',
          propina: '0',
          mensaje: 'Número de personas inválido',
        ),
        (
          monto: '50.00',
          personas: '3',
          propina: '',
          mensaje: 'Propina inválida',
        ),
        (
          monto: '50.00',
          personas: '3',
          propina: 'abc',
          mensaje: 'Propina inválida',
        ),
        (
          monto: '50.00',
          personas: '3',
          propina: '-1',
          mensaje: 'Propina inválida',
        ),
        (
          monto: '50.00',
          personas: '3',
          propina: 'NaN',
          mensaje: 'Propina inválida',
        ),
        (
          monto: '50.00',
          personas: '3',
          propina: 'Infinity',
          mensaje: 'Propina inválida',
        ),
      ];
  for (final caso in invalidos) {
    test(
      'entrada inválida (${caso.monto}/${caso.personas}/${caso.propina}) entrega solo su mensaje',
      () {
        final llamadas = <String>[];
        final resultado = Resultado(centavosPorPersona: BigInt.from(2750));
        final controlador = DivisorController(
          validarEntrada:
              ({required monto, required personas, required propina}) {
                llamadas.add('validar');
                expect(
                  (monto, personas, propina),
                  (caso.monto, caso.personas, caso.propina),
                );
                throw ArgumentError(caso.mensaje);
              },
          calcularDivision: (cuenta, estrategia) {
            llamadas.add('calcular');
            return resultado;
          },
          formateadorMoneda: _FormateadorRegistrador(llamadas, resultado),
          estrategias: {'Exacto': const _EstrategiaPrueba()},
        );

        final salida = controlador.calcular(
          monto: caso.monto,
          personas: caso.personas,
          propina: caso.propina,
          modo: 'Exacto',
        );

        expect(salida, (resultado: null, error: caso.mensaje));
        expect(llamadas, ['validar']);
      },
    );
  }

  test('una llamada válida posterior se recupera del error de entrada', () {
    final controlador = DivisorController(
      validarEntrada: ({required monto, required personas, required propina}) {
        if (monto == 'abc') throw ArgumentError('Monto inválido');
        return _crearCuenta();
      },
      calcularDivision: (cuenta, estrategia) =>
          Resultado(centavosPorPersona: BigInt.from(2750)),
      formateadorMoneda: const FormateadorMoneda(),
      estrategias: {'Exacto': const _EstrategiaPrueba()},
    );

    expect(
      controlador.calcular(
        monto: 'abc',
        personas: '4',
        propina: '10',
        modo: 'Exacto',
      ),
      (resultado: null, error: 'Monto inválido'),
    );
    expect(
      controlador.calcular(
        monto: '100.00',
        personas: '4',
        propina: '10',
        modo: 'Exacto',
      ),
      (resultado: '27.50', error: null),
    );
  });

  test('no transforma un ArgumentError producido por el cálculo', () {
    final controlador = DivisorController(
      validarEntrada: ({required monto, required personas, required propina}) =>
          _crearCuenta(),
      calcularDivision: (cuenta, estrategia) =>
          throw ArgumentError('Falla del cálculo'),
      formateadorMoneda: const FormateadorMoneda(),
      estrategias: {'Exacto': const _EstrategiaPrueba()},
    );

    expect(
      () => controlador.calcular(
        monto: '100.00',
        personas: '4',
        propina: '10',
        modo: 'Exacto',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Falla del cálculo',
        ),
      ),
    );
  });

  test('no transforma un ArgumentError producido por el formato', () {
    final controlador = DivisorController(
      validarEntrada: ({required monto, required personas, required propina}) =>
          _crearCuenta(),
      calcularDivision: (cuenta, estrategia) =>
          Resultado(centavosPorPersona: BigInt.from(2750)),
      formateadorMoneda: const _FormateadorConError(),
      estrategias: {'Exacto': const _EstrategiaPrueba()},
    );

    expect(
      () => controlador.calcular(
        monto: '100.00',
        personas: '4',
        propina: '10',
        modo: 'Exacto',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Falla del formato',
        ),
      ),
    );
  });

  test(
    'dos implementaciones distintas se sustituyen mediante el mismo contrato',
    () {
      final controlador = DivisorController(
        validarEntrada: ({
          required monto,
          required personas,
          required propina,
        }) => _crearCuenta(),
        calcularDivision: (cuenta, estrategia) => Resultado(
          centavosPorPersona: estrategia.redondear(
            BigInt.from(10),
            BigInt.from(3),
          ),
        ),
        formateadorMoneda: const FormateadorMoneda(),
        estrategias: {
          'Exacto': const _EstrategiaPrueba(),
          'Hacia arriba': const _OtraEstrategiaPrueba(),
        },
      );

      expect(controlador.modos, ['Exacto', 'Hacia arriba']);
      for (final caso in [
        (modo: 'Exacto', pago: '27.50'),
        (modo: 'Hacia arriba', pago: '4.00'),
        (modo: 'Exacto', pago: '27.50'),
      ]) {
        expect(
          controlador.calcular(
            monto: '10',
            personas: '3',
            propina: '0',
            modo: caso.modo,
          ),
          (resultado: caso.pago, error: null),
        );
      }
    },
  );
}

Cuenta _crearCuenta() => Cuenta(
  montoCoeficiente: BigInt.from(10000),
  montoEscala: 2,
  personas: BigInt.from(4),
  propinaCoeficiente: BigInt.from(10),
  propinaEscala: 0,
);

DivisorController _crearControlador(
  Map<String, EstrategiaRedondeo> estrategias,
) => DivisorController(
  validarEntrada: ({required monto, required personas, required propina}) =>
      _crearCuenta(),
  calcularDivision: (cuenta, estrategia) =>
      Resultado(centavosPorPersona: BigInt.from(2750)),
  formateadorMoneda: const FormateadorMoneda(),
  estrategias: estrategias,
);

class _EstrategiaPrueba implements EstrategiaRedondeo {
  const _EstrategiaPrueba([this.identificador = 0]);

  final int identificador;

  @override
  BigInt redondear(BigInt numerador, BigInt denominador) => BigInt.from(2750);
}

class _FormateadorRegistrador extends FormateadorMoneda {
  _FormateadorRegistrador(this.llamadas, this.esperado);

  final List<String> llamadas;
  final Resultado esperado;

  @override
  String formatear(Resultado resultado) {
    llamadas.add('formatear');
    expect(resultado, same(esperado));
    return '27.50';
  }
}

class _FormateadorConError extends FormateadorMoneda {
  const _FormateadorConError();

  @override
  String formatear(Resultado resultado) =>
      throw ArgumentError('Falla del formato');
}

class _OtraEstrategiaPrueba implements EstrategiaRedondeo {
  const _OtraEstrategiaPrueba();

  @override
  BigInt redondear(BigInt numerador, BigInt denominador) {
    expect(numerador, BigInt.from(10));
    expect(denominador, BigInt.from(3));
    return BigInt.from(400);
  }
}
