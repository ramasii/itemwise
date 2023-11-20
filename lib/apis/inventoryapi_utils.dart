import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class inventoryApiWise {
  String url = "${anu.emm}/inventory";

  create(
      {String? id_inventory, String? id_user, String? nama_inventory}) async {
    log("backup inv");
    
    try {
      var response = await http.post(
          Uri.parse(
              "$url/add?id_inventory=$id_inventory&id_user=$id_user&nama_inventory=$nama_inventory"),
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
          await create(
              id_inventory: id_inventory,
              id_user: id_user,
              nama_inventory: nama_inventory);
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth();
            // tambah ulang
            await create(
                id_inventory: id_inventory,
                id_user: id_user,
                nama_inventory: nama_inventory);
          } else if (response.body == "token not found") {
            await authapi().auth();
            // tambah ulang
            await create(
                id_inventory: id_inventory,
                id_user: id_user,
                nama_inventory: nama_inventory);
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      log("$e");
    }
  }
}
