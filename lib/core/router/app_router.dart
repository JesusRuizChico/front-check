import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/sesion_controller.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/perfil_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/chat/presentation/pages/chat_detail_screen.dart';
import '../../features/chat/presentation/pages/chat_list_screen.dart';
import '../../features/onboarding/presentation/pages/carga_screen.dart';
import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/properties/presentation/pages/arrendador_dashboard_screen.dart';
import '../../features/properties/presentation/pages/home_screen.dart';
import '../../features/properties/presentation/pages/publicar_propiedad_screen.dart';
import 'politica_navegacion.dart';
import 'rutas.dart';

/// Navegación de la app; redirige según la sesión y el rol del usuario.
final routerProvider = Provider<GoRouter>((ref) {
  final sesion = ValueNotifier<SesionState>(ref.read(sesionProvider));
  ref.listen(sesionProvider, (_, siguiente) => sesion.value = siguiente);
  ref.onDispose(sesion.dispose);

  return GoRouter(
    initialLocation: Rutas.carga,
    refreshListenable: sesion,
    redirect: (context, state) => PoliticaNavegacion.redirigir(sesion.value, state.matchedLocation),
    routes: [
      GoRoute(path: Rutas.carga, builder: (_, _) => const CargaScreen()),
      GoRoute(path: Rutas.bienvenida, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Rutas.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Rutas.registro, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: Rutas.inicioInquilino, builder: (_, _) => const HomeScreen()),
      GoRoute(path: Rutas.panelArrendador, builder: (_, _) => const ArrendadorDashboardScreen()),
      GoRoute(path: Rutas.publicarPropiedad, builder: (_, _) => const PublicarPropiedadScreen()),
      GoRoute(path: Rutas.chats, builder: (_, _) => const ChatListScreen()),
      GoRoute(
        path: Rutas.chat,
        redirect: (_, state) => state.extra is ChatArgs ? null : Rutas.chats,
        builder: (_, state) => ChatDetailScreen(args: state.extra! as ChatArgs),
      ),
      GoRoute(path: Rutas.perfil, builder: (_, _) => const PerfilScreen()),
    ],
  );
});
