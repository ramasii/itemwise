import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itemwise/allpackages.dart';
import 'package:http/http.dart' as http;

class itemApiWise {
  String url = "${anu.emm}/barang";
  String id_user =
      userWise.isLoggedIn ? userWise.userData["id_user"] : deviceData.id;

  createBulk() async {
    log("backup barang");

    try {
      var enkodeItems =
          Uri.encodeQueryComponent(jsonEncode(ItemWise().readByUser()));
      var response =
          await http.post(Uri.parse("$url/addBulk?items=$enkodeItems"),
              // Uri.parse("$url/addBulk"),
              headers: {
            "Content-Type": "application/json",
            "authorization": authapi.authorization,
          });
      switch (response.statusCode) {
        case 200:
          log("sukses");
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          // tambahkan ulang
          await createBulk();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // tambah ulang
            await createBulk();
          } else if (response.body == "token not found") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // tambah ulang
            await createBulk();
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print("bakup brg: $e");
    }
  }

  create({
    String id_barang = '',
    String? id_user,
    String? id_inventory,
    String kode_barang = '',
    String nama_barang = '',
    String catatan = '',
    String stok_barang = '',
    String harga_beli = '',
    String harga_jual = '',
    String? photo_barang,
    String added = '',
    String edited = '',
  }) async {
    log("itemapi create one");
    try {
      var response = await http.post(
          Uri.parse(
                "$url/add?id_barang=$id_barang&id_user=$id_user&id_inventory=$id_inventory&kode_barang=$kode_barang&nama_barang=$nama_barang&catatan=$catatan&stok_barang=$stok_barang&harga_beli=$harga_beli&harga_jual=$harga_jual&photo_barang=$photo_barang&added=$added&edited=$edited"
              ),
          headers: {
            "Content-Type": "application/json",
            "authorization": authapi.authorization,
          });

      switch (response.statusCode) {
        case 200:
          log("sukses");
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          // tambahkan ulang
          await create();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.toString() == "token invalid") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // tambah ulang
            await create();
          } else if (response.toString() == "token not found") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // tambah ulang
            await create();
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print("bakup brg: $e");
    }
  }

  read() async {
    log("START: IMPORT ITEM CONNECT TO SERVER");

    try {
      var response = await http.get(Uri.parse("$url/byUser"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses");
          var itms = jsonDecode(response.body);

          // clear ItemWise
          await ItemWise().clear();
          // ubah data ItemWise
          await ItemWise().setAll(itms);
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          // impor ulang
          read();
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // impor ulang
            read();
          } else if (response.body == "token not found") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // impor ulang
            read();
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print("$e read()");
    }
  }

  update(String id_barang,
      {String? id_user,
      String? id_inventory,
      String? nama_barang,
      int? stok_barang,
      int? harga_beli,
      int? harga_jual,
      String? kode_barang,
      String? catatan,
      String? photo_barang,
      String? added,
      String? edited}) async {
    log("START update itemapi");
    try {
      var response = await http.put(
          Uri.parse(
              "${url}/update?id_barang=$id_barang&id_user=$id_user&id_inventory=$id_inventory&nama_barang=$nama_barang&stok_barang=$stok_barang&harga_beli=$harga_beli&harga_jual=$harga_jual&kode_barang=$kode_barang&catatan=$catatan&photo_barang=$photo_barang&edited=$edited"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log("sukses");
          break;
        case 401:
          log("token expired");
          // ambil token baru
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          // udpate ulang
          await update(id_barang,
              id_user: id_user,
              id_inventory: id_inventory,
              nama_barang: nama_barang,
              stok_barang: stok_barang,
              harga_beli: harga_beli,
              harga_jual: harga_jual,
              kode_barang: kode_barang,
              catatan: catatan,
              photo_barang: photo_barang,
              edited: edited);
          break;
        case 403:
          // auth baru
          log("auth baru");
          if (response.body == "token invalid") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // update ulang
            await update(id_barang,
                id_user: id_user,
                id_inventory: id_inventory,
                nama_barang: nama_barang,
                stok_barang: stok_barang,
                harga_beli: harga_beli,
                harga_jual: harga_jual,
                kode_barang: kode_barang,
                catatan: catatan,
                photo_barang: photo_barang,
                edited: edited);
          } else if (response.body == "token not found") {
            await authapi().auth(userWise.userData['email_user'],
                userWise.userData['password_user']);
            // update ulang
            await update(id_barang,
                id_user: id_user,
                id_inventory: id_inventory,
                nama_barang: nama_barang,
                stok_barang: stok_barang,
                harga_beli: harga_beli,
                harga_jual: harga_jual,
                kode_barang: kode_barang,
                catatan: catatan,
                photo_barang: photo_barang,
                edited: edited);
          }
          break;
        default:
          log(response.statusCode.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  readAll() async {
    log("START get all items data");
    try {
      var response = await http.get(Uri.parse("$url/"),
          headers: {"authorization": authapi.authorization});
      switch (response.statusCode) {
        case 200:
          adminAccess.itemList = jsonDecode(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await readAll();
          break;
        default:
          log("itemAPI: ${response.statusCode}");
      }
    } catch (e) {
      print("itemAPI: $e");
    }
  }

  delete(String id_barang) async {
    log("delete itemapi");
    try {
      var response = await http.delete(
          Uri.parse("${url}/delete?id_barang=$id_barang"),
          headers: {"authorization": authapi.authorization});

      switch (response.statusCode) {
        case 200:
          log(response.body);
          break;
        case 401:
          await authapi().auth(userWise.userData['email_user'],
              userWise.userData['password_user']);
          await delete(id_barang);
          break;
        default:
          log("itemapi: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }
}
