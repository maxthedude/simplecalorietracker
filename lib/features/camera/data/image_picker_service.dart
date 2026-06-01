import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<Uint8List?> captureMealImage() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    return file == null ? null : file.readAsBytes();
  }
}
