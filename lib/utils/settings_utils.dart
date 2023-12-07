import 'package:itemwise/allpackages.dart';

enum currencies { rupiah, dollar, ringgit, yen }

class pengaturan {
  static String mataUang = "Rp.";

  ubahMataUang(var mata) async {
    switch (mata) {
      case currencies.rupiah:
        mataUang = "Rp.";
        break;
      case currencies.dollar:
        mataUang = "\$";
        break;
      case currencies.ringgit:
        mataUang = "RM";
        break;
      case currencies.yen:
        mataUang = "¥";
        break;
      default:
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("pengaturan.mataUang", mataUang);
  }

  loadPengaturan() async {
    log("START memuat pengaturan");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mataUang = prefs.getString("pengaturan.mataUang") ?? "Rp.";
    log("DONE membuat pengaturan");
  }
}
