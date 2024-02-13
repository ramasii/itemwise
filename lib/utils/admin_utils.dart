import '../allpackages.dart';
import 'package:http/http.dart';

class adminAccess {
  static List userList = [];
  static List invList = [];
  static List itemList = [];
  static List kodeList = [];

  saveList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userList", jsonEncode(userList));
    await prefs.setString("invList", jsonEncode(invList));
    await prefs.setString("itemList", jsonEncode(itemList));
    await prefs.setString("kodeList", jsonEncode(kodeList));
  }

  readList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userList = jsonDecode(prefs.getString("userList") ?? "[]");
    invList = jsonDecode(prefs.getString("invList") ?? "[]");
    itemList = jsonDecode(prefs.getString("itemList") ?? "[]");
    kodeList = jsonDecode(prefs.getString("kodeList") ?? "[]");
  }
}
