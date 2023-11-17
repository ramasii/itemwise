import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class userApiWise {
  String url = "${anu.emm}/users";

  create(
      {String? id_user,
      String? username_user,
      String? email_user,
      String? photo_user,
      String? password_user}) async {
    log("create user to API");
    try {
      final response = await http.post(Uri.parse(
          "$url/add?id_user=$id_user&username_user=$username_user&email_user=$email_user&photo_user=$photo_user&password_user=$password_user"));
      log(response.body);
      log(email_user!);

      // tambahkan data user ke device
      if (response.statusCode == 200) {
        userWise().edit(
            username_user: username_user,
            email_user: email_user,
            password_user: password_user,
            id_user: id_user);
        userWise.isLoggedIn = true;
      } else {
        log(response.statusCode.toString());
      }
    } catch (e) {
      log('$e');
    }
  }

  readByEmail(String email_user, String password_user) async {
    log("read user by email from API");
    try {
      final response = await http.get(Uri.parse(
          "$url/byEmail?email_user=$email_user&password_user=$password_user"));

      switch (response.statusCode) {
        case 200: // ini login berhasil
          log(response.body);
          return response;
        case 406:
          log("password salah");
          return response;
        case 204: // kalo user ga ada, maka tambahkan user
          log("user ga ada");
          return response;
        default:
          log('mungkin server eror: ${response.statusCode}');
          return response;
      }
    } catch (e) {
      log('$e');
    }
  }

  void update() async {
    //...
  }

  void delete() async {
    //...
  }
}
