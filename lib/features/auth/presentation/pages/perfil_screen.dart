import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/mock_database.dart';
import '../../../../domain/models/usuario_model.dart';
import '../../../properties/presentation/widgets/theme_selector_sheet.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _bioController = TextEditingController();
  final _contrasenaActualController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  final List<String> _avataresMuestra = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    final u = mockDatabase.usuarioActual ?? mockDatabase.usuarios[1];
    _nombreController.text = u.nombre;
    _telefonoController.text = u.telefono;
    _bioController.text = u.bio;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _bioController.dispose();
    _contrasenaActualController.dispose();
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _guardarDatosPersonales() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 300));
    mockDatabase.actualizarPerfil(
      nombre: _nombreController.text.trim(),
      telefono: _telefonoController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Perfil actualizado correctamente.'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cambiarContrasena() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_nuevaContrasenaController.text != _confirmarContrasenaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas nuevas no coinciden.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isChangingPassword = false);
      _contrasenaActualController.clear();
      _nuevaContrasenaController.clear();
      _confirmarContrasenaController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.lock_reset_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Contraseña actualizada exitosamente.'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _mostrarSelectorAvatares() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Foto de Perfil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _avataresMuestra.map((url) {
                return InkWell(
                  onTap: () {
                    mockDatabase.actualizarPerfil(
                      nombre: mockDatabase.usuarioActual?.nombre ?? 'Usuario',
                      fotoUrl: url,
                    );
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(url),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    final img = await _picker.pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      mockDatabase.actualizarPerfil(
                        nombre: mockDatabase.usuarioActual?.nombre ?? 'Usuario',
                        fotoUrl: _avataresMuestra[0],
                      );
                    }
                  } catch (_) {}
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Elegir de Galería'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      mockDatabase.logout();
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: mockDatabase,
      builder: (context, _) {
        final usuario = mockDatabase.usuarioActual ?? mockDatabase.usuarios[1];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            actions: [
              IconButton(
                tooltip: 'Personalizar Tema',
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => ThemeSelectorSheet.show(context),
              ),
              IconButton(
                tooltip: 'Cerrar Sesión',
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: _logout,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Cabecera de Foto y Nombre
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundImage: usuario.fotoUrl != null
                            ? NetworkImage(usuario.fotoUrl!)
                            : null,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                        child: usuario.fotoUrl == null
                            ? Text(
                                usuario.nombre.isNotEmpty ? usuario.nombre[0] : 'U',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _mostrarSelectorAvatares,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.cardColor, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  usuario.nombre,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  usuario.correo,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),

                // Badge de Rol
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        usuario.rolPrincipal.toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Acceso directo a selector de tema
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.palette_rounded, color: theme.colorScheme.primary),
                    ),
                    title: const Text('Tema y Colores', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Personalizar modo oscuro/claro y paleta de acento'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => ThemeSelectorSheet.show(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Formulario de Datos Personales
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Datos Personales',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre Completo',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono de Contacto',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _bioController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Biografía / Descripción',
                              prefixIcon: Icon(Icons.edit_note_rounded),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _guardarDatosPersonales,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Formulario de Cambio de Contraseña
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lock_outline_rounded, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Seguridad & Contraseña',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contrasenaActualController,
                            obscureText: _obscureCurrent,
                            decoration: InputDecoration(
                              labelText: 'Contraseña Actual',
                              prefixIcon: const Icon(Icons.lock_clock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                              ),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Ingresa tu contraseña actual' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nuevaContrasenaController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              labelText: 'Nueva Contraseña',
                              prefixIcon: const Icon(Icons.password_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            validator: (val) =>
                                val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmarContrasenaController,
                            obscureText: _obscureNew,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar Nueva Contraseña',
                              prefixIcon: Icon(Icons.check_circle_outline),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Confirma tu contraseña' : null,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isChangingPassword ? null : _cambiarContrasena,
                              icon: _isChangingPassword
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.key_rounded),
                              label: Text(_isChangingPassword ? 'Actualizando...' : 'Actualizar Contraseña'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
