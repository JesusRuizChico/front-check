import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Los errores se muestran al usuario con opción de reintentar; no hay reintentos automáticos.
    ProviderScope(retry: (_, _) => null, child: const ArrendamientoSeguroApp()),
  );
}

class ArrendamientoSeguroApp extends ConsumerWidget {
  const ArrendamientoSeguroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'HabitaCheck',
      debugShowCheckedModeBanner: false,
      theme: DynamicAppTheme.buildTheme(isDark: themeState.isDark, palette: themeState.palette),
      themeMode: themeState.mode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
