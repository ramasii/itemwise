import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class authapi {
  static String authorization = "";

  auth(String email_user, String password_user) async {
    log("start auth: ${userWise.userData}");
    log("${anu.emm}/auth?email_user=${userWise.userData['email_user']}&password_user=${userWise.userData['password_user']}");
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
          log("authapi auth: ${response.statusCode}");
      }
    } catch (e) {
      log("$e");
    }
    // simpan ke device
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("authorization", authorization);
    log("done auth");
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
          await auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          log("coba auth");
        }
      } catch (e) {
        log(e.toString());
      }
    }
  }
}
