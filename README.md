# HabitaCheck — Frontend (Flutter)

Aplicación para **inquilinos** y **arrendadores**. Todo se consume del backend
[`back-check`](https://github.com/JesusRuizChico/back-check); no hay datos simulados.

- **Inquilino:** explora las propiedades publicadas, guarda favoritos y chatea con el arrendador.
- **Arrendador:** publica propiedades con fotos, las pausa, marca como rentadas o elimina, y responde los chats.

## Requisitos

- Flutter 3.44 (Dart 3.12)
- Backend `back-check` corriendo (por defecto en `http://localhost:8080`)

## Ejecutar

```bash
flutter pub get
```

```bash
flutter run -d chrome
```

Dirección del backend según la plataforma:

| Plataforma | URL por defecto |
| --- | --- |
| Web / escritorio / iOS simulador | `http://localhost:8080` |
| Emulador de Android | `http://10.0.2.2:8080` |

Para un teléfono físico u otro servidor, indica la URL al compilar:

```bash
flutter run --dart-define=API_URL=http://192.168.1.50:8080
```

## Arquitectura (SOLID)

```
lib/
├── core/            # Infraestructura transversal: config, red (ApiClient), router, tema, widgets
├── domain/          # Modelos y contratos (interfaces) de repositorios y servicios
├── data/            # Implementaciones: repositorios HTTP, mappers JSON → dominio, galería
├── di/              # Raíz de composición: enlaza cada interfaz con su implementación
└── features/
    ├── auth/        # application (sesión, perfil) + presentation (login, registro, perfil)
    ├── properties/  # application (catálogo, favoritos, mis propiedades) + presentation
    ├── chat/        # application (bandeja, chat con actualización periódica) + presentation
    └── onboarding/  # bienvenida y pantalla de carga
```

- **S:** cada clase tiene una sola responsabilidad (mappers, repositorios, controladores, widgets visuales).
- **O / L:** las pantallas trabajan con interfaces (`IAuthRepository`, `IChatRepository`, ...); se pueden
  sustituir por otras implementaciones (por ejemplo, falsas en pruebas) sin modificar la UI.
- **I:** contratos pequeños (`ICatalogoRepository` separado de `IMisPropiedadesRepository`).
- **D:** las capas `application` y `presentation` dependen de abstracciones; `di/dependencias.dart` es el
  único lugar que conoce las implementaciones concretas.

## Pruebas

```bash
flutter analyze
```

```bash
flutter test
```
