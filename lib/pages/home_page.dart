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
  TextEditingController mataUangController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  ScrollController invScrollController =
      ScrollController(keepScrollOffset: false);
  bool invEditMode = false;
  bool searchMode = false;
  GlobalKey namaInvKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String invState = widget.id_inv ?? "all";
  late AnimationController bottomSheetAC;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log('in homePage');
    checkDeviceId();
    authapi().auth(
        userWise.userData['email_user'], userWise.userData['password_user']);
    bottomSheetAC = BottomSheet.createAnimationController(this);
    mataUangController.text = pengaturan.mataUang;
    filteredItems = ItemWise().readByInventory(invState, id_user);
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
        toolbarHeight: 55,
        leading: selectedItems.isEmpty
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              )
            : Container(),
        title: selectedItems.isEmpty
            // jika tidak ada barang terpilih, maka tampilkan default atau pencarian
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
                        autofocus: searchMode,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.searchItem),
                        onChanged: (value) => cariBarang(value),
                      ),
                    ),
                  ),
                ],
              )
            // jika ada barang terpilih maka tampilkan jumlah barang dipilih
            : Text(
                "${selectedItems.length}",
                style: const TextStyle(color: Colors.white),
              ),
        centerTitle: selectedItems.isEmpty,
        titleSpacing: 0,
        backgroundColor: selectedItems.isNotEmpty ? Colors.blue : null,
        actions: selectedItems.isEmpty
            ? actionsIfSelectedItemsEmpty(context)
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
                    // refresh filteredItems karena yang ditampilkan adalah filteredItems
                    filteredItems =
                        ItemWise().readByInventory(invState, id_user);
                  });
                }
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
    ];
  }

  List<Widget> actionsIfSelectedItemsEmpty(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            log("ngubah searchMode");
            // jika searchMode == true maka akan mereset filteredItems
            if (searchMode) {
              resetPencarian();
            } else {
              setState(() {
                searchMode = true;
              });
            }
          },
          icon: const Icon(Icons.search_rounded)),
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
                break;
              case "adminPanel":
                log("goto adminPanel");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminPanel()));
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
                )
            ];
          }),
    ];
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
  // cek koneksi internet
  static Future<bool> isConnected() async {
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

  /// reset pencarian
  resetPencarian() {
    setState(() {
      searchMode = false;
      searchController.clear();
      // refresh filteredItems karena yang ditampilkan adalah filteredItems
      filteredItems = ItemWise().readByInventory(invState, id_user);
    });
  }

  Future backupAsset() async {
    log("ekspor aset");

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    var terkonek = await isConnected();
    List inv = inventoryWise().readByUser();
    List itm = ItemWise().readByUser();

    if (inventoryWise().readByUser().isNotEmpty ||
        ItemWise().readByUser().isNotEmpty) {
      if (terkonek && userWise.isLoggedIn) {
        await authapi().auth(
            // auth dulu ajah
            userWise.userData['email_user'],
            userWise.userData['password_user']);
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
          await photoBarangApiWise()
              .create(e['id_barang'], base64photo: e['photo_barang']);
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
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  content: Text(AppLocalizations.of(context)!.noInternet),
                ));
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    await authapi().auth(
        userWise.userData['email_user'], userWise.userData['password_user']);

    var terkonek = await isConnected();

    if (terkonek && userWise.isLoggedIn) {
      // load inventory
      await inventoryApiWise().read();
      // load barang
      // await ItemWise().clear();
      await itemApiWise().read();

      // tutup loading
      setState(() {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // log(ItemWise().readByUser().toList().toString());
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

  Widget stokAndHargaSheet(BuildContext context, String id_barang) {
    Map barang = filteredItems.firstWhere(
      // Map barang = ItemWise().readByUser().firstWhere(
      (element) => element['id_barang'] == id_barang,
    );

    // ini pencegahan value kena reset ketika render ulang (biasanya terjadi ketika menutup/memunculkan keyboard)
    // jika id_barang beda berarti ini build id_barang baru
    if (id_barang != idBrgOld) {
      hargaJualController.text = barang['harga_jual'].toString();
      stokController.text = barang['stok_barang'].toString();
    }
    // ini kalo sama
    else {
      if (hjalNew == "") {
        hargaJualController.text = barang['harga_jual'].toString();
      }
      if (stokNew == "") {
        stokController.text = barang['stok_barang'].toString();
      }
    }
    idBrgOld = id_barang;
    return BottomSheet(
        onClosing: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.transparent,
        animationController: bottomSheetAC,
        builder: (BuildContext context) {
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
                      Center(
                        child: Container(
                          height: 5,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5)),
                        ),
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
                            decoration: InputDecoration(
                                icon: Text(pengaturan.mataUang)),
                            onChanged: (value) {
                              clearNotNumber(value, hargaJualController);
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          log("minus");
                                          int stok =
                                              int.parse(stokController.text);
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
                                        child:
                                            circledIcon(Icons.remove_rounded)),
                                    Expanded(
                                      child: TextFormField(
                                        controller: stokController,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) {
                                          clearNotNumber(value, stokController);
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
                                          int stok =
                                              int.parse(stokController.text);
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
                                        stok_barang: int.parse(
                                            stokController.text.trim()),
                                        harga_jual: int.parse(
                                            hargaJualController.text.trim()),
                                        id_inventory: barang['id_inventory']);
                                    setState(() {
                                      // refresh filteredItems karena yang ditampilkan adalah filteredItems
                                      filteredItems = ItemWise()
                                          .readByInventory(invState, id_user);
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .successSave),
                                      duration: const Duration(seconds: 1),
                                    ));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                              color:
                                                  Color.fromARGB(70, 0, 0, 0),
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
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget moreMenuItem(BuildContext context, String id_barang) {
    // dapatkan map berdasarkan id_barang
    Map barang = ItemWise().readByIdBarang(id_barang);
    return BottomSheet(
        backgroundColor: Colors.transparent,
        animationController: bottomSheetAC,
        onClosing: () {
          Navigator.pop(context);
        },
        builder: (BuildContext context) {
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
                                    Text(AppLocalizations.of(context)!
                                        .editItemDetail),
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
                                    Text(AppLocalizations.of(context)!
                                        .selectItem),
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
                          bool? hapus =
                              await fungsies().konfirmasiDialog(context);
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
        });
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
    String id_inventory = inventoryWise().readByUser()[index]["id_inventory"];
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
    return SingleChildScrollView(
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          List brgs = filteredItems;
          // List brgs = invState == "all"
          //     ? filteredItems
          //     // ? ItemWise().readByUser()
          //     : ItemWise().readByInventory(invState, id_user);
          return Column(
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
          );
        },
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
                          buildFotoBarang(barang, id),
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
                          showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return stokAndHargaSheet(
                                    context, barang['id_barang']);
                              });
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

  Container buildFotoBarang(barang, id) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          color: barang["photo_barang"] != ""
              ? Colors.transparent
              : const Color.fromARGB(255, 186, 186, 186),
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: barang["photo_barang"] != ""
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Hero(
                tag: "image$id",
                child: Image.memory(
                  Uint8List.fromList(base64.decode(barang["photo_barang"])),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.image_rounded,
                color: Colors.white,
                size: 45,
              ),
            ),
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
                      showModalBottomSheet(
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return moreMenuItem(context, barang['id_barang']);
                          });
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
                  Text(
                    "${pengaturan.mataUang} ${barang['harga_jual']}",
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                  const VerticalDivider(),
                  Text(
                    "${AppLocalizations.of(context)!.stok}: ${barang['stok_barang']}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
