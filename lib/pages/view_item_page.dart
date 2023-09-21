import 'dart:typed_data';

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
  bool isEdited = false;
  bool isImgLscape = true;
  String img = "";

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
      img = widget.itemMap!["img"];

      CheckIsImgLscape(Uint8List.fromList(base64.decode(img)));
    } else if (widget.itemMap == null) {
      isEdit == false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isEdited) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MyHomePage()),
              (route) => false);
          return false;
        } else {
          Navigator.of(context).pop(true);
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (isEdited) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MyHomePage()),
                    (route) => false);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
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

              Container(
                height: 15,
              ),

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
              ),
              Divider(),
              // algoritma: jika widget.itemMap!['img'] != "" maka tampilkan gambar, jika tidak maka tampilkan "Tambahkan Gambar", bisa ngambil gambar dari kamera dan file
              cardFotoBarang(context)
            ],
          ),
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

  Future<void> _pickImage() async {
    log("START _pickImage");

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight:
            700); // Ganti dengan ImageSource.camera jika ingin menggunakan kamera

    if (pickedImage != null) {
      // Mengencode gambar ke dalam bentuk string (base64)
      final bytes = await pickedImage.readAsBytes();
      final encodedImage = base64Encode(bytes);


      // Lakukan sesuatu dengan gambar yang sudah diencode
      setState(() {
        img = encodedImage;
      });
      await CheckIsImgLscape(bytes);
    }

    log("DONE _pickedImage");
  }

  Future<void> CheckIsImgLscape(Uint8List bytes) async {
    if (img != "") {
      final size = ImageSizeGetter.getSize(MemoryInput(bytes));

      if (size.height > size.width) {
        setState(() {
          isImgLscape = false;
        });
      }
    }
  }

  Widget cardFotoBarang(BuildContext context) {
    return Card(
      elevation: 5,
      color: Color.fromARGB(255, 232, 232, 232),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
          height: isImgLscape ? 200 : 500,
          width: MediaQuery.of(context).size.width - 10,
          child: img == ""
              ? Center(
                  child: InkWell(
                    onTap: () {
                      _pickImage();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addPhoto,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const Icon(
                            Icons.add_photo_alternate_rounded,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                )
              // TODO: tampilkan gambar dari String hasil encode gambar
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    Uint8List.fromList(base64.decode(img)),
                    fit: BoxFit.cover,
                  ),
                )),
    );
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

            await ItemWise.addItem(name, desc, stock, purPrice, selPrice, img);
            await ItemWise.saveItems();
            clearTextController();
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MyHomePage()),
                (route) => false);
          } else if (widget.itemMap != null) {
            String name = _itemNameController.text.trim();
            String desc = _itemDescriptionController.text.trim();
            String stock = _itemStockController.text.trim();
            String purPrice = _purchasePriceController.text.trim();
            String selPrice = _sellingPriceController.text.trim();

            List a = [
              widget.itemMap!['nama'],
              widget.itemMap!["desc"],
              widget.itemMap!["stock"],
              widget.itemMap!["purPrice"],
              widget.itemMap!["selPrice"],
              widget.itemMap!["img"],
            ];
            List b = [name, desc, stock, purPrice, selPrice, img];

            for (var i = 0; i < a.length; i++) {
              if (a[i] != b[i]) {
                isEdited = true;
              }
            }

            if (isEdited) {
              await ItemWise.editItem(widget.itemMap!['id'], name, desc, stock,
                  purPrice, selPrice, img);
              await ItemWise.saveItems();
            }
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
