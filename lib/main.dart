import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  // Asegura que los bindings de Flutter se inicialicen antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase con tus llaves exactas
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCz1yRxB1tzz3BOVpZvW7cPhjr9KdD45FU",
      authDomain: "habitcheck404.firebaseapp.com",
      projectId: "habitcheck404",
      storageBucket: "habitcheck404.firebasestorage.app",
      messagingSenderId: "912301642109",
      appId: "1:912301642109:web:5e50d6de08ceacacee7c14",
    ),
  );

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
