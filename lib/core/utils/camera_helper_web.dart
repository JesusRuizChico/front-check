import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

Future<XFile?> tomarFoto(BuildContext context) async {
  try {
    final mediaDevices = html.window.navigator.mediaDevices;
    if (mediaDevices == null) {
      throw Exception('Tu navegador no soporta captura de cámara directa.');
    }

    final stream = await mediaDevices.getUserMedia({'video': true});
    final viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';

    final videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..srcObject = stream
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => videoElement,
    );

    if (!context.mounted) {
      stream.getTracks().forEach((track) => track.stop());
      return null;
    }

    final XFile? fotoCapturada = await showDialog<XFile?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return _WebcamDialog(
          viewId: viewId,
          videoElement: videoElement,
          stream: stream,
        );
      },
    );

    stream.getTracks().forEach((track) => track.stop());
    return fotoCapturada;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo activar la cámara web: ${e.toString().replaceAll("Exception: ", "")}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
    return null;
  }
}

class _WebcamDialog extends StatefulWidget {
  final String viewId;
  final html.VideoElement videoElement;
  final html.MediaStream stream;

  const _WebcamDialog({
    required this.viewId,
    required this.videoElement,
    required this.stream,
  });

  @override
  State<_WebcamDialog> createState() => _WebcamDialogState();
}

class _WebcamDialogState extends State<_WebcamDialog> {
  bool _isCapturing = false;

  void _capturar() {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final video = widget.videoElement;
      final width = video.videoWidth > 0 ? video.videoWidth : 640;
      final height = video.videoHeight > 0 ? video.videoHeight : 480;

      final canvas = html.CanvasElement(width: width, height: height);
      final ctx = canvas.context2D;
      ctx.drawImage(video, 0, 0);

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.9);
      final base64String = dataUrl.split(',').last;
      final Uint8List bytes = base64Decode(base64String);

      final xFile = XFile.fromData(
        bytes,
        name: 'foto_perfil_${DateTime.now().millisecondsSinceEpoch}.jpg',
        mimeType: 'image/jpeg',
      );

      Navigator.of(context).pop(xFile);
    } catch (e) {
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al capturar la foto: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.camera_alt_rounded, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Tomar Foto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 400,
                height: 300,
                child: HtmlElementView(viewType: widget.viewId),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isCapturing ? null : _capturar,
                  icon: const Icon(Icons.camera_rounded),
                  label: Text(_isCapturing ? 'Procesando...' : 'Capturar Foto'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
