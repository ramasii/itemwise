import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class kodeApiWise {
  String url = "${apiAddress.address}/lupaPass";

  /// untuk membuat kode sementara
  create(String email) async {
    log("start create kode sementara");
    // buat id_kode_s
    String id_kode_s = "${DateTime.now().millisecondsSinceEpoch}ks";
    try {
      final response = await http
          .post(Uri.parse("$url?email_user=$email&id_kode_s=$id_kode_s"));
      switch (response.statusCode) {
        case 200:
          log("sukses membuat kode sementara");
          return response;
        default:
          log("membuat kode sementara kode ${response.statusCode}: ${response.body}");
          return response;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// untuk mencocokkan email dan kode sementara di database
  matchingKodeS(String email, String kode_s) async {
    log("start getByEmailKode: $email - $kode_s");
    try {
      final response = await http
          .get(Uri.parse("$url/matching?email_user=$email&kode_s=$kode_s"),headers: {"authorization":authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses lupaPass getByEmailKode: ${response.body}");
          return response;
        default:
          log("lupaPass getByEmailKode ${response.statusCode}: ${response.body}");
          return response;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  /// read semua data kode_s
  ///
  /// harus admin
  readAll() async {
    log("start read all data kode_s");
    try {
      final response = await http.get(Uri.parse("$url/"),
          headers: {'authorization': authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses read kode_s");
          adminAccess.kodeList = jsonDecode(response.body);
          return response;
        default:
          log("API kode_s read all data: ${response.body}");
      }
    } catch (e) {
      log("API kode_s read all data err: $e");
    }
  }

  /// delete kode
  ///
  /// harus admin
  delete(String id_kode_s) async {
    log("START DELETE kode_s: $id_kode_s");

    try {
      final response = await http.delete(Uri.parse("$url/$id_kode_s"),
          headers: {'authorization': authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses delete kode_s");
          return response;
        default:
          log("API kode_s delete data: ${response.body}");
      }
    } catch (e) {
      log("DELETE KODE_S err: $e");
    }
  }

  update(
      String id_kode_s, String email_user, String kode_s, String status) async {
    log("START UPDATE KODE_S: $id_kode_s, $kode_s");

    try {
      var response = await http.put(Uri.parse(
          "$url?id_kode_s=$id_kode_s&email_user=$email_user&kode_s=$kode_s&status=$status"),headers: {'authorization': authapi.authorization});
      
      switch (response.statusCode) {
        case 200:
          log("update kode_s ok: ${response.body}");
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await update(
              id_kode_s,
              email_user,
              kode_s,
              status);
          break;
        default:
          log("kode_s update: ${response.body}");
      }
    } catch (e) {
      log("START UPDATE kode_s: $e");
    }
  }
}
