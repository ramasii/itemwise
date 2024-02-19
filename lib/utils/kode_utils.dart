import 'package:flutter/cupertino.dart';
import 'package:itemwise/allpackages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class kodeWise {
  List kodeList = [];

  addList(List list) async {
    log("start kodewise addlist");

    kodeList = list;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(list);
    await prefs.setString("kodeList", encoded);

    log("done kodewise addlist");
  }

  loadList() async {
    log("start kodewise loadList");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedList = prefs.getString("kodeList");

    if (encodedList != null) {
      kodeList = jsonDecode(encodedList);
      log("done kodeWise loadList: data ditemukan");
    } else {
      log("done kodeWise loadList: null");
    }
  }
}
