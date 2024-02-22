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
  String? statusKodeState;
  List statusList = ['tersedia', 'selesai'];
  // user
  TextEditingController idUser = TextEditingController();
  TextEditingController emailUser = TextEditingController();
  TextEditingController passwordUser = TextEditingController();
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
  // kode_s
  TextEditingController idKodeS = TextEditingController();
  TextEditingController kodeS = TextEditingController();

  String photoItem = "";
  // filtered List
  /// gunakan hanya di bagian [_controllUser] atau [selaraskanData]
  List filteredUserList = adminAccess.userList;

  /// gunakan hanya di bagian [_controllInv] atau [selaraskanData]
  List filteredInvList = adminAccess.invList;

  /// gunakan hanya di bagian [_controllItems] atau [selaraskanData]
  List filteredItemList = adminAccess.itemList;

  /// gunakan hanya di bagian [_controllKode] atau [selaraskanData]
  List filteredKodeList = adminAccess.kodeList;

  String roleState = "";
  List role = ["user", "admin"];
  bool loading = true;
  bool searchMode = false;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    selaraskanData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchMode
            ? searchTextFormField(context)
            : Text(AppLocalizations.of(context)!.adminPanel),
        actions: [searchButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stateButton(Icons.account_circle, "user"),
                _stateButton(Icons.inventory_2_rounded, "inventory"),
                _stateButton(Icons.apps_rounded, "item"),
                _stateButton(Icons.lock, "kode")
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: loading
                  ? Container(
                      height: 100,
                      child: const Center(child: CircularProgressIndicator()))
                  : _tableControlls(context),
            )
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        curve: Curves.easeIn,
        scale: searchMode ? 0 : 1,
        duration: Duration(milliseconds: 200),
        child: _addButton(context),
      ),
    );
  }

  TextFormField searchTextFormField(BuildContext context) {
    return TextFormField(
      controller: searchController,
      focusNode: searchFocus,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchData,
          border: InputBorder.none),
      onChanged: (value) {
        String searchText = value.toLowerCase().trim();
        setState(() {
          switch (tableState) {
            case "user":
              filteredUserList = adminAccess.userList
                  .where((e) =>
                      (e['email_user'] as String)
                          .toLowerCase()
                          .contains(searchText) ||
                      (e['id_user'] as String)
                          .toLowerCase()
                          .contains(searchText))
                  .toList();
              break;
            case "inventory":
              filteredInvList = adminAccess.invList
                  .where((e) =>
                      (e['id_inventory'] as String)
                          .toLowerCase()
                          .contains(searchText) ||
                      (e['nama_inventory'] as String)
                          .toLowerCase()
                          .contains(searchText))
                  .toList();
              break;
            case "item":
              filteredItemList = adminAccess.itemList
                  .where((e) =>
                      (e['id_barang'] as String)
                          .toLowerCase()
                          .contains(searchText) ||
                      (e['nama_barang'] as String)
                          .toLowerCase()
                          .contains(searchText) ||
                      (e['kode_barang'] as String)
                          .toLowerCase()
                          .contains(searchText))
                  .toList();
              break;
            case "kode":
              filteredKodeList = adminAccess.kodeList
                  .where((e) =>
                      (e['id_kode_s'] as String)
                          .toLowerCase()
                          .contains(searchText) ||
                      (e['kode_s'] as String)
                          .toLowerCase()
                          .contains(searchText) ||
                      (e['email_user'] as String)
                          .toLowerCase()
                          .contains(searchText))
                  .toList();
              break;
            default:
          }
        });
      },
    );
  }

  IconButton searchButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          searchMode = !searchMode;
          if (searchMode == false) {
            searchController.clear();
            filteredUserList = adminAccess.userList;
            filteredInvList = adminAccess.invList;
            filteredItemList = adminAccess.itemList;
          } else {
            FocusScope.of(context).requestFocus(searchFocus);
          }
        });
        log("ubah searchMode->$searchMode");
      },
      icon: Icon(searchMode ? Icons.search_off_rounded : Icons.search),
      splashRadius: 25,
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
      case "kode":
        return _controllKode(context);
      default:
        return _controllUser(context);
    }
  }

  Widget _controllKode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredKodeList.isNotEmpty
          ? List.generate(filteredKodeList.length, (index) {
              Map kode = filteredKodeList[index];

              Map? user;
              try {
                // jika userlist tidak kosong & kode['email_user'] bukan null
                if (adminAccess.userList.isNotEmpty &&
                    kode['email_user'] != null) {
                  var tempUser = adminAccess.userList.firstWhere(
                    (element) => element['email_user'] == kode['email_user'],
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
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        kode['kode_s'],
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
                          log("tap kode_s: ${kode['id_kode_s']}");
                          // ubah idkode controller
                          idKodeS.text = kode['id_kode_s'];

                          // ubah kode_s controller
                          kodeS.text = kode['kode_s'];

                          statusKodeState = kode['status'];

                          // ubah userState
                          Map tempUser = adminAccess.userList.firstWhere(
                              (element) =>
                                  element['email_user'] == kode['email_user']);
                          userState = tempUser['id_user'];
                        });

                        _viewKode(context, kode);
                      },
                    ),
                    const Divider(
                      indent: 50,
                      endIndent: 50,
                    )
                  ],
                ),
              );
            })
          : [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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

  Future<dynamic> _viewKode(BuildContext context, Map<dynamic, dynamic> kode) {
    return showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldInfo("id_kode_s", ctrler: idKodeS, enable: false),
                    Container(
                      height: 20,
                    ),
                    _fieldInfo("kode_s", ctrler: kodeS),
                    Container(
                      height: 5,
                    ),
                    Text(
                      "Maksimal 6 karakter",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    Container(
                      height: 6,
                    ),
                    _userDropDown(context),
                    _statusKodeDropdown(),
                    Container(
                      height: 20,
                    ),
                    Text(
                      "Ditambahkan: ${DateTime.parse(kode['added']).toLocal().toString().replaceAll(".000", "")}",
                      style: const TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _deleteButton(context, "kode", kode['id_kode_s']),
                        _updateButton(context, kode: kode),
                      ],
                    ),
                  ]),
            ),
          );
        });
  }

  StatefulBuilder _statusKodeDropdown() {
    return StatefulBuilder(builder: ((context, setState) {
      return DropdownButton(
          isExpanded: true,
          value: statusKodeState,
          hint: const Text("Pilih status"),
          items: List.generate(
              2,
              (index) => DropdownMenuItem(
                  value: statusList[index],
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 155),
                    child: Text(
                      statusList[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))),
          onChanged: (value) {
            log("status kode diubah -> $value");
            setState(() {
              statusKodeState = value as String;
            });
          });
    }));
  }

  Widget _controllItems(BuildContext context) {
    // log(jsonEncode(adminAccess.itemList));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredItemList.isNotEmpty
          ? List.generate(filteredItemList.length, (index) {
              Map item = filteredItemList[index];

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
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: _customListTile(item, user, context),
                    ),
                    const Divider(
                      indent: 50,
                      endIndent: 50,
                    )
                  ],
                ),
              );
            })
          : [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: Color.fromARGB(255, 244, 250, 255)
      ),
      child: Row(
        children: [
          item['photo_barang'] != ""
              ? fungsies()
                  .buildFotoBarang(context, item, "${item['id_barang']}admin")
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
                            constraints: const BoxConstraints(
                                maxHeight: 500, maxWidth: 350),
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
                                  child: const Icon(
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
                    padding: const EdgeInsets.all(0),
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
                    padding: const EdgeInsets.all(0),
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
      children: filteredInvList.isNotEmpty
          ? List.generate(filteredInvList.length, (index) {
              Map inv = filteredInvList[index];
              Map? user;
              if (inv['id_user'] != null) {
                user = adminAccess.userList.firstWhere(
                  (element) => element['id_user'] == inv['id_user'],
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                    const Divider(
                      indent: 50,
                      endIndent: 50,
                    )
                  ],
                ),
              );
            })
          : [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                _userDropDown(context),
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

  StatefulBuilder _userDropDown(BuildContext context) {
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
                padding: const EdgeInsets.all(0),
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
      children: filteredUserList.isNotEmpty
          ? List.generate(filteredUserList.length, (index) {
              Map user = filteredUserList[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                          // usernameUser.text = user['username_user'] ?? "";
                          passwordUser.text = user['password_user'];
                        });
                        _viewUser(context, user);
                      },
                    ),
                    const Divider(
                      indent: 50,
                      endIndent: 50,
                    )
                  ],
                ),
              );
            })
          : [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                  // _fieldInfo("username_user", ctrler: usernameUser),
                  // Container(
                  //   height: 20,
                  // ),
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
                          content: Text(id == userWise.userData['id_user']
                              ? AppLocalizations.of(context)!.thisIsYourAcc
                              : AppLocalizations.of(context)!.thisIsAdmin),
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
              case "kode":
                await kodeApiWise().delete(id);
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
            style: const TextStyle(color: Colors.red),
          ),
        ));
  }

  Widget _addButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.blue),
      child: IconButton(
        icon: const Icon(
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
            case "kode":
              _addKodeS(context);
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
      // usernameUser.clear();
      passwordUser.clear();
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
                  // _fieldInfo("username_user", ctrler: usernameUser),
                  // Container(
                  //   height: 20,
                  // ),
                  _fieldInfo("password_user", ctrler: passwordUser),
                  Container(
                    height: 20,
                  ),
                  _roleDropDown()
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.all(20),
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
                  _userDropDown(context),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.all(20),
            actions: [postButton(context)],
          );
        });
  }

  Future<dynamic> _addKodeS(BuildContext context) {
    // bersihkan textController untuk add inv
    setState(() {
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
                  Text(
                      "Kode sementara akan dibuat secara otomatis dan akan mengirim email kepada user yang dipilih, silahkan pilih user"),
                  Container(
                    height: 20,
                  ),
                  _userDropDown(context),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.all(20),
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
                                  child: const Icon(
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
          if (userState != null) {
            // laoding
            setState(() {
              loading = true;
            });
            switch (tableState) {
              case "user":
                // cek apakah ada email yang sama, jika ada maka batalkan pembuatan akun
                List cekEmail = adminAccess.userList
                    .where(
                      (element) =>
                          element['email_user'] == emailUser.text.trim(),
                    )
                    .toList();

                if (cekEmail.isEmpty) {
                  // tambah user
                  log("add userapi: $roleState");
                  await userApiWise().create(
                      id_user: idUser.text.trim(),
                      // username_user: usernameUser.text.trim(),
                      email_user: emailUser.text.trim(),
                      password_user: passwordUser.text.trim(),
                      role: roleState,
                      isAdmin: true);
                }
                break;
              case "inventory":
                // tambah inv
                await inventoryApiWise().createOne(
                    idInv.text.trim(), namaInv.text.trim(), userState);
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
              case "kode":
                // cari user berdasarkan id_user
                if (userState != null) {
                  Map user = adminAccess.userList
                      .firstWhere((e) => e['id_user'] == userState);
                  await kodeApiWise().create(user['email_user']);
                }
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
          }
        },
        child: Text(AppLocalizations.of(context)!.add));
  }

  TextButton _updateButton(BuildContext context,
      {Map? user, Map? inv, Map? item, Map? kode}) {
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
              // username_user: usernameUser.text,
              email_user: emailUser.text,
              password_user: passwordUser.text,
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
          // update kode
          else if (kode != null) {
            log("update kode");
            // dapetin user berdasarkan id user
            Map user = adminAccess.userList.firstWhere(
              (element) => element['id_user'] == userState,
            );

            await kodeApiWise().update(kode['id_kode_s'], user['email_user'],
                kodeS.text.trim(), statusKodeState ?? "null");
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
        onChanged: roleStater == "admin"
            ? null
            : (value) {
                log("role berubah->$value");
                setState(() {
                  roleState = (value) as String;
                  roleStater = (value) as String;
                });
              },
        value: roleStater,
        disabledHint: Text("Akun ini milik admin"),
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
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue)),
          disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2))),
    );
  }

  // ----------------------------------------------------------------------

  Widget _stateButton(IconData icon, String state) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: tableState == state ? Colors.white : Colors.transparent),
      child: AnimatedScale(
        scale: tableState == state ? 1.3 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: IconButton(
            onPressed: () {
              setState(() {
                // reset pencarian
                searchMode = false;
                searchController.clear();
                filteredUserList = adminAccess.userList;
                filteredInvList = adminAccess.invList;
                filteredItemList = adminAccess.itemList;

                // ubah state sesuai yg diklik
                tableState = state;
                log("set tableState -> $tableState");
                // switch (state) {
                //   case "user":
                //     log("set state to user controll");
                //     tableState = "user";
                //     break;
                //   case "inventory":
                //     log("set state to inventory controll");
                //     tableState = "inventory";
                //     break;
                //   case "item":
                //     log("set state to item controll");
                //     tableState = "item";
                //     break;
                //   case "kode":
                //     tableState = ""
                //     break;
                //   default:
                // }
              });
            },
            icon: Icon(icon)),
      ),
    );
  }

  // selaraskan data dari database
  Future selaraskanData() async {
    bool terkonek = await fungsies().isConnected();
    if (terkonek) {
      // buat auth
      await authapi().auth(
          userWise.userData['email_user'], userWise.userData['password_user']);
      // ambil semua data dari database
      await userApiWise().readAll();
      await inventoryApiWise().readAll();
      await itemApiWise().readAll();
      await kodeApiWise().readAll();

      // refresh filtered list
      String searchText = searchController.text.toLowerCase().trim();
      filteredUserList = adminAccess.userList
          .where((e) =>
              (e['email_user'] as String).toLowerCase().contains(searchText) ||
              (e['id_user'] as String).toLowerCase().contains(searchText))
          .toList();
      filteredInvList = adminAccess.invList
          .where((e) =>
              (e['id_inventory'] as String)
                  .toLowerCase()
                  .contains(searchText) ||
              (e['nama_inventory'] as String)
                  .toLowerCase()
                  .contains(searchText))
          .toList();
      filteredItemList = adminAccess.itemList
          .where((e) =>
              (e['id_barang'] as String).toLowerCase().contains(searchText) ||
              (e['nama_barang'] as String).toLowerCase().contains(searchText) ||
              (e['kode_barang'] as String).toLowerCase().contains(searchText))
          .toList();
      filteredKodeList = adminAccess.kodeList
          .where((e) =>
              (e['id_kode_s'] as String).toLowerCase().contains(searchText) ||
              (e['kode_s'] as String).toLowerCase().contains(searchText) ||
              (e['email_user'] as String).toLowerCase().contains(searchText))
          .toList();

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
}
