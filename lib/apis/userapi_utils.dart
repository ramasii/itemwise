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
        // langsung auth
        await authapi().auth(email_user, password_user!);
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

  readAll() async {
    log("START get all users data");
    try {
      var response = await http.get(Uri.parse("$url/"),
          headers: {"authorization": authapi.authorization});
      switch (response.statusCode) {
        case 200:
          adminAccess.userList = jsonDecode(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
          await readAll();
          break;
        default:
          log("userApiWise: ${response.statusCode}");
      }
    } catch (e) {
      print("userApiWise: $e");
    }
  }

  update(
      {String id_user = "",
      String username_user = "",
      String email_user = "",
      String password_user = "",
      String photo_user = "",
      String role = ""}) async {
    log("update userapi");
    try {
      var response = await http.put(
          Uri.parse(
              "$url/update?id_user=$id_user&username_user=$username_user&email_user=$email_user&password_user=$password_user&photo_user=$photo_user&role=$role"),
          headers: {"authorization": authapi.authorization});
      switch (response.statusCode) {
        case 200:
          log(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'], userWise.userData['password_user']);
          await update(
              id_user: id_user,
              username_user: username_user,
              email_user: email_user,
              password_user: password_user,
              photo_user: photo_user,
              role: role);
          break;
        default:
          log("userApiWise: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  void delete() async {
    //...
  }
}
