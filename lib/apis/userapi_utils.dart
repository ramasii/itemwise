import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class userApiWise {
  String url = "${apiAddress.address}/users";

  create(
      {String? id_user,
      String? email_user,
      String? password_user,
      String role = "user",
      bool isAdmin = false}) async {
    log("create user to API");
    try {
      final response = await http.post(Uri.parse(
          "$url/add?id_user=$id_user&email_user=$email_user&password_user=$password_user&role=$role"));
      log(response.body);
      log(email_user!);

      // tambahkan data user ke device
      if (response.statusCode == 200) {
        // isAdmin == false berarti user login, jika true berarti admin nambah user
        if (isAdmin == false) {
          userWise().edit(
              email_user: email_user,
              password_user: password_user,
              id_user: id_user);
          userWise.isLoggedIn = true;
          // langsung auth
          await authapi().auth(email_user, password_user!);
        } else {
          log("sukses nambah user (KAMU ADMIN)");
        }
      } else {
        log(response.statusCode.toString());
      }
    } catch (e) {
      log('$e');
      return;
    }
  }

  /// ini adalah login
  readByEmail(String email_user, String password_user) async {
    // log("read user by email from API");
    try {
      final response = await http.get(Uri.parse(
          "$url/byEmail?email_user=$email_user&password_user=$password_user"));

      switch (response.statusCode) {
        case 200: // ini login berhasil
          print(response.body);
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
          log("userapi read all: ${response.statusCode}");
          adminAccess.userList = jsonDecode(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
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
      String email_user = "",
      String password_user = "",
      String role = "",
      bool isAdmin = false}) async {
    log("update userapi");
    try {
      var response = await http.put(
          Uri.parse(
              "$url/update?id_user=$id_user&email_user=$email_user&password_user=$password_user&role=$role"),
          headers: {"authorization": authapi.authorization});
      switch (response.statusCode) {
        case 200:
          log("SUKSES UPDATE USERAPI");
          // jika mengubah akunnya sendiri maka langsung minta auth + mengubah data akun di device
          if (id_user == userWise.userData['id_user']) {
            log("mengubah dataUser yang digunakan karena melakukan perubahan di database");
            authapi().auth(email_user, password_user);
            userWise()
                .edit(email_user: email_user, password_user: password_user);
          }
          log(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await update(
              id_user: id_user,
              email_user: email_user,
              password_user: password_user,
              role: role);
          break;
        default:
          log("userApiWise: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  delete(String id_user) async {
    log("delete userapi");
    try {
      var response = await http.delete(
          Uri.parse("${url}/delete?id_user=$id_user"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await delete(id_user);
          break;
        default:
          log("userApiWise: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  setPassword(String email, String password) async {
    log("setPassword");
    try {
      var response = await http.put(
          Uri.parse(
              "${apiAddress.address}/users/setPassword?email_user=$email&password=$password"),
          headers: {"authorization": authapi.authorization});
      if (response.statusCode == 200) {
        log("sukses ubah password");
      } else {
        log("setPassword api eror ${response.statusCode}: ${response.body}");
      }
      return response ;
    } catch (e) {
      log("setPassword err: $e");
      return http.Response("[]", 400);
    }
  }
}
