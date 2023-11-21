import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class authapi {
  static String authorization = "";

  auth() async {
    try {
      var response = await http.get(Uri.parse(
          "${anu.emm}/auth?email_user=${userWise.userData['email_user']}&password_user=${userWise.userData['password_user']}"));
      switch (response.statusCode) {
        // sukses
        case 200:
          log("dapet authorization");
          authorization = jsonDecode(response.body)["token"];
          log(authorization);
          break;
        case 403:
          log("ga boleh gitu bro");
          break;
        case 500:
          log("mungkin eror di server");
          break;
        default:
          log("${response.statusCode}");
      }
    } catch (e) {
      log("$e");
    }
    // simpan ke device
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("authorization", authorization);
  }

  loadAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loaded = prefs.getString("authorization");
    if (loaded != null) {
      log("auth ketemu");
      authorization = loaded;
    } else {
      log("auth ga ketemu");
      try {
        if (userWise.isLoggedIn) {
          await auth();
          log("coba auth");
        }
      } catch (e) {
        print(e);
      }
    }
  }
}