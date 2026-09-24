import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front_check/core/theme/app_colors.dart';
import 'package:front_check/features/auth/data/auth_service.dart';
import 'package:front_check/features/auth/presentation/widgets/especialidades_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptedPrivacy = false;
  String _selectedRole = 'arrendatario'; // 'arrendatario', 'arrendador', 'servicios'

  // Estado de especialidades (solo relevante para rol 'servicios')
  List<String> _especialidadesSeleccionadas = [];
  bool _mostrarErrorEspecialidad = false;

  Future<void> _register() async {
    if (!_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Debes aceptar el Aviso de Privacidad para continuar.'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    // Escenario 2: Validar especialidad si el rol es 'servicios'
    if (_selectedRole == 'servicios' && _especialidadesSeleccionadas.isEmpty) {
      setState(() => _mostrarErrorEspecialidad = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Debes seleccionar al menos una especialidad.'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
        _selectedRole,
        especialidades: _especialidadesSeleccionadas,
      );
      if (mounted) {
        // Escenario 1: Registro exitoso → redirigir a login
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Registro exitoso. Ahora puedes iniciar sesión.'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al registrarte. Intenta nuevamente.';
        if (e.toString().contains('CORREO_YA_REGISTRADO')) {
          errorMessage = 'El correo ya está en uso';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage), 
          backgroundColor: AppColors.danger, 
          behavior: SnackBarBehavior.floating, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: theme.colorScheme.onSurfaceVariant, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Text('Aviso de Privacidad', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      'En Arrendamiento Seguro protegemos tus datos personales. Toda la información proporcionada será utilizada exclusivamente para conectarte con propiedades o inquilinos potenciales. Al usar nuestra plataforma aceptas que almacenemos esta información en nuestros servidores cifrados.',
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _acceptedPrivacy = true);
                    context.pop();
                  },
                  child: const Text('Entendido y Aceptado'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.go('/')),
      ),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomRight, end: Alignment.topLeft, colors: [theme.colorScheme.surface, theme.colorScheme.background]))),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.secondary.withOpacity(0.4)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Crear Cuenta', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Únete a nuestra comunidad', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: theme.colorScheme.surface.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.onSurfaceVariant)),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.onSurfaceVariant)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _isLoading ? null : () => setState(() => _selectedRole = 'arrendatario'),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(color: _selectedRole == 'arrendatario' ? theme.colorScheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                                            child: Text('Busco Cuarto', textAlign: TextAlign.center, style: TextStyle(color: _selectedRole == 'arrendatario' ? Colors.white : theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _isLoading ? null : () => setState(() => _selectedRole = 'arrendador'),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(color: _selectedRole == 'arrendador' ? theme.colorScheme.secondary : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                                            child: Text('Ofrezco Cuartos', textAlign: TextAlign.center, style: TextStyle(color: _selectedRole == 'arrendador' ? Colors.white : theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _isLoading ? null : () => setState(() {
                                            _selectedRole = 'servicios';
                                            // Al cambiar de rol, limpiamos el error de especialidad
                                            _mostrarErrorEspecialidad = false;
                                          }),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(color: _selectedRole == 'servicios' ? Colors.orange : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                                            child: Text('Servicios', textAlign: TextAlign.center, style: TextStyle(color: _selectedRole == 'servicios' ? Colors.white : theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Selector de especialidades — solo visible para rol 'servicios'
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  transitionBuilder: (child, animation) => SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1,
                                    child: FadeTransition(opacity: animation, child: child),
                                  ),
                                  child: _selectedRole == 'servicios'
                                      ? Padding(
                                          key: const ValueKey('selector-especialidades'),
                                          padding: const EdgeInsets.only(top: 20),
                                          child: EspecialidadesSelector(
                                            seleccionadas: _especialidadesSeleccionadas,
                                            mostrarError: _mostrarErrorEspecialidad,
                                            onChanged: (nuevas) => setState(() {
                                              _especialidadesSeleccionadas = nuevas;
                                              // Limpia el error en cuanto selecciona algo
                                              if (nuevas.isNotEmpty) _mostrarErrorEspecialidad = false;
                                            }),
                                          ),
                                        )
                                      : const SizedBox.shrink(key: ValueKey('sin-selector')),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _nameController, enabled: !_isLoading, decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person_outline)),
                                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController, keyboardType: TextInputType.emailAddress, enabled: !_isLoading, decoration: const InputDecoration(labelText: 'Correo Electrónico', prefixIcon: Icon(Icons.email_outlined)),
                                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu correo' : (!v.contains('@') ? 'Correo no válido' : null),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneController, keyboardType: TextInputType.phone, enabled: !_isLoading, decoration: const InputDecoration(labelText: 'Número Telefónico', prefixIcon: Icon(Icons.phone_outlined)),
                                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu teléfono' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController, obscureText: _obscurePassword, enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu contraseña' : (v.length < 6 ? 'Mínimo 6 caracteres' : null),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(value: _acceptedPrivacy, onChanged: _isLoading ? null : (v) => setState(() => _acceptedPrivacy = v ?? false), activeColor: theme.colorScheme.primary),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showPrivacyPolicy,
                              child: Text.rich(
                                TextSpan(text: 'He leído y acepto el ', style: theme.textTheme.bodyMedium, children: [TextSpan(text: 'Aviso de Privacidad', style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline, fontWeight: FontWeight.bold))]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading ? CircularProgressIndicator(color: theme.colorScheme.background, strokeWidth: 3) : const Text('Registrarse'),
                      ),
                      const SizedBox(height: 20),
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

