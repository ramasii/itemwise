import 'package:itemwise/allpackages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userWise {
  static Map userData = {
    "id_user": "",
    "username_user": "",
    "email_user": "",
    "role": "user",
    "photo_user": null,
    "password_user": "",
  };
  Map resetUserData = {
    "id_user": "",
    "username_user": "",
    "email_user": "",
    "role": "user",
    "photo_user": null,
    "password_user": "",
  };

  static bool isLoggedIn = false;

  void edit( // edit atau create sama saja lo
      {String? id_user,
      String? username_user,
      String? email_user,
      String? photo_user,
      String? password_user}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ubah data jika tidak null
    userData["id_user"] = id_user ?? userData["id_user"];
    userData["username_user"] = username_user ?? userData["username_user"];
    userData["email_user"] = email_user ?? userData["email_user"];
    userData["photo_user"] = photo_user ?? userData["photo_user"];
    userData["password_user"] = password_user ?? userData["password_user"];

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
    // jika ditemukan
    if (encoded != null) {
      log("data user ketemu");
      // deocode data encoded
      var decoded = jsonDecode(encoded);
      // ubah value userData
      userData = decoded;
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
