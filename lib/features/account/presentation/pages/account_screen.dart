import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front_check/core/theme/app_colors.dart';
import 'package:front_check/features/account/data/account_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telefonoController = TextEditingController();
  final _correoAlternoController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _guardarContacto() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await accountService.actualizarContacto(
        _telefonoController.text.trim(),
        _correoAlternoController.text.trim().isEmpty ? null : _correoAlternoController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Información de contacto actualizada con éxito!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String mensajeError = 'Error al actualizar el contacto.';
        if (e.toString().contains('DATOS_INVALIDOS')) {
          mensajeError = 'Por favor verifica los datos ingresados.';
        } else {
          mensajeError = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _correoAlternoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mi Perfil / Contacto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
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
                      Icon(Icons.contact_mail_rounded, size: 64, color: theme.textTheme.bodyLarge?.color),
                      const SizedBox(height: 24),
                      Text(
                        'Actualizar Contacto',
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Modifica tu número telefónico o correo alternativo',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
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
                                  controller: _telefonoController,
                                  keyboardType: TextInputType.phone,
                                  enabled: !_isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'Teléfono de contacto',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && value.length > 25) {
                                      return 'Máximo 25 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _correoAlternoController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !_isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo Alternativo',
                                    prefixIcon: Icon(Icons.alternate_email_rounded),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                                      return 'Formato de correo no válido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _guardarContacto,
                        child: _isLoading
                            ? CircularProgressIndicator(color: theme.colorScheme.background, strokeWidth: 3)
                            : const Text('Guardar Cambios'),
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
