import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/perfil_screen.dart';
import '../../features/properties/presentation/pages/home_screen.dart';
import '../../features/properties/presentation/pages/arrendador_dashboard_screen.dart';
import '../../features/properties/presentation/pages/servicios_dashboard_screen.dart';
import '../../features/properties/presentation/pages/publicar_propiedad_screen.dart';
import '../../features/chat/presentation/pages/chat_list_screen.dart';
import '../../features/chat/presentation/pages/chat_detail_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const PerfilScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/dashboard-arrendador',
        builder: (context, state) => const ArrendadorDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard-servicios',
        builder: (context, state) => const ServiciosDashboardScreen(),
      ),
      GoRoute(
        path: '/publicar-propiedad',
        builder: (context, state) => const PublicarPropiedadScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat-detail',
        builder: (context, state) {
          final convId = state.extra as String? ?? 'conv_1';
          return ChatDetailScreen(conversacionId: convId);
        },
      ),
    ],
  );
}
