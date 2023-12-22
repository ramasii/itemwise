import 'dart:io';

import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class photoBarangApiWise {
  String url = "${anu.emm}/image";

  create(String id_barang, {String? base64photo}) async {
    log("START UPLOAD FOTO BARANG");
    // prepare variabel
    Uri uri = Uri.parse(url);

    // prepare request
    log("PREPARE REQUEST");
    var request = http.MultipartRequest('POST', uri);
    request.headers['Content-Type'] =
        "multipart/form-data; boundary=<calculated when request is sent>";
    request.fields['id_barang'] = id_barang;
    request.headers['authorization'] = authapi.authorization;

    // ini nambah file dari bytes
    log("ini nambah file dari bytes");
    String base64s =
        base64photo ?? ItemWise().readByIdBarang(id_barang)['photo_barang'];
    if (base64s != "") {
      List<int> byteImg = base64Decode(base64s);
      request.files.add(http.MultipartFile.fromBytes("photo_barang", byteImg,
          filename: "$id_barang.jpg"));
    }

    // mulai kirim request
    log("mulai kirim request");
    var response = await request.send();
    switch (response.statusCode) {
      case 200:
        log("sukses");
        break;
      default:
        log("create photobarang: ${response.statusCode}");
    }
  }

  delete(String id_barang) async {
    log("START DELETE FOTO BARANG: $id_barang");
    // prepare variabel
    Uri uri = Uri.parse("$url?id_barang=$id_barang");

    // prepare request
    log("PREPARE RESPONSE");
    var response = await http
        .delete(uri, headers: {"authorization": authapi.authorization});

    switch (response.statusCode) {
      case 200:
        log("sukses delete: $id_barang");
        break;
      default:
        log("delete photobarang: ${response.statusCode}");
    }
  }

  Future<String?> get(String id_barang) async {
    try {
      var response = await http.get(Uri.parse("$url?id_barang=$id_barang"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          // // simpan file ke itemwise()
          // ItemWise().update(id_barang,
          //     photo_barang: base64Encode(response.bodyBytes));

          // return return byte yang sudah dienkode
          return base64Encode(response.bodyBytes);
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      log("get photobarang: ${e}");
    }
  }
}
