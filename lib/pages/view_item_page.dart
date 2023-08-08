import 'dart:developer';

import 'package:itemwise/allpackages.dart';
import 'package:flutter/material.dart';

class ViewItemPage extends StatefulWidget {
  const ViewItemPage({super.key, this.itemMap});

  final Map? itemMap;

  @override
  State<ViewItemPage> createState() => _ViewItemPageState();
}

class _ViewItemPageState extends State<ViewItemPage> {
  List<Map> items = [];
  bool isEdit = true;

  @override
  void initState() {
    super.initState();
    log('in viewItemPage');
    if (widget.itemMap != null) {
      isEdit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.itemMap == null
              ? AppLocalizations.of(context)!.addItem
              : AppLocalizations.of(context)!.itemDetail),
        ),
        floatingActionButton: saveButton(context),
        body: const Center(
          child: Text('ini halaman add/view/edit'),
        ));
  }

  Widget saveButton(BuildContext context) {
    return Tooltip(
      message: "",
      child: InkWell(
        /* onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (ctx) => const ViewItemPage())), */
        radius: 35,
        borderRadius: BorderRadius.circular(30),
        child: const CircleAvatar(
          radius: 35,
          child: Icon(
            Icons.save_rounded,
            size: 30,
          ),
        ),
      ),
    );
  }
}
