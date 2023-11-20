import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class itemApiWise {
  String url = "${anu.emm}/barang";
  String id_user =
      userWise.isLoggedIn ? userWise.userData["id_user"] : deviceData.id;

  create(String id_barang) async {
    log("backup barang");

    Map item = ItemWise()
        .readByUser(id_user)
        .firstWhere((element) => element["id_barang"] == id_barang);

    // id_barang uda ada
    // id_user uda ada
    String id_inventory = item['id_inventory'];
    String kode_barang = item['kode_barang'];
    String nama_barang = item['nama_barang'];
    String catatan = item['catatan'];
    int stok_barang = item['stok_barang'];
    int harga_beli = item['harga_beli'];
    int harga_jual = item['harga_jual'];
    String photo_barang = item['photo_barang'];
    String added = item['added'];
    String edited = item['id_inventory'];

    try {
      var response = await http.post(Uri.parse(
          "$url/add?id_barang=$id_barang&id_user=$id_user&id_inventory=$id_inventory&kode_barang=$kode_barang&nama_barang=$nama_barang&catatan=$catatan&stok_barang=$stok_barang&harga_beli=$harga_beli&harga_jual=$harga_jual&photo_barang=$photo_barang&added=$added&edited=$edited"),
          headers: {"authorization":authapi.authorization});
      
      switch (response.statusCode) {
        case 200:
          log("sukses");
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth();
          // tambahkan ulang
          await create(id_barang);
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth();
            // tambah ulang
            await create(id_barang);
          } else if (response.body == "token not found") {
            await authapi().auth();
            // tambah ulang
            await create(id_barang);
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }
}
