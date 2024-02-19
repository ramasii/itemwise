import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // HATI HATI!: ini bertabrakan dengan widget Column dari flutter
import 'package:image_size_getter/image_size_getter.dart';
import 'allpackages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PickImageFrom { gallery, camera }

/// ini sebenernya multifungsi, berisi fungsi atau variabel global
/// mungkin bisa bikin efisien
class fungsies {
  Widget buildFotoBarang(BuildContext context, Map barang, String id) {
    return /* InkWell(
      onTap: () async {
        Uint8List imgBytes = base64Decode(barang["photo_barang"]);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PhotoViewPage(
            barang['id_barang'],
            imgBytes
          );
        }));
      },
      child: */
        Container(
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
                tag: "image${barang['id_barang']}",
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
    /* ); */
  }

  Future<bool> isConnected() async {
    var a = InternetConnectionCheckerPlus.createInstance(
        addresses: [AddressCheckOptions(Uri.parse(apiAddress.address))]);
    var internet = await a.connectionStatus;
    if (internet == InternetConnectionStatus.connected) {
      print('Terhubung ke internet');
      return true;
    } else {
      print('Tidak terhubung ke internet');
      return false;
    }
  }

  /// akan mengembalikan String kosongan `""` jika tidak mengambil gambar
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

  /// fungsi untuk mengubah data menjadi excel, akan mengembalikan List<int> Bytes
  generateExcel(List dataBarang) async {
    log("START generate excel");
    // buat workbook
    final Workbook workbook = Workbook();

    // buat sheet
    final Worksheet sheet1 = workbook.worksheets[0];

    // buat header
    // set style
    sheet1.getRangeByName('A1:G1').cellStyle.backColor = '#5B9BD5';
    sheet1.getRangeByName('A1:G1').cellStyle.fontColor = '#FFFFFF';
    sheet1.getRangeByName('A1:G1').cellStyle.borders.all.lineStyle =
        LineStyle.thin;
    sheet1.getRangeByName('A1:G1').cellStyle.borders.all.color = '#000000';
    // set ukuran
    sheet1.getRangeByName('A1').columnWidth = 6;
    sheet1.getRangeByName('B1:G1').columnWidth = 15;
    // nomor
    sheet1.getRangeByName('A1').setValue("No.");
    // nama brg
    sheet1.getRangeByName('B1').setValue("Nama Barang");
    // kode brg
    sheet1.getRangeByName('C1').setValue("Kode Barang");
    // deskripsi
    sheet1.getRangeByName('D1').setValue("Deskripsi");
    // stok
    sheet1.getRangeByName('E1').setValue("Stok Barang");
    // hrg beli
    sheet1.getRangeByName('F1').setValue("Harga Beli");
    // hrg jual
    sheet1.getRangeByName('G1').setValue("Harga Jual");

    // untuk setiap data barang, maka tambahkan satu baris
    for (int idxBarang = 0; idxBarang < dataBarang.length; idxBarang++) {
      log("menulis data ke-${idxBarang + 1} dari ${dataBarang.length}");
      // dapatkan barang
      Map brg = dataBarang[idxBarang];
      // buat indexBaris
      int indexBaris =
          idxBarang + 2; // +1 minimun index, dan +1 karena ada header
      // set border
      sheet1
          .getRangeByIndex(indexBaris, 1, indexBaris, 7)
          .cellStyle
          .borders
          .all
          .lineStyle = LineStyle.thin;
      sheet1
          .getRangeByIndex(indexBaris, 1, indexBaris, 7)
          .cellStyle
          .borders
          .all
          .color = "#000000";

      // set nilai ke baris(row)
      sheet1.getRangeByIndex(indexBaris, 1).setValue(idxBarang + 1);
      sheet1.getRangeByIndex(indexBaris, 2).setValue(brg['nama_barang']);
      sheet1.getRangeByIndex(indexBaris, 3).setValue(brg['kode_barang']);
      sheet1.getRangeByIndex(indexBaris, 4).setValue(brg['catatan']);
      sheet1.getRangeByIndex(indexBaris, 5).setValue(brg['stok_barang']);
      sheet1.getRangeByIndex(indexBaris, 6).setValue(brg['harga_beli']);
      sheet1.getRangeByIndex(indexBaris, 7).setValue(brg['harga_jual']);
    }

    // bytes dari workbook
    final List<int> bytes = workbook.saveAsStream();
    // dispose workbook
    // workbook.dispose();

    log("generate excel done");

    // return bytes
    return bytes;
  }

  /// cek akses memori sekaligus mengubahd data direktori pengaturan.ekspordir jika null
  cekAksesMemori() async {
    log("cek akses penyimpanan");
    // var status = await Permission.manageExternalStorage.status;
    // if (status.isRestricted || status.isDenied) {
    //   status = await Permission.manageExternalStorage.request();
    // }

    try {
      var storageStatus = await Permission.storage.status;
      if (storageStatus.isRestricted || storageStatus.isDenied) {
        storageStatus = await Permission.storage.request();
      }

      // ubah direktori pengaturan.ekspordir jika null
      if (pengaturan.eksporDir == null) {
        log("ubah direktori pengaturan.ekspordir jika null");
        var newDir = await getExternalStorageDirectory();
        await pengaturan().ubahEksporDir(newDir!);
      }
    } catch (e) {
      log("CEK AKSES MEMORI: $e");
    }
  }
}
