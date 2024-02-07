import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class lupaPassword {
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
          .get(Uri.parse("$url/matching?email_user=$email&kode_s=$kode_s"));

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
}
