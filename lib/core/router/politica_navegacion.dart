import '../../features/auth/application/sesion_controller.dart';
import 'rutas.dart';

/// Decide a dónde debe ir el usuario según su sesión y su rol.
class PoliticaNavegacion {
  const PoliticaNavegacion._();

  static String? redirigir(SesionState sesion, String ubicacion) {
    if (!sesion.inicializada) {
      return ubicacion == Rutas.carga ? null : Rutas.carga;
    }
    final usuario = sesion.usuario;
    if (usuario == null) {
      return Rutas.publicas.contains(ubicacion) ? null : Rutas.bienvenida;
    }
    final inicio = usuario.esArrendador ? Rutas.panelArrendador : Rutas.inicioInquilino;
    if (ubicacion == Rutas.carga || Rutas.publicas.contains(ubicacion)) return inicio;
    if (Rutas.soloArrendador.contains(ubicacion) && !usuario.esArrendador) return inicio;
    if (Rutas.soloInquilino.contains(ubicacion) && usuario.esArrendador) return inicio;
    return null;
  }
}
