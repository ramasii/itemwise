import 'allpackages.dart';
import 'package:flutter/material.dart';

class fungsies {
  pickImage() async {
    log("START _pickImage");

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 400,
        maxWidth: 400);

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

  Future<bool> konfirmasiHapus(BuildContext context) async {
    bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("${AppLocalizations.of(context)!.attention}"),
            content: Text(AppLocalizations.of(context)!.delDataCantRecover),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(AppLocalizations.of(context)!.delete,
                      style: TextStyle(color: Colors.red))),
            ],
          );
        });
    return result ?? false;
  }
}
