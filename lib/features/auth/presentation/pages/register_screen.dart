import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/mock_database.dart';
import '../../../properties/presentation/widgets/theme_selector_sheet.dart';

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
  bool _acceptedPrivacy = true;
  String _selectedRole = 'arrendatario'; // 'arrendatario', 'arrendador', 'servicios'

  Future<void> _register() async {
    if (!_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar el Aviso de Privacidad para continuar.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 350));

    final nuevo = mockDatabase.registrarUsuario(
      nombre: _nameController.text.trim(),
      correo: _emailController.text.trim(),
      contrasena: _passwordController.text,
      telefono: _phoneController.text.trim(),
      rolSolicitado: _selectedRole,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('¡Registro exitoso! Sesión iniciada.'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (nuevo.esArrendador) {
        context.go('/dashboard-arrendador');
      } else if (nuevo.esPrestador) {
        context.go('/dashboard-servicios');
      } else {
        context.go('/home');
      }
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Cambiar Tema',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(color: theme.scaffoldBackgroundColor),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 44,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Crear Cuenta',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Únete a la comunidad de HabitaCheck',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Selector de Rol
                    Text(
                      '¿Qué tipo de cuenta necesitas?',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleChoiceCard(
                            title: 'Inquilino',
                            icon: Icons.person_rounded,
                            isSelected: _selectedRole == 'arrendatario',
                            onTap: () => setState(() => _selectedRole = 'arrendatario'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RoleChoiceCard(
                            title: 'Arrendador',
                            icon: Icons.real_estate_agent_rounded,
                            isSelected: _selectedRole == 'arrendador',
                            onTap: () => setState(() => _selectedRole = 'arrendador'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RoleChoiceCard(
                            title: 'Técnico',
                            icon: Icons.build_rounded,
                            isSelected: _selectedRole == 'servicios',
                            onTap: () => setState(() => _selectedRole = 'servicios'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campos del formulario
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre Completo *',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo Electrónico *',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono Móvil (10 dígitos) *',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña *',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (val) =>
                                  val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Checkbox de Privacidad
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedPrivacy,
                          onChanged: (val) => setState(() => _acceptedPrivacy = val ?? false),
                          activeColor: theme.colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            'Acepto los Términos de Servicio y el Aviso de Privacidad.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Botón Registrarse
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Completar Registro'),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿Ya tienes una cuenta? ', style: theme.textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Inicia sesión'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChoiceCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
