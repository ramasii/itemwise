import 'allpackages.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class fungsies {
  pickImage() async {
    log("START _pickImage");

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final encodedImage = base64Encode(bytes);
      log(encodedImage.length.toString());
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

  Future<dynamic> konfirmasiHapus(BuildContext context, {String? judul, String? msg}) async {
    bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(judul ?? AppLocalizations.of(context)!.attention),
            content: Text(msg ?? AppLocalizations.of(context)!.delDataCantRecover),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(AppLocalizations.of(context)!.delete,
                      style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                  )),
            ],
          );
        });
    return result ?? false;
  }
}
