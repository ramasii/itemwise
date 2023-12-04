import 'allpackages.dart';
import 'package:flutter/material.dart';

class fungsies {
  pickImage() async {
    log("START _pickImage");

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 1,
        maxHeight: 50,
        maxWidth: 50);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final encodedImage = base64Encode(bytes);

      // kembalikan gambar yang dienkode
      return encodedImage;
    } else {
      return "";
    }
  }

  CheckIsImgLscape(Uint8List bytes) {
    log("start check image landscape");
    final size = ImageSizeGetter.getSize(MemoryInput(bytes));

    if (size.height > size.width) {
      return false;
    } else {
      return true;
    }
  }
}
