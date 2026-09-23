import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front_check/core/theme/app_colors.dart';
import 'package:front_check/features/auth/data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        final roles = response['rolesActivos'] as List<dynamic>? ?? [];
        if (roles.contains('arrendador')) {
          context.go('/dashboard-arrendador');
        } else if (roles.contains('proveedor') || roles.contains('servicios')) {
          context.go('/dashboard-servicios');
        } else {
          context.go('/home'); // Arrendatario por defecto
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al iniciar sesión. Revisa tus credenciales o tu conexión.';
        if (e.toString().contains('CREDENCIALES_INVALIDAS') || e.toString().contains('Credenciales inválidas')) {
          errorMessage = 'Las credenciales son inválidas';
        } else if (e.toString().contains('CUENTA_BLOQUEADA') || e.toString().contains('Cuenta bloqueada')) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [theme.colorScheme.surface, theme.colorScheme.background],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1, left: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary.withOpacity(0.4)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.lock_person_rounded, size: 64, color: theme.textTheme.bodyLarge?.color),
                      const SizedBox(height: 24),
                      Text('Bienvenido de nuevo', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Inicia sesión para continuar', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 40),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !_isLoading,
                                  decoration: const InputDecoration(labelText: 'Correo Electrónico', prefixIcon: Icon(Icons.email_outlined)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Ingresa tu correo';
                                    if (!value.contains('@')) return 'Correo no válido';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: _isLoading ? null : () {}, child: const Text('¿Olvidaste tu contraseña?')),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading ? CircularProgressIndicator(color: theme.colorScheme.background, strokeWidth: 3) : const Text('Iniciar Sesión'),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('¿No tienes cuenta?', style: theme.textTheme.bodyMedium),
                          TextButton(onPressed: _isLoading ? null : () => context.pushReplacement('/register'), child: const Text('Regístrate aquí')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

