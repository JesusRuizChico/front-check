/// Rutas de navegación de la app.
class Rutas {
  const Rutas._();

  static const carga = '/cargando';
  static const bienvenida = '/';
  static const login = '/login';
  static const registro = '/register';
  static const inicioInquilino = '/home';
  static const panelArrendador = '/dashboard-arrendador';
  static const publicarPropiedad = '/publicar-propiedad';
  static const chats = '/chats';
  static const chat = '/chat-detail';
  static const perfil = '/perfil';

  static const publicas = {bienvenida, login, registro};
  static const soloArrendador = {panelArrendador, publicarPropiedad};
  static const soloInquilino = {inicioInquilino};
}
