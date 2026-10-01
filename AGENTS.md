# Instrucciones del proyecto

Aplicación Flutter de una sola pantalla para dividir una cuenta entre varias personas.

## Estructura y dependencias

- `lib/presentation/`: interfaz y estado de la pantalla.
- `lib/domain/`: entidades y lógica de negocio.
- `lib/data/`: implementaciones de acceso a datos.
- Dirección de dependencias: `presentation → domain ← data`.
- Domain no puede importar Flutter ni depender de paquetes externos.

## Reglas

- Utilizar null safety y nombres en español.
- No agregar paquetes externos.
- No modificar `test/` sin autorización del usuario.
- No agregar dependencias a `pubspec.yaml` sin avisar al usuario.
- No modificar las carpetas `android/` ni `ios/`.

## Comandos de verificación

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```
