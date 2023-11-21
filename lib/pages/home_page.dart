import 'package:itemwise/allpackages.dart';
import 'package:flutter/material.dart';
import 'pages.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = "Item Wise", this.id_inv});

  final String title;
  final String? id_inv;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> selectedItems = [];
  late String invState;
  String id_user =
      userWise.isLoggedIn ? userWise.userData["id_user"] : deviceData.id;
  TextEditingController NamaInvController = TextEditingController();
  ScrollController invScrollController =
      ScrollController(keepScrollOffset: false);
  bool invEditMode = false;
  GlobalKey namaInvKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log('in homePage');
    checkDeviceId();
    invState = widget.id_inv ?? "all";
    log("WOIIII${widget.id_inv}$invState");
  }

  void checkDeviceId() async {
    var isIdSaved = await deviceData().isKeyAvailable("deviceId");
    // A.K.A pertama kali buka,
    // deviceId ini digunakan untuk pengganti idUser di atribut inv dan brg,
    // ketika login nanti muncul dialog: (judul: "Pindahkan aset saat ini ke akun Anda?", msg: "Jika iya maka aset hanya bisa diakses ketika menggunakan akun ini, jika tidak maka aset hanya bisa diakses ketika tidak terhubung dengan akun apapun, harap pikirkan dengan bijak")
    if (isIdSaved == false) {
      var a = await DeviceInfoPlugin().deviceInfo;
      var b = a.data;
      var c = '${b["deviceId"]}';
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
      drawerEnableOpenDragGesture: selectedItems.isEmpty,
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 55,
        leading: selectedItems.isEmpty
            ? IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              )
            : Container(),
        title: selectedItems.isEmpty
            ? Column(
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
                              text: inventoryWise()
                                  .readByUser(id_user)
                                  .firstWhere((element) =>
                                      element["id_inventory"] ==
                                      invState)["nama_inventory"],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    )
                ],
              )
            : Text(
                "${selectedItems.length}",
                style: const TextStyle(color: Colors.white),
              ),
        centerTitle: selectedItems.isEmpty,
        titleSpacing: 0,
        backgroundColor: selectedItems.isNotEmpty ? Colors.blue : null,
        actions: selectedItems.isEmpty
            ? [
                PopupMenuButton(onSelected: (value) async {
                  switch (value) {
                    case "profil":
                      log("profil");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const userPage()));
                      break;
                    case "ekspor":
                      await backupAsset();
                      break;
                    case "impor":
                      await loadAsset();
                      break;
                    default:
                  }
                }, itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                        value: "profil",
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(userWise.isLoggedIn
                                ? Icons.account_box_rounded
                                : Icons.login_rounded),
                            Container(
                              width: 10,
                            ),
                            Text(userWise.isLoggedIn
                                ? AppLocalizations.of(context)!.profile
                                : AppLocalizations.of(context)!.login)
                          ],
                        )),
                    if (userWise.isLoggedIn)
                      PopupMenuItem(
                          value: "ekspor",
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.backup_rounded),
                              Container(
                                width: 10,
                              ),
                              Text(AppLocalizations.of(context)!.bakcup)
                            ],
                          )),
                    if (userWise.isLoggedIn)
                      PopupMenuItem(
                          value: "impor",
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.download_rounded),
                              Container(
                                width: 10,
                              ),
                              Text(AppLocalizations.of(context)!.loadData)
                            ],
                          ))
                  ];
                })
              ]
            : [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 45,
                    ),
                    IconButton(
                        highlightColor: Colors.red,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          log("delete $selectedItems", name: "delete button");
                          deleteItemDialog(context);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ))
                  ],
                ),
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
              ],
      ),
      body: ItemWise().readByInventory(invState, id_user).isNotEmpty
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
      floatingActionButton: Visibility(
        child: addButton(context),
        visible: selectedItems.isEmpty,
      ),
    );
  }

  //-----------------------------------------------------------------------------//
  // cek koneksi internet
  Future<bool> isConnected() async {
    var internet = await InternetConnectionCheckerPlus().hasConnection;
    if (internet == false) {
      print('Tidak terhubung ke internet');
      return false;
    } else {
      print('Terhubung ke internet');
      return true;
    }
  }

  Future backupAsset() async {
    log("ekspor aset");

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });

    var terkonek = await isConnected();
    List inv = inventoryWise().readByUser(id_user);
    List itm = ItemWise().readByUser(id_user);

    if (inventoryWise().readByUser(id_user).isNotEmpty ||
        ItemWise().readByUser(id_user).isNotEmpty) {
      if (terkonek && userWise.isLoggedIn) {
        // bakcup inventory
        for (var element in inv) {
          await inventoryApiWise().create(
              id_inventory: element["id_inventory"],
              id_user: element["id_user"],
              nama_inventory: element["nama_inventory"]);
        }
        // backup barang
        for (var element in itm) {
          await itemApiWise().create(element['id_barang']);
        }
        // tutup loading
        Navigator.pop(context);
      }
    }

    log("bakcup func done");
  }

  Future loadAsset() async {
    log("load aset");

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });

    var terkonek = await isConnected();

    if (terkonek && userWise.isLoggedIn) {
      // load inventory
      await inventoryApiWise().read();
      // load barang
      await itemApiWise().read();

      // tutup loading
      setState(() {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });
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
                                "inv${DateTime.now().millisecondsSinceEpoch.toString()}";
                            setState(() {
                              invEditMode = false;
                            });
                            invNameDialog(context, id_inventory, "add");
                          },
                          tooltip: AppLocalizations.of(context)!.addInventory,
                          icon: const Icon(Icons.add_box)),
                      // edit
                      IconButton(
                        onPressed: () {
                          if (inventoryWise().readByUser(id_user).isNotEmpty) {
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
                      Stack(alignment: Alignment.center, children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              invState = "all";
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
              if (inventoryWise().readByUser(id_user).isNotEmpty)
                Expanded(
                  child: ListView(
                    controller: invScrollController,
                    children: List.generate(
                        inventoryWise().readByUser(id_user).length, (index) {
                      return _inventoryTile(index, context);
                    }),
                  ),
                ),
              if (inventoryWise().readByUser(id_user).isNotEmpty)
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
              if (inventoryWise().readByUser(id_user).isEmpty)
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

  Future<dynamic> invNameDialog(
      BuildContext context, String id_inventory, String mode) {
    NamaInvController.clear();
    return showDialog(
        context: context,
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
              InkWell(
                onTap: () async {
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
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: successButton(AppLocalizations.of(context)!.save)),
              )
            ],
          );
        });
  }

  Row _inventoryTile(int index, BuildContext context) {
    String id_inventory =
        inventoryWise().readByUser(id_user)[index]["id_inventory"];
    int jml_brg = ItemWise().readByInventory(id_inventory, id_user).length;
    return Row(
      children: [
        Expanded(
            child: ListTile(
          onTap: () {
            log("tap ${id_inventory}");
            switch (invEditMode) {
              case false:
                setState(() {
                  invState = id_inventory;
                });
                Navigator.pop(context);
                break;
              case true:
                log("edit anu");
                var id = id_inventory;
                setState(() {
                  // ubah isi textcontroller
                  NamaInvController.text = inventoryWise()
                      .readByUser(id_user)
                      .firstWhere((element) =>
                          element["id_inventory"] == id)["nama_inventory"];
                });
                invNameDialog(context, id_inventory, "edit");
                break;
              default:
            }
          },
          // hapus
          onLongPress: () {
            if (invState != id_inventory && invEditMode == false) {
              deleteInvDialog(context, id_inventory);
            }
          },
          title: Text(
            inventoryWise().readByUser(id_user)[index]["nama_inventory"],
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
    return Tooltip(
      message: AppLocalizations.of(context)!.addItem,
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => ViewItemPage(
                      invState: invState,
                    ))),
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
    );
  }

  Widget listItems(BuildContext context) {
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          List brgs = invState == "all"
              ? ItemWise().readByUser(id_user)
              : ItemWise().readByInventory(invState, id_user);
          return Column(
            children: List.generate(brgs.length, (index) {
              var id = brgs[index]['id_barang'];
              var title = brgs[index]['nama_barang'];
              return buildItem(index, context, id, title, brgs[index]);
            }),
          );
        },
      ),
    );
  }

  Widget buildItem(int index, BuildContext context, id, title, barang) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Hero(
                tag: "image$index",
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: barang["photo_barang"] != ""
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          child: Image.memory(
                            Uint8List.fromList(
                                base64.decode(barang["photo_barang"])),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_rounded,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                ),
              ),
              Container(
                width: 5,
              ),
              Expanded(
                child: MyListTile(context, index, id, barang, tinggi: 70),
              )
            ],
          ),
        ),
        const Divider(
          height: 10,
        )
      ],
    );
  }

  InkWell MyListTile(BuildContext context, int index, id, barang,
      {double tinggi = 60}) {
    return InkWell(
      onTap: () async {
        if (selectedItems.isEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => ViewItemPage(
                        itemMap: barang,
                        invState: invState == "all" ? null : invState,
                      )));
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
        padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
        decoration: BoxDecoration(
            color: Color.fromARGB(
                selectedItems.contains(id) == true ? 100 : 0, 255, 229, 59),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              barang['nama_barang'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              barang['catatan'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              "${AppLocalizations.of(context)!.stok}: ${barang['stok_barang']}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> deleteItemDialog(BuildContext context, {String? id}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              "${AppLocalizations.of(context)!.delete} ${selectedItems.length} ${AppLocalizations.of(context)!.items}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: greyButton(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  for (var id in selectedItems) {
                    ItemWise().delete(id);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(dangerSnackbar(
                      context,
                      "${AppLocalizations.of(context)!.delete} ${selectedItems.length} ${AppLocalizations.of(context)!.items}"));
                  selectedItems.clear();
                });
                Navigator.of(context).pop();
              },
              child: dangerButton(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> deleteInvDialog(BuildContext context, String id) {
    var idx = inventoryWise()
        .readByUser(id_user)
        .indexWhere((e) => e["id_inventory"] == id);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              "${AppLocalizations.of(context)!.delete} \"${inventoryWise().readByUser(id_user)[idx]["nama_inventory"]}\"?"),
          actions: <Widget>[
            // tombol cancel
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: greyButton(AppLocalizations.of(context)!.cancel),
            ),
            // tombol hapus
            TextButton(
              onPressed: () async {
                setState(() {
                  // hapus
                  inventoryWise().delete(id);
                  // ubah id_inventory menjadi null ke semua barang yang mengandung id ini
                  ItemWise.items.forEach((element) {
                    if (element["id_inventory"] == id) {
                      ItemWise()
                          .update(element["id_barang"], id_inventory: null);
                    }
                  });
                  // tampilkan snakbar
                  ScaffoldMessenger.of(context).showSnackBar(dangerSnackbar(
                      context,
                      "${AppLocalizations.of(context)!.delete} ${AppLocalizations.of(context)!.inventory}"));
                  selectedItems.clear();
                });
                Navigator.of(context).pop();
              },
              child: dangerButton(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  Container dangerButton(String msg) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.redAccent),
        child: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ));
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

  Container greyButton(String msg) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.grey),
        child: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        ));
  }

  SnackBar dangerSnackbar(BuildContext context, String msg) {
    return SnackBar(
      content: Text(msg),
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 1),
    );
  }
}
