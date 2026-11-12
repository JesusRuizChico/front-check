import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/router/politica_navegacion.dart';
import 'package:front_check/core/router/rutas.dart';
import 'package:front_check/domain/models/usuario_model.dart';
import 'package:front_check/features/auth/application/sesion_controller.dart';

Usuario _usuario(String rol) => Usuario(id: 1, nombre: 'Ana', correo: 'ana@example.com', roles: [rol]);

void main() {
  group('PoliticaNavegacion', () {
    test('Mientras se verifica la sesión se muestra la pantalla de carga', () {
      expect(PoliticaNavegacion.redirigir(const SesionState(), Rutas.inicioInquilino), Rutas.carga);
      expect(PoliticaNavegacion.redirigir(const SesionState(), Rutas.carga), isNull);
    });

    test('Sin sesión solo se permiten las rutas públicas', () {
      const sinSesion = SesionState(inicializada: true);
      expect(PoliticaNavegacion.redirigir(sinSesion, Rutas.login), isNull);
      expect(PoliticaNavegacion.redirigir(sinSesion, Rutas.registro), isNull);
      expect(PoliticaNavegacion.redirigir(sinSesion, Rutas.panelArrendador), Rutas.bienvenida);
      expect(PoliticaNavegacion.redirigir(sinSesion, Rutas.chats), Rutas.bienvenida);
    });

    test('El inquilino entra a su panel y no puede abrir el del arrendador', () {
      final sesion = SesionState(inicializada: true, usuario: _usuario(Usuario.rolArrendatario));
      expect(PoliticaNavegacion.redirigir(sesion, Rutas.login), Rutas.inicioInquilino);
      expect(PoliticaNavegacion.redirigir(sesion, Rutas.publicarPropiedad), Rutas.inicioInquilino);
      expect(PoliticaNavegacion.redirigir(sesion, Rutas.chats), isNull);
    });

    test('El arrendador entra a su panel y no puede abrir el del inquilino', () {
      final sesion = SesionState(inicializada: true, usuario: _usuario(Usuario.rolArrendador));
      expect(PoliticaNavegacion.redirigir(sesion, Rutas.bienvenida), Rutas.panelArrendador);
      expect(PoliticaNavegacion.redirigir(sesion, Rutas.inicioInquilino), Rutas.panelArrendador);
      expect(PoliticaNavegacion.redirigir(sesion, Rutas.publicarPropiedad), isNull);
    });
  });
}
