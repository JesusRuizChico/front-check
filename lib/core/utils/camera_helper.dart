import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_helper_stub.dart'
    if (dart.library.html) 'camera_helper_web.dart' as impl;

class CameraHelper {
  /// Captura una foto usando la cámara real del dispositivo o navegador web
  static Future<XFile?> tomarFotoConCamara(BuildContext context) {
    return impl.tomarFoto(context);
  }
}
