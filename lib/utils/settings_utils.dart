import 'package:itemwise/allpackages.dart';

enum currencies { rupiah, dollar, ringgit, yen }

enum sorter { name12, name21, added12, added21, stock12, stock21, hjual12, hjual21 }

class pengaturan {
  static String mataUang = "Rp.";
  static sorter sortBy = sorter.name12;
  static Directory? eksporDir;

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

  loadMataUang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mataUang = prefs.getString("pengaturan.mataUang") ?? "Rp.";
  }

  ubahSorting(sorter by) async {
    log("ubah sorter->${by.name}");
    sortBy = by;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("pengaturan.sortBy", by.name);
  }

  loadSorting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tempSort = prefs.getString("pengaturan.sortBy") ?? "name12";
    sortBy = sorter.values.firstWhere((element) => element.name == tempSort);
  }

  ubahEksporDir(Directory newDir) async {
    log("ubah ekspordir->${newDir.path}");
    eksporDir = newDir;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("pengaturan.eksporDir", newDir.path);
  }

  loadEksporDir() async {
    log("START load ekspordir");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tempPath = prefs.getString("pengaturan.eksporDir");
    if (tempPath != null) {
      log("dir ketemu");
      eksporDir = Directory(tempPath);
    }
  }

  loadPengaturan() async {
    log("START memuat pengaturan");
    loadMataUang();
    loadSorting();
    loadEksporDir();
    log("DONE memuat pengaturan");
  }
}
