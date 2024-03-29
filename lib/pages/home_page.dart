// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart';
import 'package:itemwise/allpackages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = "Item Wise", this.id_inv});

  final String title;
  final String? id_inv;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<String> selectedItems = [];
  List filteredItems = [];
  String hjalNew = "";
  String stokNew = "";
  String idBrgOld = "";
  String id_user =
      userWise.isLoggedIn ? userWise.userData["id_user"] : deviceData.id;
  TextEditingController NamaInvController = TextEditingController();
  TextEditingController hargaJualController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  ScrollController invScrollController =
      ScrollController(keepScrollOffset: false);
  CurrencyFormatterSettings mataUangSetting =
      CurrencyFormatterSettings(symbol: "Rp", thousandSeparator: ".");
  bool invEditMode = false;
  bool searchMode = false;
  bool filenameValid = true;
  GlobalKey namaInvKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String invState = widget.id_inv ?? "all";
  late AnimationController bottomSheetAC;

  // buat variabel timer
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    log('in homePage');
    checkDeviceId();
    authapi().auth(
        userWise.userData['email_user'], userWise.userData['password_user']);
    bottomSheetAC = BottomSheet.createAnimationController(this);
    filteredItems = ItemWise().readByInventory(invState, id_user);

    // ini adalah pengulangan tiap sekian detik
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _selaraskanAkun();
    });
  }

  // dispose akan dipanggil jika menutup halaman ini
  // tidak berpengaruh oleh push, kecuali pushAndRemove atau navigator yang tidak menutup halaman ini
  // (maksudnya kalo kena pop bakal dipanggil)
  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  _selaraskanAkun() async {
    print("selaraskan akun: ${DateTime.now()}");

    // cek koneksi ke server
    bool isConnected = await fungsies().isConnected();

    if (userWise.isLoggedIn) {
      // jika bisa menyambung ke server
      if (isConnected) {
        // dapatkan data akun berdasarkan email + password
        final Response responLogin = await userApiWise().readByEmail(
            userWise.userData['email_user'],
            userWise.userData['password_user']);

        // convert response menjadi json
        final Map decodedResponLogin = jsonDecode(responLogin.body);

        // response:  
        // {
        //  "msg":"success",
        //  "result":{
        //            "id_user":"FFAA4576076C48EF912ADE0AC4E8EF1816996772984971701343042764",
        //            "email_user":"amdramadhani221005@gmail.com",
        //            "role":"user",
        //            "password_user":"ramatokdeh"
        //            }
        // }

        // ambil elemen 'result' karena isinya adalah data akun yg dibuat login
        final Map userData = decodedResponLogin['result'];

        // cek jika role sebelumnya adalah user DAN respon dari API rolenya admin
        // artinya role dari dataLogin di device berbeda dengan yg diterima dari API
        if (userWise.userData['role'] == "user" &&
            userData['role'] == "admin") {

          // tampilkan dialog
          showCupertinoDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text("Anda sekarang adalah admin"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.ok))
                    ],
                  ));
        }
        // jika sebelumnya admin dan respon dari API rolenya user
        else if (userWise.userData['role'] == "admin" &&
            userData['role'] == "user") {
          showCupertinoDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: Text("Anda sekarang adalah pengguna"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.ok))
                    ],
                  ));
        }

        // setelah mendapatkan response dari API maka ubah dataLogin
        // userData ini respon yg diconvert jadi json
        userWise().edit(
            id_user: userData['id_user'],
            email_user: userData['email_user'],
            password_user: userData['password_user'],
            role: userData['role']);

        // (OPSIONAL) lakukan autorisasi lagi menggunakan email+password
        await authapi().auth(userData['email_user'], userData['password_user']);

        // 'mounted' mencegah eror `Unhandled Exception: setState() called after dispose()`
        // ini yg aku maksud "setState tabrakan dengan pop"
        if (mounted) {
          setState(() {
            log("selesai _selaraskanAkun");
          });
        }

      } else {
        print("tidak bisa menyambung ke server");
      }
    }
  }

  
  _selaraskanDataBarang() async {
    print("selaraskan data barang: ${DateTime.now()}");

    // cek koneksi ke server
    bool isConnected = await fungsies().isConnected();

    // jika terkoneksi
    if(isConnected){

    }
  }

  void checkDeviceId() async {
    var isIdSaved = await deviceData().isKeyAvailable("deviceId");
    // A.K.A pertama kali buka,
    // deviceId ini digunakan untuk pengganti idUser di atribut inv dan brg,
    // ketika login nanti muncul dialog: (judul: "Pindahkan aset saat ini ke akun Anda?", msg: "Jika iya maka aset hanya bisa diakses ketika menggunakan akun ini, jika tidak maka aset hanya bisa diakses ketika tidak terhubung dengan akun apapun, harap pikirkan dengan bijak")
    if (isIdSaved == false) {
      var a = await DeviceInfoPlugin().deviceInfo;
      var b = a.data;
      var c = '${b["deviceId"] ?? b["id"]}';
      await deviceData().edit(c);
      if (userWise.isLoggedIn == false) {
        id_user = c;
      }
    } else {
      log("device id: ${deviceData.id}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _homeDrawer(context),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      onDrawerChanged: (isOpened) {
        if (isOpened == false) {
          setState(() {
            invEditMode = false;
          });
        }
        resetPencarian();
      },
      drawerEnableOpenDragGesture: selectedItems.isEmpty,
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: invState != "all" ? 55 : null,
        leading: selectedItems.isEmpty
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              )
            : Center(
                child: Text("${selectedItems.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 24)),
              ),
        title: selectedItems.isEmpty
            ? Stack(
                alignment: Alignment.center,
                children: [
                  defaultAppBar(context),
                  AnimatedScale(
                    alignment: Alignment.centerRight,
                    scale: searchMode ? 1 : 0,
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 244, 250, 255)),
                      child: TextFormField(
                        controller: searchController,
                        enabled: searchMode,
                        autofocus: searchMode,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchItem),
                        onChanged: (value) => cariBarang(value),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
        centerTitle: selectedItems.isEmpty,
        titleSpacing: 0,
        backgroundColor: selectedItems.isNotEmpty ? Colors.blue : null,
        actions: selectedItems.isEmpty
            ? searchMode
                ? [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            searchMode = false;
                            filteredItems =
                                ItemWise().readByInventory(invState, id_user);
                          });
                        },
                        icon: Icon(Icons.close))
                  ]
                : actionsIfSelectedItemsEmpty(context)
            : actionsIfSelectedItemsNotEmpty(context),
      ),
      body: filteredItems.isNotEmpty
          // body: ItemWise().readByInventory(invState, id_user).isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: listItems(context))
          : Center(
              child: Text(
                AppLocalizations.of(context)!.thisRoomEmpty,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 156, 210, 255)),
                textAlign: TextAlign.center,
              ),
            ),
      floatingActionButton: addButton(context),
    );
  }

  List<Widget> actionsIfSelectedItemsNotEmpty(BuildContext context) {
    return [
      // tombol hapus
      IconButton(
          splashRadius: 20,
          onPressed: () async {
            log("delete $selectedItems", name: "delete button");
            bool? hapus = await fungsies().konfirmasiDialog(context,
                msg:
                    "${AppLocalizations.of(context)!.delete} ${selectedItems.length} ${AppLocalizations.of(context)!.items}?");
            if (hapus == true) {
              for (String a in selectedItems) {
                await ItemWise().delete(a);
              }
              setState(() {
                selectedItems.clear();
                // jika dalam mode pencarian
                if (searchMode) {
                  cariBarang(searchController.text.trim());
                }
                // jika tidak dlm mode pencarian
                else {
                  filteredItems = ItemWise().readByInventory(invState, id_user);
                }
              });
            }
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.white,
          )),
      // tombol pindah inventory
      IconButton(
          onPressed: () async {
            log("tombol pindah inventaris");
            String? id_inventory = await _dialogPindahInventaris(context);
            // if (id_inventory != null) {
            for (var e in selectedItems) {
              await ItemWise().update(e, id_inventory: id_inventory);
            }
            setState(() {
              selectedItems.clear();
              // jika dalam mode pencarian
              if (searchMode) {
                cariBarang(searchController.text.trim());
              }
              // jika tidak dlm mode pencarian
              else {
                filteredItems = ItemWise().readByInventory(invState, id_user);
              }
            });
            // }
          },
          splashRadius: 20,
          icon: const Icon(Icons.inventory_2, color: Colors.white)),
      // tombol bersihkan pilihan
      IconButton(
          onPressed: () {
            log("cancel");
            setState(() {
              selectedItems.clear();
            });
          },
          splashRadius: 20,
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white,
          ))
    ];
  }

  Future<dynamic> _dialogPindahInventaris(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          // variabel untuk inventaris yang dipilih
          String sel = "";
          if (selectedItems.isNotEmpty) {
            sel = ItemWise().readByIdBarang(selectedItems[0])['id_inventory'] ??
                "";
          }
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.moveToInv),
            contentPadding: const EdgeInsets.all(10),
            content: StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(inventoryWise().readByUser().length,
                      (index) {
                    Map inv = inventoryWise().readByUser()[index];
                    return RadioListTile(
                        contentPadding: const EdgeInsets.all(0),
                        value: inv['id_inventory'],
                        title: Text(inv['nama_inventory']),
                        groupValue: sel,
                        onChanged: (value) {
                          log("ubah value->$value");
                          setState(() {
                            sel = value;
                          });
                        });
                  }),
                ),
              );
            }),
            actions: [
              TextButton(
                  onPressed: () {
                    log("batal pindah inv");
                    Navigator.of(context).pop(null);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel)),
              TextButton(
                  onPressed: () async {
                    log("pindahkan barang ke $sel");
                    // tutup dialog
                    Navigator.of(context).pop(sel);
                  },
                  child: Text(AppLocalizations.of(context)!.save)),
            ],
          );
        });
  }

  List<Widget> actionsIfSelectedItemsEmpty(BuildContext context) {
    return [
      PopupMenuButton(
          onOpened: () => resetPencarian(),
          onSelected: (value) async {
            switch (value) {
              case "profil":
                log("profil");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const userPage()));
                break;
              case "ekspor":
                await backupAsset();
                break;
              case "impor":
                await loadAsset();
                // refresh filter
                setState(() {
                  filteredItems = ItemWise().readByInventory(invState, id_user);
                });
                break;
              case "adminPanel":
                log("goto adminPanel");
                // loading
                showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    });

                // tes koneksi internet
                bool terkonekkah = await fungsies().isConnected();

                if (terkonekkah) {
                  // tutup loading
                  Navigator.pop(context);

                  // menuju admin panel
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminPanel()));
                } else {
                  // tutup loading
                  Navigator.pop(context);
                  log("ga ada koneksi ke server");

                  // tampilkan info ga ada internet
                  showCupertinoDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            content:
                                Text(AppLocalizations.of(context)!.noInternet),
                          ));
                }
                break;
              case "sort":
                log("sort");
                sortingDialog(context);
                break;
              case "cari":
                log("ngubah searchMode");
                // jika searchMode == true maka akan mereset filteredItems
                if (searchMode) {
                  log("↳ false");
                  resetPencarian();
                } else {
                  log("↳ true");
                  setState(() {
                    searchMode = true;
                  });
                }
                break;
              case "saveExcel":
                // cek izin penyimpanan
                await fungsies().cekAksesMemori();
                await _dialogSimpanExcel(context);
                // await pickDirectory(context);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                  value: "profil",
                  child: _menuItem(
                      context,
                      userWise.isLoggedIn
                          ? Icons.account_box_rounded
                          : Icons.login_rounded,
                      userWise.isLoggedIn
                          ? AppLocalizations.of(context)!.profile
                          : AppLocalizations.of(context)!.login)),
              if (filteredItems.isNotEmpty)
                PopupMenuItem(
                  value: "cari",
                  child: _menuItem(context, Icons.search,
                      AppLocalizations.of(context)!.searchItem),
                ),
              if (filteredItems.isNotEmpty)
                PopupMenuItem(
                  value: "sort",
                  child: _menuItem(
                      context, Icons.sort, AppLocalizations.of(context)!.sort),
                ),
              if (filteredItems.isNotEmpty)
                PopupMenuItem(
                    value: "saveExcel",
                    child: _menuItem(context, Icons.calendar_view_month_rounded,
                        AppLocalizations.of(context)!.saveAsExcel)),
              if (userWise.isLoggedIn)
                PopupMenuItem(
                    value: "ekspor",
                    child: _menuItem(context, Icons.backup_rounded,
                        AppLocalizations.of(context)!.bakcup)),
              if (userWise.isLoggedIn)
                PopupMenuItem(
                    value: "impor",
                    child: _menuItem(context, Icons.download_rounded,
                        AppLocalizations.of(context)!.loadData)),
              // akses khusus admean
              if (userWise.userData['role'] == "admin" && userWise.isLoggedIn)
                PopupMenuItem(
                  value: "adminPanel",
                  child: _menuItem(context, Icons.admin_panel_settings_rounded,
                      AppLocalizations.of(context)!.adminPanel),
                ),
            ];
          }),
    ];
  }

  Future<dynamic> sortingDialog(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            content: StatefulBuilder(builder: ((context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                      value: sorter.name12,
                      groupValue: pengaturan.sortBy,
                      title: Text(AppLocalizations.of(context)!.nameAZ),
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),
                  RadioListTile(
                      value: sorter.name21,
                      title: Text(AppLocalizations.of(context)!.nameZA),
                      groupValue: pengaturan.sortBy,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),
                  RadioListTile(
                      value: sorter.added12,
                      title: Text(AppLocalizations.of(context)!.newestAdded),
                      groupValue: pengaturan.sortBy,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),
                  RadioListTile(
                      value: sorter.added21,
                      title: Text(AppLocalizations.of(context)!.oldestAdded),
                      groupValue: pengaturan.sortBy,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),

                  // TODO: tambah urutkan berdasarkan stok dan harga
                  RadioListTile(
                      value: sorter.stock12,
                      title: Text("Stok  paling sedikit"),
                      groupValue: pengaturan.sortBy,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),
                  RadioListTile(
                      value: sorter.stock21,
                      title: Text("Stok terbanyak"),
                      groupValue: pengaturan.sortBy,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),
                  RadioListTile(
                      value: sorter.hjual12,
                      title: Text("Harga Jual terkecil"),
                      groupValue: pengaturan.sortBy,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),
                  RadioListTile(
                      value: sorter.hjual21,
                      title: Text("Harga Jual terbesar"),
                      groupValue: pengaturan.sortBy,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            pengaturan().ubahSorting(value);
                          }
                        });
                      }),
                ],
              );
            })),
            actions: [
              TextButton(
                  onPressed: () {
                    log("ok");
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.ok))
            ],
          );
        });
  }

  Column defaultAppBar(BuildContext context) {
    return Column(
      children: [
        Text(widget.title),
        if (invState != "all")
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 150),
            child: Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(right: 3),
                      child: Icon(
                        Icons.inventory,
                        color: Colors.green,
                        size: 17,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: inventoryWise().readByUser().firstWhere((element) =>
                        element["id_inventory"] == invState)["nama_inventory"],
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              overflow: TextOverflow.fade,
            ),
          )
      ],
    );
  }

  Row _menuItem(BuildContext context, IconData icon, String menuTitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Container(
          width: 10,
        ),
        Text(menuTitle)
      ],
    );
  }

  //-----------------------------------------------------------------------------//

  /// reset pencarian
  resetPencarian() {
    setState(() {
      searchMode = false;
      searchController.clear();
      // refresh filteredItems karena yang ditampilkan adalah filteredItems
      filteredItems = ItemWise().readByInventory(invState, id_user);
    });
  }

  /// pertama akan dihapus data berdasarkan id_user di database
  /// kedua akan ditambahkan data dari device ke database
  Future backupAsset() async {
    log("ekspor aset");

    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    var terkonek = await fungsies().isConnected();
    List itm = ItemWise().readByUser();

    if (inventoryWise().readByUser().isNotEmpty ||
        ItemWise().readByUser().isNotEmpty) {
      if (terkonek && userWise.isLoggedIn) {
        // auth dulu
        await authapi().auth(userWise.userData['email_user'],
            userWise.userData['password_user']);

        // hapus barang & inventory berdasarkan user di DB
        await itemApiWise().deleteByUser(userWise.userData['id_user']);
        await inventoryApiWise().deleteByuser(userWise.userData['id_user']);

        // bakcup inventory
        await inventoryApiWise().create();

        // backup barang, tiap barang akan diupload satu persatu
        // ini juga upload foto barang jika ada
        for (var e in itm) {
          await itemApiWise().create(
            id_barang: e['id_barang'],
            id_inventory: e['id_inventory'],
            id_user: e['id_user'],
            kode_barang: e['kode_barang'],
            nama_barang: e['nama_barang'],
            catatan: e['catatan'],
            stok_barang: e['stok_barang'].toString(),
            harga_beli: e['harga_beli'].toString(),
            harga_jual: e['harga_jual'].toString(),
            photo_barang: e['photo_barang'],
            added: e['added'],
            edited: e['edited'],
          );

          // bakckup foto barang
          // jika foto barang ada maka backup, jika tidak maka hapus foto di server
          if (e['photo_barang'] != "") {
            await photoBarangApiWise()
                .create(e['id_barang'], base64photo: e['photo_barang']);
          } else {
            print(
                "foto barang tidak ditemukan: ${e['id_barang']}, maka lakukan delete");
            await photoBarangApiWise().delete(e['id_barang']);
          }
        }

        // tutup loading
        setState(() {
          Navigator.pop(context);
        });
      } else {
        // tutup loading
        setState(() {
          Navigator.pop(context);
        });
        showCupertinoDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  content: Text(AppLocalizations.of(context)!.noInternet),
                ));
      }
    }

    log("bakcup func done");
  }

  loadAsset() async {
    log("load aset");

    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    await authapi().auth(
        userWise.userData['email_user'], userWise.userData['password_user']);

    var terkonek = await fungsies().isConnected();

    if (terkonek && userWise.isLoggedIn) {
      // load inventory
      await inventoryApiWise().read();

      // load barang
      // await ItemWise().clear();
      // load barang ini sekaligus mendapatkan foto barangnya
      await itemApiWise().read();

      // load foto barang untuk setiap item milik user
      // for (var e in ItemWise().readByUser()) {
      //   String? base64img = await photoBarangApiWise().get(e['id_barang']);
      //   if (base64img != null) {
      //     ItemWise().update(e['id_barang'], photo_barang: base64img);
      //   }
      // }

      // tutup loading
      Navigator.pop(context);
      // log(ItemWise().readByUser().toList().toString());
    }

    log("load func done");
  }

  SafeArea _homeDrawer(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.inventory,
                        style: const TextStyle(
                            fontSize: 25,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const Divider(),
                  // menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // tambah inventaris
                      IconButton(
                          onPressed: () async {
                            log("nambah");
                            var id_inventory =
                                "${id_user}inv${DateTime.now().millisecondsSinceEpoch.toString()}";
                            setState(() {
                              invEditMode = false;
                              NamaInvController.clear();
                            });
                            invNameDialog(context, id_inventory, "add");
                          },
                          tooltip: AppLocalizations.of(context)!.addInventory,
                          icon: const Icon(Icons.add_box)),
                      // edit
                      IconButton(
                        onPressed: () {
                          if (inventoryWise().readByUser().isNotEmpty) {
                            log("ngedit");
                            setState(() {
                              invEditMode = !invEditMode;
                            });
                          }
                        },
                        icon: Icon(
                          invEditMode ? Icons.edit : Icons.edit_off_rounded,
                          color: invEditMode ? Colors.green : Colors.grey[400],
                        ),
                      ),
                      // tombol semua barang
                      Stack(alignment: Alignment.center, children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              invState = "all";
                              filteredItems =
                                  ItemWise().readByInventory("all", id_user);
                            });
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.all_inbox_rounded,
                            color: Colors.green,
                          ),
                        ),
                        if (invState == "all")
                          const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 25,
                          ),
                        if (invState == "all")
                          const Icon(
                            Icons.person,
                            size: 20,
                          ),
                      ])
                    ],
                  ),
                  if (invEditMode)
                    Text(AppLocalizations.of(context)!.tapToEditInv,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[300])),
                  const Divider()
                ],
              ),
              if (inventoryWise().readByUser().isNotEmpty)
                Expanded(
                  // list inventory
                  child: ListView(
                    controller: invScrollController,
                    children: List.generate(inventoryWise().readByUser().length,
                        (index) {
                      return _inventoryTile(index, context);
                    }),
                  ),
                ),
              if (inventoryWise().readByUser().isNotEmpty)
                if (invEditMode == false)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      AppLocalizations.of(context)!.holdToRemoveInv,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.blue[200]),
                      textAlign: TextAlign.center,
                    ),
                  ),
              if (inventoryWise().readByUser().isEmpty)
                Text(
                  AppLocalizations.of(context)!.tapButtonToAddInventory,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.blue[200]),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stokDanHargaSheet(BuildContext context, String id_barang) {
    Map barang = filteredItems.firstWhere(
      // Map barang = ItemWise().readByUser().firstWhere(
      (element) => element['id_barang'] == id_barang,
    );

    // // ini pencegahan value kena reset ketika render ulang (biasanya terjadi ketika menutup/memunculkan keyboard)
    // // jika id_barang beda berarti ini build id_barang baru
    // if (id_barang != idBrgOld) {
    //   hargaJualController.text = barang['harga_jual'].toString();
    //   stokController.text = barang['stok_barang'].toString();
    // }
    // // ini kalo sama
    // else {
    //   if (hjalNew == "") {
    //     hargaJualController.text = barang['harga_jual'].toString();
    //   }
    //   if (stokNew == "") {
    //     stokController.text = barang['stok_barang'].toString();
    //   }
    // }
    // idBrgOld = id_barang;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)!.editStockAndPrice,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 20,
                    ),
                    Text(
                      barang['nama_barang'],
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      height: 5,
                    ),
                    Text(
                      barang['kode_barang'],
                      style: const TextStyle(fontSize: 15),
                    ),
                    Container(
                      height: 20,
                    ),
                    Text(AppLocalizations.of(context)!.selPrice,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                    TextFormField(
                      controller: hargaJualController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyTextInputFormatter(
                            locale: "id", symbol: "", decimalDigits: 0)
                      ],
                      decoration:
                          InputDecoration(icon: Text(pengaturan.mataUang)),
                      onChanged: (value) {
                        if (value == "") {
                          setState(() {
                            hargaJualController.text = "0";
                          });
                        } else {
                          setState(() {
                            hjalNew = value;
                          });
                        }
                      },
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.stok,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    log("minus");
                                    int stok = int.parse(stokController.text);
                                    if (stok > 0) {
                                      setState(() {
                                        stokController.text =
                                            (stok - 1).toString();
                                      });
                                    }
                                    setState(() {
                                      stokNew = stok.toString();
                                    });
                                  },
                                  child: circledIcon(Icons.remove_rounded)),
                              Expanded(
                                child: TextFormField(
                                  controller: stokController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (value) {
                                    if (value == "") {
                                      setState(() {
                                        stokController.text = "0";
                                      });
                                    }
                                  },
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    log("add");
                                    int stok = int.parse(stokController.text);
                                    setState(() {
                                      stokController.text =
                                          (stok + 1).toString();
                                      stokNew = stok.toString();
                                    });
                                  },
                                  child: circledIcon(Icons.add_rounded))
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 40,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              log("simpan lewat bottomsheet");
                              await ItemWise().update(id_barang,
                                  stok_barang:
                                      int.parse(stokController.text.trim()),
                                  harga_jual: int.parse(hargaJualController.text
                                      .trim()
                                      .replaceAll(".", "")),
                                  id_inventory: barang['id_inventory']);
                              setState(() {
                                // jika dalam mode pencarian
                                if (searchMode) {
                                  cariBarang(searchController.text.trim());
                                }
                                // jika tidak dlm mode pencarian
                                else {
                                  filteredItems = ItemWise()
                                      .readByInventory(invState, id_user);
                                }
                                // refresh filteredItems karena yang ditampilkan adalah filteredItems
                                // filteredItems = ItemWise()
                                //     .readByInventory(invState, id_user);
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                    AppLocalizations.of(context)!.successSave),
                                duration: const Duration(seconds: 1),
                              ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromARGB(70, 0, 0, 0),
                                        blurRadius: 2)
                                  ]),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                AppLocalizations.of(context)!.save,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // mendorong bottomsheet ke atas ketika buka keyboard
                    AnimatedContainer(
                        height: MediaQuery.of(context).viewInsets.bottom,
                        duration: const Duration(milliseconds: 200))
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).viewPadding.bottom,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget moreMenu(BuildContext context, String id_barang) {
    // dapatkan map berdasarkan id_barang
    Map barang = ItemWise().readByIdBarang(id_barang);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                Container(
                  height: 20,
                ),
                // info barang yang diklik
                // nama barang
                Text(
                  barang['nama_barang'],
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Container(
                  height: 5,
                ),
                // kode barang
                Text(
                  barang['kode_barang'],
                  style: const TextStyle(fontSize: 15),
                ),
                Container(
                  height: 20,
                ),
                Text(
                  "${AppLocalizations.of(context)!.action}:",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Container(
                  height: 10,
                ),
                // menu edit detail
                InkWell(
                  onTap: () async {
                    log("edit detail");
                    // tutup menu
                    Navigator.pop(context);
                    // menuju halaman view/edit
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewItemPage(
                                  itemMap: barang,
                                )));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!.editItemDetail),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                // menu pilih
                InkWell(
                  onTap: () {
                    log("pilih");
                    setState(() {
                      selectedItems.add(id_barang);
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: IntrinsicWidth(
                          stepHeight: null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.selectItem),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                // menu hapus
                InkWell(
                  onTap: () async {
                    log("hapus");
                    bool? hapus = await fungsies().konfirmasiDialog(context);
                    if (hapus == true) {
                      await ItemWise().delete(id_barang);
                      setState(() {
                        // refresh filteredItems karena yang ditampilkan adalah filteredItems
                        filteredItems =
                            ItemWise().readByInventory(invState, id_user);
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.delete),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void clearNotNumber(String value, TextEditingController controller) {
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedValue != value) {
      controller.text = cleanedValue;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: cleanedValue.length),
      );
    }
  }

  Container circledIcon(IconData ikon) {
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(55, 0, 0, 0),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 5))
            ]),
        child: Icon(
          ikon,
          color: Colors.white,
        ));
  }

  Future<dynamic> invNameDialog(
      BuildContext context, String id_inventory, String mode) {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return AlertDialog(
            key: namaInvKey,
            title: mode == "add"
                ? Text(AppLocalizations.of(context)!.addInventory)
                : Text(AppLocalizations.of(context)!.changeName),
            content: SingleChildScrollView(
              child: TextFormField(
                controller: NamaInvController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterName),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  log("simpan");
                  if (NamaInvController.text.trim().isNotEmpty) {
                    setState(() {
                      // cek apakah sudah login
                      if (userWise.isLoggedIn) {
                        log("sudah login");
                        id_user = userWise.userData["id_user"];
                      }
                      // belum login
                      else {
                        log("belum login");
                        id_user = deviceData.id;
                      }

                      switch (mode) {
                        case "add":
                          inventoryWise().create(id_inventory, id_user,
                              NamaInvController.text.trim());
                          log("create: $id_inventory - $id_user - ${NamaInvController.text.trim()}");
                          break;
                        case "edit":
                          log("tekan simpan edit");
                          inventoryWise().update(id_inventory, id_user,
                              NamaInvController.text.trim());
                          invEditMode = false;
                          break;
                        default:
                      }
                    });

                    NamaInvController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text(AppLocalizations.of(context)!.save),
              )
            ],
          );
        });
  }

  Row _inventoryTile(int index, BuildContext context) {
    String id_inventory = inventoryWise().readByUser()[index]["id_inventory"];
    int jml_brg = ItemWise().readByInventory(id_inventory, id_user).length;
    return Row(
      children: [
        Expanded(
            child: ListTile(
          // pindah inventaris
          onTap: () {
            log("tap ${id_inventory}");
            log("jml brg: $jml_brg");
            switch (invEditMode) {
              case false:
                setState(() {
                  invState = id_inventory;
                  // refresh filteredItems karena yang ditampilkan adalah filteredItems
                  filteredItems = ItemWise().readByInventory(invState, id_user);
                });
                Navigator.pop(context);
                break;
              case true:
                log("edit anu");
                var id = id_inventory;
                setState(() {
                  // bersihkan isi textcontroller
                  NamaInvController.clear();
                  // ubah isi textcontroller
                  NamaInvController.text = inventoryWise()
                      .readByUser()
                      .firstWhere((element) =>
                          element["id_inventory"] == id)["nama_inventory"];
                });
                invNameDialog(context, id_inventory, "edit");
                break;
              default:
            }
          },
          // hapus
          onLongPress: () async {
            if (invState != id_inventory && invEditMode == false) {
              bool? hapus = await fungsies().konfirmasiDialog(context,
                  msg:
                      "${AppLocalizations.of(context)!.delete} \"${inventoryWise().readById(id_inventory)!["nama_inventory"]}\"?");
              if (hapus == true) {
                setState(() {
                  inventoryWise().delete(id_inventory);
                });
              }
            }
          },
          title: Text(
            inventoryWise().readByUser()[index]["nama_inventory"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text("$jml_brg ${AppLocalizations.of(context)!.items}"),
          trailing: invState == id_inventory
              ? const Icon(
                  Icons.person,
                  color: Colors.blue,
                )
              : const Icon(Icons.chevron_right_rounded),
        ))
      ],
    );
  }

  Widget addButton(BuildContext context) {
    return AnimatedScale(
      scale: selectedItems.isEmpty ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Tooltip(
        message: AppLocalizations.of(context)!.addItem,
        child: InkWell(
          onTap: () {
            resetPencarian();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => ViewItemPage(
                          invState: invState,
                        )));
          },
          radius: 35,
          borderRadius: BorderRadius.circular(30),
          child: const CircleAvatar(
            radius: 35,
            child: Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget listItems(BuildContext context) {
    List brgs = filteredItems;

    // mengurutkan barang
    brgs.sort((a, b) {
      String namaA = a['nama_barang'];
      String namaB = b['nama_barang'];
      DateTime timeA = DateTime.parse(a['added']);
      DateTime timeB = DateTime.parse(b['added']);

      // TODO: tambahkan variabel stok dan harga untuk sort
      int stokA = a['stok_barang'];
      int stokB = b['stok_barang'];
      int hJualA = a['harga_jual'];
      int hJualB = b['harga_jual'];

      switch (pengaturan.sortBy) {
        case sorter.name12:
          return namaA.compareTo(namaB);
        case sorter.name21:
          return namaB.compareTo(namaA);
        case sorter.added21:
          return timeA.compareTo(timeB);
        case sorter.added12:
          return timeB.compareTo(timeA);

        // TODO: tambah urutkan berdasarkan stok dan harga
        case sorter.stock12:
          return stokA.compareTo(stokB);
        case sorter.stock21:
          return stokB.compareTo(stokA);
        case sorter.hjual12:
          return hJualA.compareTo(hJualB);
        case sorter.hjual21:
          return hJualB.compareTo(hJualA);
        default:
          return namaA.compareTo(namaB);
      }
    });
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: List.generate(brgs.length, (index) {
              var id = brgs[index]['id_barang'];
              var title = brgs[index]['nama_barang'];
              return buildItem(index, context, id, title, brgs[index]);
            }),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              AppLocalizations.of(context)!.tapAndHoldToSelect,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.blue[200]),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: 150,
          )
        ],
      ),
    );
  }

  Widget buildItem(int index, BuildContext context, id, title, barang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(26, 0, 0, 0),
                  blurRadius: 2,
                  spreadRadius: 1)
            ],
            color: Colors.white),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Visibility(
                      visible: barang['photo_barang'] != "",
                      child: Row(
                        children: [
                          _inkWellPhotoBarang(barang, context, id),
                          Container(
                            width: 5,
                          ),
                        ],
                      )),
                  Expanded(
                    child: MyListTile(context, index, id, barang, tinggi: 70),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // buka bottomsheet
                        if (selectedItems.isEmpty) {
                          // ubah nilai harga jual controller dan stok
                          hargaJualController.text = CurrencyFormatter.format(
                              barang['harga_jual'],
                              CurrencyFormatterSettings(
                                  symbol: "", thousandSeparator: "."));
                          stokController.text =
                              barang['stok_barang'].toString();

                          // tampilkan bottom sheet
                          _tampilkanBottomSheet(context,
                              stokDanHargaSheet(context, barang['id_barang']));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: selectedItems.isEmpty
                                    ? Colors.blue
                                    : const Color.fromARGB(100, 158, 158, 158),
                                width: 1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          AppLocalizations.of(context)!.editStockAndPrice,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: selectedItems.isEmpty
                                  ? Colors.blue
                                  : const Color.fromARGB(100, 158, 158, 158),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  InkWell _inkWellPhotoBarang(barang, BuildContext context, id) {
    return InkWell(
        onTap: () async {
          Uint8List imgBytes = base64Decode(barang["photo_barang"]);
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PhotoViewPage(barang['id_barang'], imgBytes);
          })).then((value) => _refreshData());
        },
        child: fungsies().buildFotoBarang(context, barang, id));
  }

  Future<dynamic> _tampilkanBottomSheet(BuildContext context, Widget sheet) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: sheet),
          );
        });
  }

  InkWell MyListTile(BuildContext context, int index, id, barang,
      {double tinggi = 60}) {
    return InkWell(
      onTap: () async {
        if (selectedItems.isEmpty) {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => ViewItemPage(
                        itemMap: barang,
                        invState: invState == "all" ? null : invState,
                      ))).then((value) => _refreshData());
        } else {
          if (selectedItems.contains(id)) {
            log("deselect $id");
            setState(() {
              selectedItems.remove(id);
            });
          } else {
            log("select $id");
            setState(() {
              selectedItems.add(id);
            });
          }
        }
      },
      onLongPress: () async {
        setState(() {
          if (selectedItems.contains(id)) {
            log("deselect $id");
            setState(() {
              selectedItems.remove(id);
            });
          } else {
            log("select $id");
            setState(() {
              selectedItems.add(id);
            });
          }
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
        decoration: BoxDecoration(
            color: Color.fromARGB(
                selectedItems.contains(id) == true ? 100 : 0, 255, 229, 59),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // info nama brg
                Expanded(
                  child: Text(
                    barang['nama_barang'],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
                // menu lainnya
                AnimatedScale(
                  scale: selectedItems.isEmpty ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: IconButton(
                    onPressed: () {
                      log("tekan more");
                      _tampilkanBottomSheet(
                          context, moreMenu(context, barang['id_barang']));
                    },
                    icon: const Icon(Icons.more_horiz_rounded),
                    iconSize: 25,
                  ),
                )
              ],
            ),
            // info kode brg
            Text(
              barang['kode_barang'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 0.6),
            ),
            const Divider(
              color: Colors.transparent,
            ),
            //info harga jual + stok barang
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        CurrencyFormatter.format(
                            barang['harga_jual'], mataUangSetting),
                        // "${pengaturan.mataUang} ${barang['harga_jual']}",
                        style: const TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        "${AppLocalizations.of(context)!.stok}: ${barang['stok_barang']}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// refresh filteredItems
  void _refreshData() {
    setState(() {
      filteredItems = ItemWise().readByInventory(invState, id_user);
    });
  }

  /// digunakan untuk memilih direktori lalu menyimpannya untuk penggunaan selanjutnya
  ///
  /// akan mengembalikan `Directory`
  Future<Directory?> pickDirectory(BuildContext context) async {
    // cek akses memori
    await fungsies().cekAksesMemori();

    Directory directory =
        pengaturan.eksporDir ?? Directory(FolderPicker.rootPath);
    // log(directory.path);

    Directory? newDirectory = await FolderPicker.pick(
      allowFolderCreation: true,
      context: context,
      rootDirectory: directory,
      message: "Pilih folder",
    );

    return newDirectory;
  }

  _dialogSimpanExcel(BuildContext context) async {
    fileNameController.text =
        "ItemWise-${DateTime.now().toString().replaceAll(RegExp(r'\s|:|\.'), "-")}";

    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.saveAsExcel),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: fileNameController,
                        decoration: InputDecoration(
                            label:
                                Text(AppLocalizations.of(context)!.enterName)),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!.required;
                          } else {
                            bool simbolTerlarang =
                                RegExp(r'[\\/:\*\?\"<>\|]').hasMatch(value);
                            if (simbolTerlarang) {
                              return 'Simbol terlarang #"*:<>?/&]|';
                            }
                          }
                        },
                        onChanged: (value) {
                          bool simbolTerlarang =
                              RegExp(r'[\\/:\*\?\"<>\|]').hasMatch(value);
                          if (value.trim().isEmpty || simbolTerlarang) {
                            filenameValid = false;
                          } else {
                            filenameValid = true;
                          }
                        },
                      ),
                    ),
                    const Text(
                      ".xlsx",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                Container(
                  height: 20,
                ),
                Text(AppLocalizations.of(context)!.selectFolder),
                Container(
                  height: 10,
                ),
                Container(
                    // padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 216, 216, 216)),
                        borderRadius: BorderRadius.circular(5)),
                    child: StatefulBuilder(builder: (context, setState) {
                      return InkWell(
                        onTap: () async {
                          log("on tap");
                          Directory? dir = await pickDirectory(context);
                          if (dir != null) {
                            await pengaturan().ubahEksporDir(dir);
                          }
                          // mencegah eror `Unhandled Exception: setState() called after dispose()`
                          if (mounted) {
                            setState(() {
                              log("pengaturan ekspor diubah");
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.folder_rounded),
                            Container(
                              width: 5,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                dragStartBehavior: DragStartBehavior.down,
                                scrollDirection: Axis.horizontal,
                                child: Text(pengaturan.eksporDir!.path),
                              ),
                            )
                          ],
                        ),
                      );
                    })),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(color: Colors.grey),
                  )),
              TextButton(
                  onPressed: () async {
                    // cek apakah nama file valid
                    if (filenameValid) {
                      // ubah data menjadi excel, ini akan mengembalikan nilai byte
                      List<int> bytes =
                          await fungsies().generateExcel(filteredItems);

                      // tulis file
                      File excelFile = File(
                          "${pengaturan.eksporDir!.path}/${fileNameController.text.trim()}.xlsx");
                      log("${pengaturan.eksporDir!.path}/${fileNameController.text.trim()}.xlsx : ${bytes.length}");
                      await excelFile.writeAsBytes(bytes);

                      // buat snackbar
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(
                            "Sukses menyimpan ${fileNameController.text.trim()}.xlsx"),
                        duration: const Duration(seconds: 1, milliseconds: 500),
                      ));

                      // tutup dialog
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save))
            ],
          );
        });
  }

  /// cari barang berdasarkan teks lalu set filteredItems
  void cariBarang(String teks) {
    setState(() {
      filteredItems = ItemWise()
          .readByInventory(invState, id_user)
          .where((element) =>
              (element['nama_barang'] as String)
                  .toLowerCase()
                  .contains(teks.toLowerCase()) ||
              (element['kode_barang'] as String)
                  .toLowerCase()
                  .contains(teks.toLowerCase()) ||
              (element['catatan'] as String)
                  .toLowerCase()
                  .contains(teks.toLowerCase()))
          .toList();
    });
  }

  Container successButton(String msg) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.green),
        child: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ));
  }
}
