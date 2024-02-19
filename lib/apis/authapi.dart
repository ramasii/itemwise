import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class authapi {
  static String authorization = "";

  auth(String email_user, String password_user) async {
    log("start auth: ${userWise.userData}");
    log("${apiAddress.address}/auth?email_user=${userWise.userData['email_user']}&password_user=${userWise.userData['password_user']}");
    try {
      var response = await http.get(Uri.parse(
          "${apiAddress.address}/auth?email_user=${userWise.userData['email_user']}&password_user=${userWise.userData['password_user']}"));

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

  shortAuth(String email_user, String kode_s) async {
    try {
      var response = await http.get(Uri.parse(
          "http://localhost:8003/xiirpl1_03/api/auth/shortAuth?email_user=$email_user&kode_s=$kode_s"));

      if (response.statusCode == 200) {
        log("dapet short authorization");
        authorization = jsonDecode(response.body)['token'];
        log("token: $authorization");
      } else {
        log("shortAuth error ${response.statusCode}: ${response.body}");
      }

      return response;
    } catch (e) {
      log("shortAuth catch eror: $e");
      return http.Response("[]", 400);
    }
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
