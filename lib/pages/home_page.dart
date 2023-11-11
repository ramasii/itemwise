import 'package:itemwise/allpackages.dart';
import 'package:flutter/material.dart';
import 'pages.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = "Item Wise"});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> selectedItems = [];
  String invState = "all";
  String id_user = "id_user";
  TextEditingController NamaInvController = TextEditingController();
  ScrollController invScrollController =
      ScrollController(keepScrollOffset: false);
  bool invEditMode = false;
  GlobalKey namaInvKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log('in homePage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _homeDrawer(context),
      appBar: AppBar(
        toolbarHeight: 55,
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
                              text: inventoryWise.inventories.firstWhere(
                                  (element) =>
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
        backgroundColor: selectedItems.isNotEmpty ? Colors.blue : Colors.white,
        actions: selectedItems.isEmpty
            ? [
                PopupMenuButton(onSelected: (value) {
                  switch (value) {
                    case "profil":
                      log("msg2");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const userPage()));
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
                            Icon(Icons.account_box_rounded),
                            Container(
                              width: 10,
                            ),
                            Text(AppLocalizations.of(context)!.profile)
                          ],
                        )),
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
      body: ItemWise.items.isNotEmpty
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

                            invNameDialog(context, id_inventory, "add");
                          },
                          tooltip: AppLocalizations.of(context)!.addInventory,
                          icon: const Icon(Icons.add_box)),
                      // edit
                      IconButton(
                        onPressed: () {
                          log("ngedit");
                          setState(() {
                            invEditMode = !invEditMode;
                          });
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
                  const Divider()
                ],
              ),
              if (inventoryWise.inventories.isNotEmpty)
                Expanded(
                  child: ListView(
                    controller: invScrollController,
                    children: List.generate(inventoryWise.inventories.length,
                        (index) {
                      return _inventoryTile(index, context);
                    }),
                  ),
                ),
              if (inventoryWise.inventories.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    invEditMode
                        ? AppLocalizations.of(context)!.tapToEditInv
                        : AppLocalizations.of(context)!.holdToRemoveInv,
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.blue[200]),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (inventoryWise.inventories.isEmpty)
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
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return AlertDialog(
            key: namaInvKey,
            title: mode == "add"
                ? Text(AppLocalizations.of(context)!.addInventory)
                : Text(AppLocalizations.of(context)!.changeName),
            content: Container(
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
    return Row(
      children: [
        Expanded(
            child: ListTile(
          onTap: () {
            log("tap ${inventoryWise.inventories[index]["id_inventory"]}");
            switch (invEditMode) {
              case false:
                setState(() {
                  invState = inventoryWise.inventories[index]["id_inventory"];
                });
                Navigator.pop(context);
                break;
              case true:
                log("edit anu");
                var id = inventoryWise.inventories[index]["id_inventory"];
                setState(() {
                  // ubah isi textcontroller
                  NamaInvController.text = inventoryWise.inventories.firstWhere(
                      (element) =>
                          element["id_inventory"] == id)["nama_inventory"];
                });
                invNameDialog(context,
                    inventoryWise.inventories[index]["id_inventory"], "edit");
                break;
              default:
            }
          },
          // hapus
          onLongPress: () {
            if (invState != inventoryWise.inventories[index]["id_inventory"] &&
                invEditMode == false) {
              deleteInvDialog(
                  context, inventoryWise.inventories[index]["id_inventory"]);
            }
          },
          title: Text(
            inventoryWise.inventories[index]["nama_inventory"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: const Text("<jml_brg> items"),
          trailing: invState == inventoryWise.inventories[index]["id_inventory"]
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
            context, MaterialPageRoute(builder: (ctx) => const ViewItemPage())),
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
          return Column(
            children: List.generate(ItemWise.items.length, (index) {
              var id = ItemWise.items[index]['id_barang'];
              var title = ItemWise.items[index]['nama_barang'];
              return buildItem(index, context, id, title);
            }),
          );
        },
      ),
    );
  }

  Widget buildItem(int index, BuildContext context, id, title) {
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
                  child: ItemWise.items[index]["photo_barang"] != ""
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          child: Image.memory(
                            Uint8List.fromList(base64
                                .decode(ItemWise.items[index]["photo_barang"])),
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
                child: MyListTile(context, index, id, tinggi: 70),
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

  InkWell MyListTile(BuildContext context, int index, id,
      {double tinggi = 60}) {
    return InkWell(
      onTap: () async {
        if (selectedItems.isEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => ViewItemPage(
                        itemMap: ItemWise.items[index],
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
              ItemWise.items[index]['nama_barang'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              ItemWise.items[index]['catatan'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              "${AppLocalizations.of(context)!.stok}: ${ItemWise.items[index]['stok_barang']}",
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
    var idx =
        inventoryWise.inventories.indexWhere((e) => e["id_inventory"] == id);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              "${AppLocalizations.of(context)!.delete} \"${inventoryWise.inventories[idx]["nama_inventory"]}\"?"),
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
    );
  }
}
