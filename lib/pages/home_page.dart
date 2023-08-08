import 'dart:developer';

import 'package:itemwise/allpackages.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List items = [
    {"id": "ini id unik", "title": "ini title"}
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log('in homePage');
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: items.isNotEmpty
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
      child: Column(
          children: List.generate(items.length, (index) {
        var id = items[index]['id'];
        var title = items[index]['title'];
        return buildItem(index, context, id, title);
      })),
    );
  }

  Widget buildItem(int index, BuildContext context, id, title) {
    return Row(
      children: [
        Expanded(
            child: ListTile(
          leading: const CircleAvatar(
            radius: 22,
            child: Icon(Icons.ac_unit),
          ),
          title: Text(items[index]['title']),
          subtitle: Text(items[index]['id']),
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => ViewItemPage(
                          itemMap: items[index],
                        )));
          },
          onLongPress: () async {
            setState(() {
              items.removeWhere((element) => element["id"] == id);
            });
          },
        ))
      ],
    );
  }

  void _addList() {
    log('START _adList');
    setState(() {
      items.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": DateTime.now().toString()
      });
    });
    log('DONE _adList');
  }

  void saveItems() async {
    log('START saveItems');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String a = jsonEncode(items);

    await prefs.setString('items', a);
    log('DONE saveItems');
  }

  void getItems() async {
    log('START getItems');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    log(prefs.getString('items') == null ? 'items null' : 'items ada');
    String a = prefs.getString('items') ?? jsonEncode(items);

    List b = jsonDecode(a);

    setState(() {
      items = b;
    });
    log('DONE getItems');
  }
}
