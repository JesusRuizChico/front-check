import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(
      child: ArrendamientoSeguroApp(),
    ),
  );
}

class ArrendamientoSeguroApp extends ConsumerWidget {
  const ArrendamientoSeguroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Arrendamiento Seguro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Premium dark theme with blues
      routerConfig: AppRouter.router,
    );
  }
}
