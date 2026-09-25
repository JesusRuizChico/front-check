# Guía de Contribución

### Flujo de trabajo
Seguimos el modelo **GitHub Flow adaptado** (con ramas `develop` y `sprint`):
1. Crear rama a partir de `develop` bajo el formato `feature/nombre-modulo` o `fix/descripcion`.
2. Realizar commits respetando el estándar **Conventional Commits** (`feat:`, `fix:`, `chore:`, `refactor:`).
3. Abrir un Pull Request hacia `develop` (o `main` para releases).
4. El PR requiere la validación del CI en verde y al menos una aprobación para el merge.

### Versionado
- Se emplea versionado semántico: `vMayor.Menor.Parche` vinculado al número de compilación interno (ej. `v1.0.0 (1)`).
