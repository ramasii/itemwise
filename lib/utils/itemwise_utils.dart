import 'package:itemwise/allpackages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemWise {
  static List items = [];
  Map item = {
    "id_barang": "",
    "id_user": "",
    "id_inventory": "",
    "kode_barang": "",
    "nama_barang": "",
    "catatan": "",
    "stok_barang": 0,
    "harga_beli": 0,
    "harga_jual": 0,
    "photo_barang": "",
    "added": "",
    "edited": "",
  };
  Map resetItem = {
    "id_barang": "",
    "id_user": "",
    "id_inventory": "",
    "kode_barang": "",
    "nama_barang": "",
    "catatan": "",
    "stok_barang": 0,
    "harga_beli": 0,
    "harga_jual": 0,
    "photo_barang": "",
    "added": "",
    "edited": "",
  };

  void create(String id_barang, String id_user, String nama_barang,
      int stok_barang, int harga_beli, int harga_jual,
      {String? id_inventory,
      String? kode_barang,
      String? catatan,
      String? photo_barang,
      String? added,
      String? edited}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ubah nilai item
    item["id_barang"] = id_barang;
    item["id_user"] = id_user;
    item["nama_barang"] = nama_barang;
    item["stok_barang"] = stok_barang;
    item["harga_beli"] = harga_beli;
    item["harga_jual"] = harga_jual;
    item["id_inventory"] = id_inventory /* ?? "all" */;
    item["kode_barang"] = kode_barang ?? "";
    item["catatan"] = catatan ?? "";
    item["photo_barang"] = photo_barang ?? "";
    item["added"] = added ?? "";
    item["edited"] = edited ?? "";

    // tambahkan item ke items
    items.add(item);
    // reset item
    item = resetItem;
    // encode items
    var encoded = jsonEncode(items);

    // simpan items di device
    await prefs.setString("items", encoded);
  }

  void read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ambil items(encoded) dari device
    var encoded = prefs.getString("items");
    // jika ketemu
    if (encoded != null) {
      log("items ketemu");
      // decode encoded
      var decoded = jsonDecode(encoded);
      // ubah items
      items = decoded;
    } else {
      log("items tidak ditemukan");
    }
  }

  List readByUser() {
    String id_user =
        userWise.isLoggedIn ? userWise.userData['id_user'] : deviceData.id;
    var filtered = items.where((element) => element["id_user"] == id_user);
    return filtered.toList();
  }

  List readByInventory(String id_inventory, String id_user) {
    if (id_inventory != "all") {
      var filtered = items.where((element) =>
          element["id_inventory"] == id_inventory &&
          element["id_user"] == id_user);
      return filtered.toList();
    } else {
      var filtered = items.where((element) => element["id_user"] == id_user);
      return filtered.toList();
    }
  }

  Map readByIdBarang(String id_barang) {
    Map byIdBarang = readByUser()
        .firstWhere((element) => element['id_barang'] == id_barang);
    return byIdBarang;
  }

  update(String id_barang,
      {String? id_user,
      String? id_inventory,
      String? nama_barang,
      int? stok_barang,
      int? harga_beli,
      int? harga_jual,
      String? kode_barang,
      String? catatan,
      String? photo_barang,
      String? added,
      String? edited}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // cari index berdasarkan id_barang
    var idx = items.indexWhere((element) => element["id_barang"] == id_barang);

    // ubah nilai element berdasarkan index
    items[idx]["id_barang"] = id_barang;
    items[idx]["id_user"] = id_user ?? items[idx]["id_user"];
    items[idx]["id_inventory"] =
        id_inventory /* ?? items[idx]["id_inventory"] */;
    items[idx]["nama_barang"] = nama_barang ?? items[idx]["nama_barang"];
    items[idx]["stok_barang"] = stok_barang ?? items[idx]["stok_barang"];
    items[idx]["harga_beli"] = harga_beli ?? items[idx]["harga_beli"];
    items[idx]["harga_jual"] = harga_jual ?? items[idx]["harga_jual"];
    items[idx]["kode_barang"] = kode_barang ?? items[idx]["kode_barang"];
    items[idx]["catatan"] = catatan ?? items[idx]["catatan"];
    items[idx]["photo_barang"] = photo_barang ?? items[idx]["photo_barang"];
    items[idx]["added"] = added ?? items[idx]["added"];
    items[idx]["edited"] = edited ?? items[idx]["edited"];
    // dengan begini nilai di dalam items bakal berubah

    // encode items
    var encoded = jsonEncode(items);
    // simpan items di device
    await prefs.setString("items", encoded);
  }

  void delete(String id_barang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // hapus dari items
    items.removeWhere((element) => element["id_barang"] == id_barang);
    // encode items
    var encoded = jsonEncode(items);
    // simpan items di device
    await prefs.setString("items", encoded);
  }

  clear() async {
    log("DONE CLEAR ITEMS");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    items.clear();
    // encode items
    var encoded = jsonEncode(items);
    // simpan items di device
    await prefs.setString("items", encoded);
    log("DONE CLEAR ITEMS");
  }

  setAll(List itms) async {
    log("DONE SETALL ITEMS");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    items = itms;
    // encode items
    var encoded = jsonEncode(items);
    // simpan items di device
    await prefs.setString("items", encoded);
    log("DONE SETALL ITEMS");
  }
}
