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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log('in homePage');
    getItems();
  }

  Future getItems() async {
    List a = await ItemWise.getItems();
    setState(() {
      ItemWise.items = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedItems.isEmpty
            ? Text(widget.title)
            : Text(
                "${selectedItems.length}",
                style: TextStyle(color: Colors.white),
              ),
        centerTitle: selectedItems.isEmpty,
        titleSpacing: 25,
        backgroundColor: selectedItems.isNotEmpty ? Colors.blue : Colors.white,
        actions: selectedItems.isEmpty
            ? null
            : [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 45,
                    ),
                    IconButton(
                        highlightColor: Colors.red,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          log("delete ${selectedItems}", name: "delete button");
                          deleteDialog(context);
                        },
                        icon: Icon(
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
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ))
              ],
      ),
      body: ItemWise.items.isNotEmpty
          ? Padding(
              padding: EdgeInsets.only(top: 10), child: listItems(context))
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
              var id = ItemWise.items[index]['id'];
              var title = ItemWise.items[index]['name'];
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
                  child: ItemWise.items[index]["img"] != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: Image.memory(
                            Uint8List.fromList(
                                base64.decode(ItemWise.items[index]["img"])),
                            fit: BoxFit.cover,
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
      borderRadius: BorderRadius.all(Radius.circular(15)),
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
              ItemWise.items[index]['name'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18),
            ),
            Text(
              ItemWise.items[index]['desc'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              "${AppLocalizations.of(context)!.stok}: ${ItemWise.items[index]['stock']}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> deleteDialog(BuildContext context, {String? id}) {
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
                    ItemWise.deleteItem(id);
                  }
                  ItemWise.saveItems();
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

  Container dangerButton(String msg) {
    return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.redAccent),
        child: Text(
          msg,
          style: TextStyle(color: Colors.white),
        ));
  }

  Container greyButton(String msg) {
    return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.grey),
        child: Text(
          msg,
          style: TextStyle(color: Colors.white),
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
