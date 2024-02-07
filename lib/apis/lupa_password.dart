import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class lupaPassword {
  String url = "${apiAddress.address}/lupaPass";

  create(String email) async {
    log("start create kode sementara");
    // buat id_kode_s
    String id_kode_s = "${DateTime.now().millisecondsSinceEpoch}ks";
    try {
      final response = await http.post(Uri.parse("$url?email_user=$email&id_kode_s=$id_kode_s"));
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
}
