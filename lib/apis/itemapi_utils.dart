import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class itemApiWise {
  String url = "${anu.emm}/barang";
  String id_user =
      userWise.isLoggedIn ? userWise.userData["id_user"] : deviceData.id;

  create() async {
    log("backup barang");

    try {
      var enkodeItems =
          Uri.encodeQueryComponent(jsonEncode(ItemWise().readByUser()));
      var response =
          await http.post(Uri.parse("$url/addBulk?items=$enkodeItems"),
              // Uri.parse("$url/addBulk"),
              headers: {
            "Content-Type": "application/json",
            "authorization": authapi.authorization,
          });
      switch (response.statusCode) {
        case 200:
          log("sukses");
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
          // tambahkan ulang
          await create();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
            // tambah ulang
            await create();
          } else if (response.body == "token not found") {
            await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
            // tambah ulang
            await create();
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print("bakup brg: $e");
    }
  }

  read() async {
    log("START: IMPORT ITEM CONNECT TO SERVER");

    try {
      var response = await http.get(Uri.parse("$url/byUser"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses");
          var itms = jsonDecode(response.body);

          // clear ItemWise
          await ItemWise().clear();
          // ubah data ItemWise
          await ItemWise().setAll(itms);
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
          // impor ulang
          read();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
            // impor ulang
            read();
          } else if (response.body == "token not found") {
            await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
            // impor ulang
            read();
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print("$e read()");
    }
  }

  readAll() async {
    log("START get all items data");
    try {
      var response = await http.get(Uri.parse("$url/"),
          headers: {"authorization": authapi.authorization});
      switch (response.statusCode) {
        case 200:
          adminAccess.itemList = jsonDecode(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
          await readAll();
          break;
        default:
          log("itemAPI: ${response.statusCode}");
      }
    } catch (e) {
      print("itemAPI: $e");
    }
  }
}
