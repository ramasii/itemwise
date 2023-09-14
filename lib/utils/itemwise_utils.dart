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
  }

  static Future<void> addItem(
      String name, String desc, String stock, String purPrice, String selPrice) async {
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
    });
    log('DONE addItem');
  }
}
