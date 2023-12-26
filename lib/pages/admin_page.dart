// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itemwise/pages/home_page.dart';
import '../allpackages.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String tableState = "user";
  String? userState;
  String? invState;
  // user
  TextEditingController idUser = TextEditingController();
  TextEditingController emailUser = TextEditingController();
  TextEditingController usernameUser = TextEditingController();
  TextEditingController passwordUser = TextEditingController();
  String photo_user = "null";
  // inv
  TextEditingController idInv = TextEditingController();
  TextEditingController namaInv = TextEditingController();
  // item
  TextEditingController idItem = TextEditingController();
  TextEditingController namaItem = TextEditingController();
  TextEditingController kodeItem = TextEditingController();
  TextEditingController catatanItem = TextEditingController();
  TextEditingController stokItem = TextEditingController();
  TextEditingController hBliItem = TextEditingController();
  TextEditingController hJalItem = TextEditingController();
  String photoItem = "";

  String roleState = "";
  List role = ["user", "admin"];
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selaraskanData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminPanel)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stateButton(Icons.account_circle, "user"),
                _stateButton(Icons.inventory_2_rounded, "inventory"),
                _stateButton(Icons.apps_rounded, "item"),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: loading
                  ? Container(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()))
                  : _tableControlls(context),
            )
          ],
        ),
      ),
      floatingActionButton: _addButton(context),
    );
  }

  Widget _tableControlls(BuildContext context) {
    switch (tableState) {
      case "user":
        return _controllUser(context);
      case "inventory":
        return _controllInv(context);
      case "item":
        return _controllItems(context);
      default:
        return _controllUser(context);
    }
  }

  Widget _controllItems(BuildContext context) {
    // log(jsonEncode(adminAccess.itemList));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: adminAccess.itemList.isNotEmpty
          ? List.generate(adminAccess.itemList.length, (index) {
              Map item = adminAccess.itemList[index];

              Map? user;
              try {
                // jika userlist tidak kosong & item['id_user'] bukan null
                if (adminAccess.userList.isNotEmpty &&
                    item['id_user'] != null) {
                  var tempUser = adminAccess.userList.firstWhere(
                    (element) => element['id_user'] == item['id_user'],
                  );
                  // jika variabel userList mengandung id-nya
                  if (tempUser != -1) {
                    user = tempUser;
                  }
                }
              } catch (e) {
                print("_controllItems: $e");
              }
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: _customListTile(item, user, context),
                    ),
                    Divider(
                      indent: 50,
                      endIndent: 50,
                    )
                  ],
                ),
              );
            })
          : [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Container(
                  height: 100,
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.nothing),
                  ),
                ),
              )
            ],
    );
  }

  Widget _customListTile(Map item, Map? user, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: Color.fromARGB(255, 244, 250, 255)
      ),
      child: Row(
        children: [
          item['photo_barang'] != ""
              ? fungsies().buildFotoBarang(context,item, "${item['id_barang']}admin")
              : Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    idItem.text = item['id_barang'];
                    namaItem.text = item['nama_barang'];
                    kodeItem.text = item['kode_barang'];
                    catatanItem.text = item['catatan'];
                    stokItem.text = item['stok_barang'].toString();
                    hBliItem.text = item['harga_beli'].toString();
                    hJalItem.text = item['harga_jual'].toString();
                    userState = item['id_user'];
                    invState = item['id_inventory'];
                    photoItem = item['photo_barang'];
                  });
                  _viewItem(context, item);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // info nama brg
                        Expanded(
                          child: Text(
                            item['nama_barang'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    // info pemilik brg
                    Text(
                      user == null ? "" : user['email_user'],
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(
                      color: Colors.transparent,
                    ),
                    //info harga jual + stok item
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Text(
                            "${pengaturan.mataUang} ${item['harga_jual']}",
                            style: const TextStyle(color: Colors.deepOrange),
                          ),
                          const VerticalDivider(),
                          Text(
                            "${AppLocalizations.of(context)!.stok}: ${item['stok_barang']}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// jika parameter [item] == null -> `MENAMBAH` file
  ///
  /// jika parameter [item] != null -> `MENGEDIT` file
  _viewItem(BuildContext context, Map? item) {
    log("buka view item");

    if (item == null) {
      log("buka view item: nambah");
      // buat id_barang
      String id_barang =
          "${userWise.userData['id_user']}brg${DateTime.now().millisecondsSinceEpoch}";
      // clear textfieldcontroller untuk membuat item
      setState(() {
        idItem.text = id_barang;
        namaItem.clear();
        kodeItem.clear();
        catatanItem.clear();
        stokItem.clear();
        hBliItem.clear();
        hJalItem.clear();
        photoItem = "";
        invState = null;
        userState = null;
      });
    }

    return showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    photoItem != ""
                        // render foto barang
                        ? Container(
                            constraints:
                                BoxConstraints(maxHeight: 500, maxWidth: 350),
                            // child: ClipOval(
                            child: InkWell(
                              onLongPress: () async {
                                // hapus gambar
                                bool? hapus = await fungsies().konfirmasiDialog(
                                    context,
                                    msg: AppLocalizations.of(context)!
                                        .deleteImgCfrmation);
                                if (hapus == true) {
                                  log("hapus");
                                  setState(() {
                                    photoItem = "";
                                  });
                                }
                              },
                              child: Image.memory(
                                  Uint8List.fromList(base64.decode(photoItem))),
                            ),
                            // ),
                          )
                        // tampilkan tombol tambah foto
                        : Container(
                            height: 100,
                            width: 100,
                            child: ClipOval(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () async {
                                  setState(() {
                                    _addPhotoBarang(context, setState);
                                  });
                                },
                                child: Container(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    Container(
                      height: 10,
                    ),
                    Visibility(
                        visible: photoItem != "",
                        child: Text(
                          AppLocalizations.of(context)!.holdToRemoveImg,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        )),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("id_barang",
                        ctrler: idItem, enable: item == null),
                    // _fieldInfo("id_barang", ctrler: idItem, enable: false),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("nama_barang", ctrler: namaItem),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("kode_barang", ctrler: kodeItem),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("catatan", ctrler: catatanItem),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("stok_barang",
                        ctrler: stokItem, inputType: TextInputType.number),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("harga_beli",
                        ctrler: hBliItem, inputType: TextInputType.number),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("harga_jual",
                        ctrler: hJalItem, inputType: TextInputType.number),
                    Container(
                      height: 20,
                    ),
                    _invUsrDropDown(),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Visibility(
                          visible: item != null,
                          child: _deleteButton(
                              context, "item", item!['id_barang']),
                        ),
                        _updateButton(context, item: item),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget _invUsrDropDown() {
    return StatefulBuilder(builder: (((context, setState) {
      List invByUserState = adminAccess.invList
          .where((element) => element['id_user'] == userState)
          .toList();

      return Column(
        children: [
          DropdownButton(
              isExpanded: true,
              value: userState,
              hint: Text(AppLocalizations.of(context)!.user),
              items: List.generate(adminAccess.userList.length, (index) {
                Map user = adminAccess.userList[index];
                return DropdownMenuItem(
                  value: user['id_user'],
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 155),
                      child: Text(
                        user['email_user'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }),
              onChanged: (value) {
                log("userState berubah");
                setState(() {
                  invState = null;
                  userState = (value) as String;
                  log("$value");
                });
              }),
          Container(
            height: 20,
          ),
          DropdownButton(
              isExpanded: true,
              value: invByUserState.isEmpty ? null : invState,
              hint: Text(AppLocalizations.of(context)!.selectInv),
              items: List.generate(invByUserState.length, (index) {
                Map inv = invByUserState[index];
                return DropdownMenuItem(
                  value: inv['id_inventory'],
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 155),
                      child: Text(
                        inv['nama_inventory'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }),
              onChanged: (value) {
                log("invState berubah");
                setState(() {
                  invState = (value!) as String;
                  log("$value");
                });
              }),
        ],
      );
    })));
  }

  Widget _controllInv(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: adminAccess.invList.isNotEmpty
          ? List.generate(adminAccess.invList.length, (index) {
              Map inv = adminAccess.invList[index];
              Map? user = null;
              if (inv['id_user'] != null) {
                user = adminAccess.userList.firstWhere(
                  (element) => element['id_user'] == inv['id_user'],
                );
              }
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        inv['nama_inventory'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: user != null
                          ? Text(
                              user['email_user'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          idInv.text = inv['id_inventory'];
                          // idUser.text = inv['id_user'];
                          namaInv.text = inv['nama_inventory'];
                          userState = inv['id_user'];
                        });
                        _viewInv(context, inv);
                      },
                    ),
                    Divider(
                      indent: 50,
                      endIndent: 50,
                    )
                  ],
                ),
              );
            })
          : [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Container(
                  height: 100,
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.nothing),
                  ),
                ),
              )
            ],
    );
  }

  Future<dynamic> _viewInv(BuildContext context, Map inv) {
    return showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(children: [
                _fieldInfo("id_inventory", ctrler: idInv, enable: false),
                Container(
                  height: 20,
                ),
                _fieldInfo("nama_inventory", ctrler: namaInv),
                Container(
                  height: 20,
                ),
                _userDropDown(),
                Container(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _deleteButton(context, "inv", inv['id_inventory']),
                    _updateButton(context, inv: inv),
                  ],
                )
              ]),
            ),
          );
        });
  }

  StatefulBuilder _userDropDown() {
    return StatefulBuilder(builder: (((context, setState) {
      return DropdownButton(
          isExpanded: true,
          value: userState,
          hint: Text(AppLocalizations.of(context)!.user),
          items: List.generate(adminAccess.userList.length, (index) {
            Map user = adminAccess.userList[index];
            return DropdownMenuItem(
              value: user['id_user'],
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 155),
                  child: Text(
                    user['email_user'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }),
          onChanged: (value) {
            log("userState berubah");
            setState(() {
              log("$value");
              userState = (value) as String;
            });
          });
    })));
  }

  Widget _controllUser(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: adminAccess.userList.isNotEmpty
          ? List.generate(adminAccess.userList.length, (index) {
              Map user = adminAccess.userList[index];
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        user['email_user'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        "${AppLocalizations.of(context)!.password}: ${user['password_user']}",
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        setState(() {
                          roleState = user['role'];
                          idUser.text = user['id_user'];
                          emailUser.text = user['email_user'];
                          usernameUser.text = user['username_user'];
                          passwordUser.text = user['password_user'];
                        });
                        _viewUser(context, user);
                      },
                    ),
                    Divider(
                      indent: 50,
                      endIndent: 50,
                    )
                  ],
                ),
              );
            })
          : [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Container(
                  height: 100,
                  child: Center(
                    child: Text(AppLocalizations.of(context)!.nothing),
                  ),
                ),
              )
            ],
    );
  }

  Future<dynamic> _viewUser(BuildContext context, Map<dynamic, dynamic> user) {
    if (user['photo_user'] != "null") {
      setState(() {
        photo_user = user['photo_user'];
      });
    }
    return showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("id_user", ctrler: idUser, enable: false),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("email_user", ctrler: emailUser),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("username_user", ctrler: usernameUser),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("password_user", ctrler: passwordUser),
                  Container(
                    height: 20,
                  ),
                  _roleDropDown(roleStater: user['role']),
                  Container(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _deleteButton(context, "user", user['id_user']),
                      _updateButton(context, user: user),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  TextButton _deleteButton(BuildContext context, String tipe, String id) {
    return TextButton(
        onPressed: () async {
          bool? hapus = await fungsies().konfirmasiDialog(context);

          if (hapus == true) {
            setState(() {
              loading = true;
            });
            switch (tipe) {
              case "user":
                Map user = adminAccess.userList
                    .firstWhere((element) => element["id_user"] == id);
                // jika id_user yang mau dihapus beda dengan yang dipake
                if (id != userWise.userData['id_user'] &&
                    user['role'] != "admin") {
                  await userApiWise().delete(id);
                  Navigator.pop(context);
                }
                // jika sama
                else {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  showCupertinoDialog(
                    barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content:
                              Text(id == userWise.userData['id_user'] ? AppLocalizations.of(context)!.thisIsYourAcc : AppLocalizations.of(context)!.thisIsAdmin),
                        );
                      });
                }
                break;
              case "inv":
                await inventoryApiWise().delete(id);
                Navigator.pop(context);
                break;
              case "item":
                await itemApiWise().delete(id);
                await photoBarangApiWise().delete(id);
                Navigator.pop(context);
                break;
              default:
            }
            await selaraskanData();
            setState(() {
              loading = false;
            });
          }
          // Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppLocalizations.of(context)!.delete,
            style: TextStyle(color: Colors.red),
          ),
        ));
  }

  Widget _addButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.blue),
      child: IconButton(
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          switch (tableState) {
            case "user":
              _addUserDialog(context);
              break;
            case "inventory":
              _addInvDialog(context);
              break;
            case "item":
              _addItemDialog(context);
              break;
            default:
              _addUserDialog(context);
          }
          // tampilkan layar tambah berdasarkan tableState
        },
      ),
    );
  }

  Future<dynamic> _addUserDialog(BuildContext context) {
    // buat id_user
    String id_user =
        "${deviceData.id}usr${DateTime.now().millisecondsSinceEpoch}";
    // bersihkan textController dkk untuk nambah user
    setState(() {
      idUser.text = id_user;
      emailUser.clear();
      usernameUser.clear();
      passwordUser.clear();
      photo_user = "null";
    });
    return showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("id_user", ctrler: idUser),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("email_user", ctrler: emailUser),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("username_user", ctrler: usernameUser),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("password_user", ctrler: passwordUser),
                  Container(
                    height: 20,
                  ),
                  _roleDropDown()
                ],
              ),
            ),
            actionsPadding: EdgeInsets.all(20),
            actions: [postButton(context)],
          );
        });
  }

  Future<dynamic> _addInvDialog(BuildContext context) {
    // buat id_inventory
    String id_inventory =
        "${userWise.userData['id_user']}inv${DateTime.now().millisecondsSinceEpoch}";
    // bersihkan textController untuk add inv
    setState(() {
      idInv.text = id_inventory;
      namaInv.clear();
      userState = null;
    });

    return showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _fieldInfo("id_inventory", ctrler: idInv),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo("nama_inventory", ctrler: namaInv),
                  Container(
                    height: 20,
                  ),
                  _userDropDown(),
                ],
              ),
            ),
            actionsPadding: EdgeInsets.all(20),
            actions: [postButton(context)],
          );
        });
  }

  _addItemDialog(BuildContext context) {
    // buat id_barang
    String id_barang =
        "${userWise.userData['id_user']}brg${DateTime.now().millisecondsSinceEpoch}";
    // clear textfieldcontroller untuk membuat item
    setState(() {
      idItem.text = id_barang;
      namaItem.clear();
      kodeItem.clear();
      catatanItem.clear();
      stokItem.clear();
      hBliItem.clear();
      hJalItem.clear();
      photoItem = "";
      invState = null;
      userState = null;
    });

    return showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // photoItem ini adalah base64 hasil enkode byte
                    photoItem != ""
                        // render foto barnag
                        ? Container(
                            height: 100,
                            width: 100,
                            child: ClipOval(
                              child: Image.memory(
                                  Uint8List.fromList(base64.decode(photoItem))),
                            ),
                          )
                        // tampilkan tombol tambah foto
                        : Container(
                            height: 100,
                            width: 100,
                            child: ClipOval(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () async {
                                  setState(() async {
                                    await _addPhotoBarang(context, setState);
                                  });
                                },
                                child: Container(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("id_barang", ctrler: idItem),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("nama_barang", ctrler: namaItem),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("kode_barang", ctrler: kodeItem),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("catatan", ctrler: catatanItem),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("stok_barang",
                        ctrler: stokItem, inputType: TextInputType.number),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("harga_beli",
                        ctrler: hBliItem, inputType: TextInputType.number),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("harga_jual",
                        ctrler: hJalItem, inputType: TextInputType.number),
                    Container(
                      height: 20,
                    ),
                    _invUsrDropDown(),
                  ],
                ),
              ),
              actions: [postButton(context)],
            );
          });
        });
  }

  Future<void> _addPhotoBarang(
      BuildContext context, StateSetter setState) async {
    log("add item photo");
    // ambil gambar dari galeri atau dari kamera
    bool? fromCam = await fungsies().konfirmasiDialog(context,
        msg: AppLocalizations.of(context)!.choosePhotoSource,
        trueText: AppLocalizations.of(context)!.camera,
        falseText: AppLocalizations.of(context)!.gallery,
        trueColor: Colors.blue);
    var imeg = "";
    // ambil foto berdasarkan pilihan
    if (fromCam != null) {
      imeg = await fungsies().pickImage(
          from: fromCam ? PickImageFrom.camera : PickImageFrom.gallery);
    }
    if (imeg != "") {
      // set nilai
      setState(() {
        photoItem = imeg;
      });
    }
  }

  Widget postButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          // laoding
          setState(() {
            loading = true;
          });
          switch (tableState) {
            case "user":
              // cek apakah ada email yang sama, jika ada maka batalkan pembuatan akun
              List cekEmail = adminAccess.userList
                  .where(
                    (element) => element['email_user'] == emailUser.text.trim(),
                  )
                  .toList();

              if (cekEmail.isEmpty) {
                // tambah user
                log("add userapi: $roleState");
                await userApiWise().create(
                    id_user: idUser.text.trim(),
                    username_user: usernameUser.text.trim(),
                    email_user: emailUser.text.trim(),
                    photo_user: photo_user,
                    password_user: passwordUser.text.trim(),
                    role: roleState,
                    isAdmin: true);
              }
              break;
            case "inventory":
              // tambah inv
              await inventoryApiWise()
                  .createOne(idInv.text.trim(), namaInv.text.trim(), userState);
              break;
            // tambah item
            case "item":
              String added = DateTime.now().millisecondsSinceEpoch.toString();
              await itemApiWise().create(
                  id_barang: idItem.text.trim(),
                  id_user: userState,
                  id_inventory: invState,
                  kode_barang: kodeItem.text.trim(),
                  nama_barang: namaItem.text.trim(),
                  catatan: catatanItem.text.trim(),
                  stok_barang:
                      stokItem.text.trim() == "" ? "0" : stokItem.text.trim(),
                  harga_beli:
                      hBliItem.text.trim() == "" ? "0" : hBliItem.text.trim(),
                  harga_jual:
                      hJalItem.text.trim() == "" ? "0" : hJalItem.text.trim(),
                  photo_barang: photoItem,
                  added: added,
                  edited: added);
              break;
            default:
          }
          await selaraskanData();
          // tutup loading
          setState(() {
            loading = false;
          });
          // tutup dialog
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.add));
  }

  TextButton _updateButton(BuildContext context,
      {Map? user, Map? inv, Map? item}) {
    return TextButton(
        onPressed: () async {
          log("update");
          Navigator.pop(context);
          //loading
          setState(() {
            loading = true;
          });

          if (user != null) {
            log("update role->$roleState");
            await userApiWise().update(
              id_user: user['id_user'],
              username_user: usernameUser.text,
              email_user: emailUser.text,
              password_user: passwordUser.text,
              photo_user: user['photo_user'],
              role: roleState,
              isAdmin: true,
            );
          }
          // ini update inv
          else if (inv != null) {
            await inventoryApiWise().update(
                id_inventory: idInv.text,
                id_user: userState,
                nama_inventory: namaInv.text);
          }
          // update item
          else if (item != null) {
            String edited = DateTime.now().millisecondsSinceEpoch.toString();
            await itemApiWise().update(item['id_barang'],
                id_user: userState,
                id_inventory: invState,
                kode_barang: kodeItem.text.trim(),
                nama_barang: namaItem.text.trim(),
                catatan: catatanItem.text.trim(),
                stok_barang: int.parse(
                    stokItem.text.trim().isEmpty ? "0" : stokItem.text.trim()),
                harga_beli: int.parse(
                    hBliItem.text.trim().isEmpty ? "0" : hBliItem.text.trim()),
                harga_jual: int.parse(
                    hJalItem.text.trim().isEmpty ? "0" : hJalItem.text.trim()),
                photo_barang: photoItem == "" ? "" : photoItem,
                edited: edited,
                added: item['added']);

            // update photo barang
            if (photoItem != "") {
              await photoBarangApiWise()
                  .create(item['id_barang'], base64photo: photoItem);
            } else {
              await photoBarangApiWise().delete(item['id_barang']);
            }
          }
          // selaraskan data dengan database
          await selaraskanData();
          //tutup loading
          setState(() {
            // Navigator.pop(context);
            loading = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(AppLocalizations.of(context)!.update),
        ));
  }

  Widget _roleDropDown({String roleStater = "user"}) {
    return StatefulBuilder(builder: ((context, setState) {
      return DropdownButton(
        isExpanded: true,
        onChanged: (value) {
          log("role berubah->$value");
          setState(() {
            roleState = (value) as String;
            roleStater = (value) as String;
          });
        },
        value: roleStater,
        items: List.generate(
            role.length,
            (index) => DropdownMenuItem(
                  value: role[index],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(role[index]),
                  ),
                )),
      );
    }));
  }

  TextFormField _fieldInfo(String field,
      {bool enable = true,
      TextEditingController? ctrler,
      TextInputType? inputType}) {
    return TextFormField(
      enabled: enable,
      controller: ctrler,
      maxLines: null,
      onChanged: (value) {
        if (inputType == TextInputType.number) {
          final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleanedValue != value) {
            ctrler!.text = cleanedValue;
            ctrler.selection = TextSelection.fromPosition(
              TextPosition(offset: cleanedValue.length),
            );
          }
        }
      },
      keyboardType: inputType,
      decoration: InputDecoration(
          labelText: "${field}${enable ? '' : '🔒'}",
          labelStyle: TextStyle(color: enable ? Colors.blue : Colors.red),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2))),
    );
  }

  // ----------------------------------------------------------------------

  Widget _stateButton(IconData icon, String state) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: tableState == state ? Colors.white : Colors.transparent),
      child: AnimatedScale(
        scale: tableState == state ? 1.3 : 1,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: IconButton(
            onPressed: () {
              setState(() {
                switch (state) {
                  case "user":
                    log("set state to user controll");
                    tableState = "user";
                    break;
                  case "inventory":
                    log("set state to inventory controll");
                    tableState = "inventory";
                    break;
                  case "item":
                    log("set state to item controll");
                    tableState = "item";
                    break;
                  default:
                }
              });
            },
            icon: Icon(icon)),
      ),
    );
  }

  // selaraskan data dari database
  Future selaraskanData() async {
    if (await isConnected()) {
      // ambil semua data dari database
      await userApiWise().readAll();
      await inventoryApiWise().readAll();
      await itemApiWise().readAll();
      // simpan list
      await adminAccess().saveList();
      // tutup loading
      setState(() {
        loading = false;
      });
    } else {
      await adminAccess().readList();
      // tutup loading
      setState(() {
        loading = false;
      });
    }
  }

  // cek koneksi internet
  Future<bool> isConnected() async {
    var a = await InternetConnectionCheckerPlus.createInstance(
        addresses: [AddressCheckOptions(Uri.parse(anu.emm))]);
    var internet = await a.connectionStatus;
    if (internet == InternetConnectionStatus.connected) {
      print('Tidak terhubung ke internet');
      return false;
    } else {
      print('Terhubung ke internet');
      return true;
    }
  }
}
