import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase de forma nativa. 
  // En Android buscará el archivo google-services.json automáticamente.
  await Firebase.initializeApp();

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
    return MaterialApp.router(
      title: 'Arrendamiento Seguro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
