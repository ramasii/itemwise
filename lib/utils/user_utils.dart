import 'package:itemwise/allpackages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userWise {
  static Map userData = {
    "id_user": "",
    // "username_user": "",
    "email_user": "",
    "role": "user",
    "password_user": "",
  };
  Map resetUserData = {
    "id_user": "",
    // "username_user": "",
    "email_user": "",
    "role": "user",
    "password_user": "",
  };

  static bool isLoggedIn = false;

  /// edit dan create dijadikan satu
  void edit(
      // edit atau create sama saja lo
      {String? id_user,
      // String? username_user,
      String? email_user,
      String? password_user,
      String? role}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ubah data jika tidak null
    userData["id_user"] = id_user ?? userData["id_user"];
    // userData["username_user"] = username_user ?? userData["username_user"];
    userData["email_user"] = email_user ?? userData["email_user"];
    userData["password_user"] = password_user ?? userData["password_user"];
    userData["role"] = role ?? userData["role"];

    // encode userData & ubah isLoggedIn jadi true
    var encoded = jsonEncode(userData);
    isLoggedIn = true;

    // simpan ke perangkat
    await prefs.setString("userData", encoded);
    await prefs.setBool("isLoggedIn", isLoggedIn);
  }

  void read() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ambil data encoded dari perangkat
    var encoded = await prefs.getString("userData");
    var infoLogin = await prefs.getBool("isLoggedIn");
    // jika ditemukan
    if (encoded != null && infoLogin != null) {
      log("data user ketemu");
      log("$encoded\n$infoLogin");
      // deocode data encoded
      var decoded = jsonDecode(encoded);
      // ubah value userData & info login
      userData = decoded;
      isLoggedIn = infoLogin;
    }
    // jika tidak ketemu
    else {
      log("data user tidak ada");
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ubah ke semula
    userData = resetUserData;
    isLoggedIn = false;
    // hapus userData di perangkat
    await prefs.remove("userData");
    // simpan status login
    await prefs.setBool("isLoggedIn", isLoggedIn);
  }
}
