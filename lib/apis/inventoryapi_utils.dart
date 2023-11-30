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
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          // tambahkan ulang
          await create();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // tambah ulang
            await create();
          } else if (response.body == "token not found") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
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
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          // impor ulang
          read();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // impor ulang
            read();
          } else if (response.body == "token not found") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
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
      var response = await http.get(Uri.parse("$url/"),
          headers: {"authorization": authapi.authorization});
      switch (response.statusCode) {
        case 200:
          adminAccess.invList = jsonDecode(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await readAll();
          break;
        default:
          log("inventoryAPI: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("inventoryAPI: $e");
    }
  }

  update(
      {String id_inventory = "",
      String? id_user,
      String nama_inventory = ""}) async {
    log("START update inv");
    log("$id_inventory,$id_user,$nama_inventory");
    try {
      var response = await http.put(
          Uri.parse(
              "$url/update?id_inventory=$id_inventory&id_user=$id_user&nama_inventory=$nama_inventory"),
          headers: {"authorization": authapi.authorization});
      switch (response.statusCode) {
        case 200:
          log("update inv ok: ${response.body}");
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await update(
              id_inventory: id_inventory,
              id_user: id_user,
              nama_inventory: nama_inventory);
          break;
        default:
          log("inventoryAPI: ${response.statusCode}");
      }
    } catch (e) {
      print("inv update api: $e");
    }
  }

  delete(String id_inventory) async {
    log("delete inventoryapi");
    try {
      var response = await http.delete(
          Uri.parse("${url}/delete?id_inventory=$id_inventory"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await delete(id_inventory);
          break;
        default:
          log("inventoryapi: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }
}
