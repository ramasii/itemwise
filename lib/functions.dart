import 'allpackages.dart';
import 'package:flutter/material.dart';
enum PickImageFrom {gallery,camera}

/// ini sebenernya multifungsi, berisi fungsi atau variabel global
/// mungkin bisa bikin efisien 
class fungsies {
  // List filteredItems = ItemWise().

  pickImage({PickImageFrom from = PickImageFrom.gallery}) async {
    log("START _pickImage");

    final imagePicker = ImagePicker();
    XFile? pickedImage;

    // ambil lewat kamera atau dari galeri
    if(from == PickImageFrom.gallery){
      pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);
    } else {
      pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 100, maxWidth: 100);
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

    if (size.height > size.width) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> konfirmasiDialog(BuildContext context,
      {String? judul, String? msg, String? trueText, String? falseText}) async {
    bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(judul ?? AppLocalizations.of(context)!.attention),
            content:
                Text(msg ?? AppLocalizations.of(context)!.delDataCantRecover),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(trueText ?? AppLocalizations.of(context)!.delete,
                      style: const TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    falseText ?? AppLocalizations.of(context)!.cancel,
                  )),
            ],
          );
        });
    return result ?? false;
  }
}
