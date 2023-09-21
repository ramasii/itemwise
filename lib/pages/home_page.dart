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
        title: Text(widget.title),
      ),
      body: ItemWise.items.isNotEmpty
          ? listItems(context)
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
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(color: Colors.blue),
          child: const Center(
            child: Text("70x70", style: TextStyle(color: Colors.white),),
          ),
        ),
        Expanded(
          child: MyListTile(context, index, id, tinggi: 70),
        )
      ],
    );
  }

  //-----------------------------------------------------------------------------//

  InkWell MyListTile(BuildContext context, int index, id, {double tinggi = 60}) {
    return InkWell(
          onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => ViewItemPage(
                            itemMap: ItemWise.items[index],
                          )));
            },
            onLongPress: () async {
              setState(() {
                ItemWise.items.removeWhere((element) => element["id"] == id);
              });
            },
          child: Container(
            height: tinggi,
            padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ItemWise.items[index]['name'],
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ItemWise.items[index]['desc'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),),
              ],
            ),
          ),
        );
  }
}
