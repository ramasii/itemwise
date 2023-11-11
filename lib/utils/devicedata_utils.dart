import 'package:itemwise/allpackages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class deviceData {
  static String id = "";

  edit(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = deviceId;
    await prefs.setString("deviceId", id);
  }

  void reset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = "";
    await prefs.remove("deviceId");
  }

  Future<bool> isKeyAvailable(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var a = await prefs.getString(key);
    if (a == null) {
      log("deviceId tidak ditemukan");
      return false;
    } else {
      log("deviceId ditemukan");
      id = a;
      return true;
    }
  }
}
