import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: ArrendamientoSeguroApp(),
    ),
  );
}

class ArrendamientoSeguroApp extends ConsumerWidget {
  const ArrendamientoSeguroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    final activeTheme = DynamicAppTheme.buildTheme(
      isDark: themeState.isDark,
      palette: themeState.palette,
    );

    return MaterialApp.router(
      title: 'HabitaCheck',
      debugShowCheckedModeBanner: false,
      theme: activeTheme,
      themeMode: themeState.mode,
      routerConfig: AppRouter.router,
    );
  }
}
