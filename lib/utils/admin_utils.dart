import '../allpackages.dart';
import 'package:http/http.dart';

class adminAccess {
  static List userList = [];
  static List invList = [];
  static List itemList = [];

  saveList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userList", jsonEncode(userList));
    await prefs.setString("invList", jsonEncode(invList));
    await prefs.setString("itemList", jsonEncode(itemList));
  }

  readList()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userList = jsonDecode(prefs.getString("userList") ?? "[]");
    invList = jsonDecode(prefs.getString("invList") ?? "[]");
    itemList = jsonDecode(prefs.getString("itemList") ?? "[]");
  }
}
