import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/camera_helper.dart';
import '../../data/perfil_service.dart';

/// Pantalla de Gestión de Perfil de Usuario
/// Implementa la Historia de Usuario: HU04 — Actualización de Foto de Perfil
/// 
/// Escenarios cubiertos:
/// - Escenario 1: Actualización exitosa de la foto de perfil.
/// - Escenario 2: Intento de subir un archivo no soportado o que excede el tamaño.
/// - Escenario 3: Eliminación de la foto de perfil y restablecimiento al avatar por defecto.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Instancia para selección de imágenes del dispositivo
  final ImagePicker _picker = ImagePicker();

  // Estado del perfil del usuario
  Map<String, dynamic>? _perfil;
  Uint8List? _previewBytes;
  int _cacheBuster = DateTime.now().millisecondsSinceEpoch;
  bool _isLoading = true;
  bool _isProcessingPhoto = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  /// Carga los datos del perfil desde el endpoint GET /api/perfil
  Future<void> _cargarDatosPerfil() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final datos = await perfilService.obtenerMiPerfil();
      if (mounted) {
        setState(() {
          _perfil = datos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// Escenario 1 y 2: Selecciona una imagen y la envía al servidor
  Future<void> _seleccionarYSubirFoto(ImageSource source) async {
    Navigator.of(context).pop(); // Cerrar el modal de opciones

    try {
      final XFile? imagenSeleccionada;
      if (source == ImageSource.camera) {
        imagenSeleccionada = await CameraHelper.tomarFotoConCamara(context);
      } else {
        imagenSeleccionada = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85, // Optimización de compresión sin pérdida visual
        );
      }

      // Si el usuario canceló la selección, no realizamos ninguna acción
      if (imagenSeleccionada == null) return;

      final bytes = await imagenSeleccionada.readAsBytes();

      setState(() {
        _isProcessingPhoto = true;
        _previewBytes = bytes; // Reflejar en la UI inmediatamente
      });

      // Enviamos la imagen al backend a través del servicio
      final perfilActualizado = await perfilService.actualizarFotoPerfil(imagenSeleccionada);

      if (mounted) {
        setState(() {
          // Escenario 1: Actualizar la foto en pantalla de inmediato
          _perfil = perfilActualizado;
          _cacheBuster = DateTime.now().millisecondsSinceEpoch;
          _isProcessingPhoto = false;
        });

        // Notificación de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Foto de perfil actualizada exitosamente.'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      // Escenario 2: Mensaje de error si el archivo no es soportado o excede 5 MB
      // La foto anterior se conserva intacta
      if (mounted) {
        setState(() {
          _isProcessingPhoto = false;
          _previewBytes = null; // Revertir vista previa en caso de error
        });

        final mensajeLimpio = error.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(mensajeLimpio)),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Escenario 3: Elimina la foto de perfil del usuario
  Future<void> _confirmarYEliminarFoto() async {
    Navigator.of(context).pop(); // Cerrar modal de opciones

    // Diálogo de confirmación para evitar eliminaciones accidentales
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar foto de perfil?'),
        content: const Text(
          'Se removerá tu fotografía actual y se mostrará el avatar predeterminado de tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isProcessingPhoto = true);

    try {
      final perfilActualizado = await perfilService.eliminarFotoPerfil();

      if (mounted) {
        setState(() {
          _previewBytes = null;
          // Escenario 3: La foto pasa a ser null y se muestra el avatar predeterminado
          if (perfilActualizado != null) {
            _perfil = perfilActualizado;
          } else if (_perfil != null) {
            _perfil!['fotoPerfil'] = null;
          }
          _cacheBuster = DateTime.now().millisecondsSinceEpoch;
          _isProcessingPhoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Foto eliminada. Se restauró el avatar predeterminado.'),
              ],
            ),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isProcessingPhoto = false);
        final mensaje = error.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo eliminar la foto: $mensaje'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Despliega el menú inferior con las opciones para cambiar o eliminar la foto
  void _mostrarOpcionesFoto() {
    final tieneFoto = _perfil?['fotoPerfil'] != null &&
        (_perfil!['fotoPerfil'] as String).isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: theme.colorScheme.onSurfaceVariant),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Foto de perfil',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Formatos permitidos: JPG, PNG, WEBP (Máx. 5 MB)',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.accent),
                  ),
                  title: const Text('Elegir de la galería'),
                  onTap: () => _seleccionarYSubirFoto(ImageSource.gallery),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.secondary),
                  ),
                  title: const Text('Tomar foto con la cámara'),
                  onTap: () => _seleccionarYSubirFoto(ImageSource.camera),
                ),
                if (tieneFoto) ...[
                  const Divider(height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                    ),
                    title: const Text(
                      'Eliminar foto actual',
                      style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                    ),
                    onTap: _confirmarYEliminarFoto,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar datos',
            onPressed: _cargarDatosPerfil,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo base
          Container(color: theme.colorScheme.background),

          // Efecto de desenfoque decorativo de fondo
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView(theme)
                    : _buildPerfilContent(theme),
          ),
        ],
      ),
    );
  }

  /// Vista de error si no se pudo cargar el perfil
  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar el perfil',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargarDatosPerfil,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Contenido principal del perfil con el Avatar interactivo y los datos del usuario
  Widget _buildPerfilContent(ThemeData theme) {
    final nombre = _perfil?['nombre'] ?? 'Usuario';
    final correo = _perfil?['correo'] ?? '';
    final telefono = _perfil?['telefono'] ?? 'Sin registrar';
    final fotoUrl = _perfil?['fotoPerfil'] as String?;
    final roles = (_perfil?['roles'] as List<dynamic>?)?.map((r) => r.toString()).toList() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // -----------------------------------------------------------
          // SECCIÓN DE AVATAR (HU04 - Actualización de Foto de Perfil)
          // -----------------------------------------------------------
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Contenedor circular con degradado elegante
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: theme.colorScheme.surface,
                    child: ClipOval(
                      child: SizedBox(
                        width: 128,
                        height: 128,
                        child: _buildAvatarImage(fotoUrl, nombre),
                      ),
                    ),
                  ),
                ),

                // Indicador de carga sobre el avatar durante la subida o borrado
                if (_isProcessingPhoto)
                  Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.55),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),

                // Botón interactivo para editar/cambiar la foto
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Material(
                    color: AppColors.accent,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isProcessingPhoto ? null : _mostrarOpcionesFoto,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nombre del usuario
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Correo
          Text(
            correo,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),

          const SizedBox(height: 14),

          // Badges de roles
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: roles.map((rol) => _buildRoleBadge(rol)).toList(),
          ),

          const SizedBox(height: 28),

          // -----------------------------------------------------------
          // TARJETA DE DETALLES DE LA CUENTA
          // -----------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.onSurfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información Personal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nombre completo',
                  value: nombre,
                  theme: theme,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Correo electrónico',
                  value: correo,
                  theme: theme,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: telefono,
                  theme: theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botón directo para cambiar la foto
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: AppColors.accent.withOpacity(0.5)),
            ),
            onPressed: _isProcessingPhoto ? null : _mostrarOpcionesFoto,
            icon: const Icon(Icons.image_outlined, color: AppColors.accent),
            label: const Text(
              'Personalizar Foto de Perfil',
              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la imagen del avatar o el avatar predeterminado
  Widget _buildAvatarImage(String? fotoUrl, String nombre) {
    // 1. Si el usuario acaba de seleccionar una foto, mostrar la vista previa en memoria de inmediato
    if (_previewBytes != null) {
      return Image.memory(
        _previewBytes!,
        fit: BoxFit.cover,
      );
    }

    // 2. Si hay una URL en la base de datos, cargarla asegurando dominio completo y cache busting
    if (fotoUrl != null && fotoUrl.trim().isNotEmpty) {
      String resolvedUrl = fotoUrl.trim();
      if (!resolvedUrl.startsWith('http://') && !resolvedUrl.startsWith('https://')) {
        resolvedUrl = 'http://localhost:8080${resolvedUrl.startsWith('/') ? '' : '/'}$resolvedUrl';
      }

      final uri = Uri.parse(resolvedUrl);
      final cacheBustedUrl = uri.replace(
        queryParameters: {...uri.queryParameters, 't': '$_cacheBuster'},
      ).toString();

      return Image.network(
        cacheBustedUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Si falla la carga de la imagen de red, mostramos el avatar predeterminado
          return _buildDefaultAvatar(nombre);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }

    // Escenario 3: Avatar predeterminado cuando no hay foto asignada
    return _buildDefaultAvatar(nombre);
  }

  /// Avatar predeterminado con la inicial del usuario y colores institucionales
  Widget _buildDefaultAvatar(String nombre) {
    final inicial = nombre.trim().isNotEmpty ? nombre.trim()[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.accent.withOpacity(0.12),
      child: Center(
        child: Text(
          inicial,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  /// Badge indicador de rol
  Widget _buildRoleBadge(String rol) {
    final rolFormateado = rol.replaceAll('ROLE_', '').toLowerCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text(
        rolFormateado.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.accentLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Fila de información con icono descriptivo
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
