import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class inventoryApiWise {
  String url = "${anu.emm}/inventory";

  create() async {
    log("backup inv");
    // log(jsonEncode(inventoryWise.inventories));

    try {
      var response = await http.post(
          Uri.parse(
              "$url/addBulk?invs=${jsonEncode(inventoryWise().readByUser())}"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses");
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth();
          // tambahkan ulang
          await create();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth();
            // tambah ulang
            await create();
          } else if (response.body == "token not found") {
            await authapi().auth();
            // tambah ulang
            await create();
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      log("$e");
    }
  }

  read() async {
    log("START: IMPORT INVENTORY CONNECT TO SERVER");

    try {
      var response = await http.get(Uri.parse("$url/byUser"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses");
          var invs = jsonDecode(response.body);
          log("$invs");

          // clear Inventory
          await inventoryWise().clear();
          // ubah data inventori
          await inventoryWise().setAll(invs);
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth();
          // impor ulang
          read();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth();
            // impor ulang
            read();
          } else if (response.body == "token not found") {
            await authapi().auth();
            // impor ulang
            read();
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  readAll() async {
    log("START get all inv data");
    try {
      var response = await http.get(Uri.parse("$url/"),headers: {
        "authorization":authapi.authorization
      });
      switch (response.statusCode) {
        case 200:
          adminAccess.invList = jsonDecode(response.body);
          break;
        case 401:
          await authapi().auth();
          await readAll();
          break;
        default:
          log("inventoryAPI: ${response.statusCode}");
      }
    } catch (e) {
      print("inventoryAPI: $e");
    }
  }
}
