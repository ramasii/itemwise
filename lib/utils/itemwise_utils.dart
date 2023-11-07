import 'package:itemwise/allpackages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemWise {
  static List items = [];

  static Future<void> saveItems() async {
    log('START saveItems');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String a = jsonEncode(ItemWise.items);

    await prefs.setString('items', a);
    log('DONE saveItems');
  }

  static getItems() async {
    log('START getItems');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    log(prefs.getString('items') == null ? 'items null' : 'items ada');

    String a = prefs.getString('items') ?? "[]";

    List b = jsonDecode(a);

    ItemWise.items = b;

    log('DONE getItems');
    return b;
  }

  static deleteItem(String id) {
    log('START deleteItem');
    ItemWise.items.removeWhere((element) => element['id']==id);
  }

  static Future<void> addItem(String name, String desc, String stock,
      String purPrice, String selPrice, String img) async {
    log('START addItem');
    var a = DateTime.now().millisecondsSinceEpoch.toString();
    ItemWise.items.add({
      "id": a,
      "name": name,
      "desc": desc,
      "stock": stock,
      "purPrice": purPrice,
      "selPrice": selPrice,
      "addedTime": a,
      "editedTime": a,
      "img": img
    });
    log('DONE addItem');
  }

  static Future<void> editItem(String id, String name, String desc,
      String stock, String purPrice, String selPrice, String img) async {
    log('START editItem id:$id');
    var a = DateTime.now().millisecondsSinceEpoch.toString();

    ItemWise.items[items.indexWhere((element) => element['id'] == id)] = {
      "id": id,
      "name": name,
      "desc": desc,
      "stock": stock,
      "purPrice": purPrice,
      "selPrice": selPrice,
      "addedTime": ItemWise.items
          .firstWhere((element) => element['id'] == id)['addedTime'],
      "editedTime": a,
      "img": img
    };
    log('DONE editItem id:$id');
  }
}
