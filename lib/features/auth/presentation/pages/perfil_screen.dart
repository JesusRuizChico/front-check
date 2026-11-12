import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/password_validator.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../../../core/widgets/avatar_usuario.dart';
import '../../../../core/widgets/avisos.dart';
import '../../../../di/dependencias.dart';
import '../../../../domain/models/usuario_model.dart';
import '../../../properties/presentation/widgets/theme_selector_sheet.dart';
import '../../application/perfil_controller.dart';
import '../../application/sesion_controller.dart';
import '../widgets/boton_cerrar_sesion.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _bioController = TextEditingController();
  final _contrasenaActualController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _isUpdatingPhoto = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  PerfilController get _perfil => ref.read(perfilControllerProvider);

  @override
  void initState() {
    super.initState();
    final usuario = ref.read(sesionProvider).usuario;
    if (usuario != null) _cargarDatos(usuario);
  }

  void _cargarDatos(Usuario usuario) {
    _nombreController.text = usuario.nombre;
    _telefonoController.text = usuario.telefono ?? '';
    _bioController.text = usuario.bio ?? '';
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
    try {
      await _perfil.actualizarDatos(
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (mounted) Avisos.exito(context, 'Perfil actualizado correctamente.');
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _cambiarContrasena() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    if (_nuevaContrasenaController.text != _confirmarContrasenaController.text) {
      Avisos.error(context, 'Las contraseñas nuevas no coinciden.');
      return;
    }
    setState(() => _isChangingPassword = true);
    try {
      await _perfil.cambiarContrasena(
        actual: _contrasenaActualController.text,
        nueva: _nuevaContrasenaController.text,
      );
      if (!mounted) return;
      _contrasenaActualController.clear();
      _nuevaContrasenaController.clear();
      _confirmarContrasenaController.clear();
      Avisos.exito(context, 'Contraseña actualizada exitosamente.');
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  Future<void> _ejecutarCambioDeFoto(Future<void> Function() accion, String mensajeExito) async {
    setState(() => _isUpdatingPhoto = true);
    try {
      await accion();
      if (mounted) Avisos.exito(context, mensajeExito);
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    } finally {
      if (mounted) setState(() => _isUpdatingPhoto = false);
    }
  }

  Future<void> _elegirFoto() async {
    try {
      final imagen = await ref.read(selectorImagenesProvider).elegirUna();
      if (imagen == null || !mounted) return;
      await _ejecutarCambioDeFoto(() => _perfil.actualizarFoto(imagen), 'Foto de perfil actualizada.');
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    }
  }

  void _mostrarOpcionesFoto(Usuario usuario) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Foto de Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de Galería'),
                onTap: () {
                  Navigator.pop(ctx);
                  _elegirFoto();
                },
              ),
              if (usuario.fotoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _ejecutarCambioDeFoto(_perfil.eliminarFoto, 'Foto de perfil eliminada.');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = ref.watch(sesionProvider).usuario;
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            tooltip: 'Personalizar Tema',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
          const BotonCerrarSesion(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Stack(
                  children: [
                    AvatarUsuario(nombre: usuario.nombre, fotoUrl: usuario.fotoUrl, radio: 54),
                    if (_isUpdatingPhoto)
                      const Positioned.fill(child: Center(child: CircularProgressIndicator())),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _isUpdatingPhoto ? null : () => _mostrarOpcionesFoto(usuario),
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
                const SizedBox(height: 14),
                Text(usuario.nombre, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(usuario.correo, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        usuario.rolPrincipal.toUpperCase(),
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
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
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TituloSeccion(icono: Icons.person_outline_rounded, texto: 'Datos Personales'),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre Completo',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono de Contacto',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty || PhoneValidator.isValid(val)
                                ? null
                                : 'Debe tener 10 dígitos',
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _bioController,
                            maxLines: 2,
                            maxLength: 500,
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
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TituloSeccion(icono: Icons.lock_outline_rounded, texto: 'Seguridad & Contraseña'),
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
                            validator: (val) => val == null || val.isEmpty ? 'Ingresa tu contraseña actual' : null,
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
                            validator: (val) => PasswordValidator.isValid(val)
                                ? null
                                : 'Mínimo 8 caracteres, una mayúscula y un número',
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmarContrasenaController,
                            obscureText: _obscureNew,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar Nueva Contraseña',
                              prefixIcon: Icon(Icons.check_circle_outline),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Confirma tu contraseña' : null,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isChangingPassword ? null : _cambiarContrasena,
                              icon: _isChangingPassword
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
        ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _TituloSeccion({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
