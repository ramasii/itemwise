import 'package:itemwise/allpackages.dart';
import 'package:flutter/material.dart';
import 'package:itemwise/pages/home_page.dart';

class ViewItemPage extends StatefulWidget {
  const ViewItemPage({super.key, this.itemMap});

  final Map? itemMap;

  @override
  State<ViewItemPage> createState() => _ViewItemPageState();
}

class _ViewItemPageState extends State<ViewItemPage> {
  List items = [];
  bool isEdit = true;

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _itemStockController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log('in viewItemPage');
    if (widget.itemMap != null) {
      isEdit = true;
      _itemNameController.text = widget.itemMap!['name'];
      _itemDescriptionController.text = widget.itemMap!['desc'];
      _itemStockController.text = widget.itemMap!['stock'].toString();
      _purchasePriceController.text = widget.itemMap!['purPrice'].toString();
      _sellingPriceController.text = widget.itemMap!['selPrice'].toString();
    } else if (widget.itemMap == null) {
      isEdit == false;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // nama item | item name
            TextFormField(
              controller: _itemNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Item name is required';
                }
                return null; // Validasi berhasil
              },
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.itemName),
            ),

            // deskripsi | description
            TextFormField(
              controller: _itemDescriptionController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description),
              maxLines: null,
            ),

            // stok | stock
            TextFormField(
              key: GlobalKey(),
              controller: _itemStockController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Item name is required';
                } else {
                  return null; // Validasi berhasil
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.itemStock),
              onChanged: (value) {
                // Membersihkan karakter selain angka
                clearNotNumber(value, _itemStockController);
              },
            ),

            Container(height: 15,),

            // harga beli | purchase price | buy price
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _purchasePriceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Item name is required';
                      }
                      return null; // Validasi berhasil
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.purPrice,
                      border: OutlineInputBorder(
                        // Mengatur border
                        borderRadius: BorderRadius.circular(
                            10.0), // Mengatur sudut border
                      ),
                    ),
                    onChanged: (value) {
                      // Membersihkan karakter selain angka
                      clearNotNumber(value, _purchasePriceController);
                    },
                  ),
                ),

                const Spacer(),

                // harga jual | sell price
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _sellingPriceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Item name is required';
                      }
                      return null; // Validasi berhasil
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.selPrice,
                      border: OutlineInputBorder(
                        // Mengatur border
                        borderRadius: BorderRadius.circular(
                            10.0), // Mengatur sudut border
                      ),
                    ),
                    onChanged: (value) {
                      // Membersihkan karakter selain angka
                      clearNotNumber(value, _sellingPriceController);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
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

  void clearTextController() {
    setState(() {
      _itemDescriptionController.clear();
      _itemNameController.clear();
      _itemStockController.clear();
      _purchasePriceController.clear();
      _sellingPriceController.clear();
    });
  }

  Widget saveButton(BuildContext context) {
    return Tooltip(
      message: "",
      child: InkWell(
        onTap: () async {
          if (widget.itemMap == null) {
            String name = _itemNameController.text;
            String desc = _itemDescriptionController.text;
            String stock = _itemStockController.text;
            String purPrice = _purchasePriceController.text;
            String selPrice = _sellingPriceController.text;
            await ItemWise.addItem(name, desc, stock, purPrice, selPrice);
            await ItemWise.saveItems();
            clearTextController();
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MyHomePage()),
                (route) => false);
          } else if (widget.itemMap != null) {
            String name = _itemNameController.text;
            String desc = _itemDescriptionController.text;
            String stock = _itemStockController.text;
            String purPrice = _purchasePriceController.text;
            String selPrice = _sellingPriceController.text;
            await ItemWise.editItem(
                widget.itemMap!['id'], name, desc, stock, purPrice, selPrice);
            await ItemWise.saveItems();
          }
        },
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
