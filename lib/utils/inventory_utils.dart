import 'package:itemwise/allpackages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class inventoryWise {
  // STRING id_inventory,id_user,nama_inventory
  static List inventories = [];

  void create(
      String id_inventory, String id_user, String nama_inventory) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // buat var obj
    Map obj = {
      "id_inventory": id_inventory,
      "id_user": id_user,
      "nama_inventory": nama_inventory
    };
    // tambah obj ke inventories
    inventories.add(obj);
    // ubah inventories menjadi String
    String str = jsonEncode(inventories);
    // simpan str di internal
    await prefs.setString('inventories', str);
    log("DONE create - inventory");
  }

  void read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ambil data dari sistem
    String? str = await prefs.getString('inventories');
    // jika key nya ketemu
    if (str != null) {
      log("inventories ketemu");
      // decode str menjadi List<Map>
      List decoded = jsonDecode(str);
      // ubah nilai inventories
      inventories = decoded;
    }
    // jika tidak ketemu
    else {
      log("inventories tidak ketemu");
    }
  }

  List readByUser(String id_user) {
    List inv =
        inventories.where((element) => element['id_user'] == id_user).toList();
    return inv;
  }

  Map? readById(String id_inventory) {
    Map? inv = inventories.firstWhere(
        (element) => element["id_inventory"] == id_inventory,
        orElse: () => null);
    return inv;
  }

  void update(
      String id_inventory, String id_user, String nama_inventory) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = inventories
        .indexWhere((element) => element["id_inventory"] == id_inventory);

    // buat var obj
    Map obj = {
      "id_inventory": id_inventory,
      "id_user": id_user,
      "nama_inventory": nama_inventory
    };
    // ubah langsung di inventories
    inventories[index] = obj;
    // ubah inventories menjadi String
    String str = jsonEncode(inventories);
    // simpan str di internal
    await prefs.setString('inventories', str);
  }

  void delete(String id_inventory) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // delete dari inventories
    inventories
        .removeWhere((element) => element["id_inventory"] == id_inventory);
    // ubah inventories menjadi String
    String str = jsonEncode(inventories);
    // simpan str di internal
    await prefs.setString('inventories', str);
  }
}
