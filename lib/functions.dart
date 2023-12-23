import 'package:flutter/cupertino.dart';

import 'allpackages.dart';
import 'package:flutter/material.dart';

enum PickImageFrom { gallery, camera }

/// ini sebenernya multifungsi, berisi fungsi atau variabel global
/// mungkin bisa bikin efisien
class fungsies {
  Container buildFotoBarang(barang, id) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          color: barang["photo_barang"] != ""
              ? Colors.transparent
              : const Color.fromARGB(255, 186, 186, 186),
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: barang["photo_barang"] != ""
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Hero(
                tag: "image$id",
                child: Image.memory(
                  Uint8List.fromList(base64.decode(barang["photo_barang"])),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.image_rounded,
                color: Colors.white,
                size: 45,
              ),
            ),
    );
  }

  pickImage({PickImageFrom from = PickImageFrom.gallery}) async {
    log("START _pickImage");

    final imagePicker = ImagePicker();
    XFile? pickedImage;

    // ambil lewat kamera atau dari galeri
    if (from == PickImageFrom.gallery) {
      pickedImage = await imagePicker.pickImage(
          source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
    } else if (from == PickImageFrom.camera) {
      pickedImage = await imagePicker.pickImage(
          source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
    }

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
    int h = size.height;
    int w = size.width;

    if (h > w && (h - w >= 50 || w - h >= 50)) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool?> konfirmasiDialog(
    BuildContext context, {
    // String? judul,
    String? msg,
    String? trueText,
    String? falseText,
    Color? trueColor,
    Color? falseColor,
  }) async {
    bool? result = await showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text(judul ?? AppLocalizations.of(context)!.attention),
            content:
                Text(msg ?? AppLocalizations.of(context)!.delDataCantRecover),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(trueText ?? AppLocalizations.of(context)!.delete,
                      style: TextStyle(color: trueColor ?? Colors.red))),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    falseText ?? AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: falseColor ?? Colors.blue),
                  )),
            ],
          );
        });
    return result;
  }
}
