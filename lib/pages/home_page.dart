import 'dart:developer';

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: items.isNotEmpty ? SingleChildScrollView(
        child: Column(
            children: List.generate(items.length, (index) {
          var id = items[index]['id'];
          var title = items[index]['title'];
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
                  return tampilkanDialog(context, id, title);
                },
                onLongPress: () async {
                  setState(() {
                    items.removeWhere((element) => element["id"] == id);
                  });
                },
              ))
            ],
          );
        })),
      )
      : const Center(child: Text('😮\nItem Anda kosong', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 156, 210, 255)), textAlign: TextAlign.center,),),
      floatingActionButton: FloatingActionButton(
        onPressed: _addList,
        tooltip: 'Tambah Data',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> tampilkanDialog(BuildContext context, id, title) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🦗'),
          content: Text('🤔id: $id\n-----\n😅title: $title'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
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
}
