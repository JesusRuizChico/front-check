import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> tomarFoto(BuildContext context) async {
  final picker = ImagePicker();
  return await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 85,
  );
}
