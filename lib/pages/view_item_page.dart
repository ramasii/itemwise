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
      _itemNameController.text = widget.itemMap!['nama_barang'];
      _itemDescriptionController.text = widget.itemMap!['catatan'];
      _itemStockController.text = widget.itemMap!['stok_barang'].toString();
      _purchasePriceController.text = widget.itemMap!['harga_beli'].toString();
      _sellingPriceController.text = widget.itemMap!['harga_jual'].toString();
      img = widget.itemMap!["photo_barang"];

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
              /* // tampilkan id barang
              if (widget.itemMap != null)
                Text("barang: ${widget.itemMap!['id_barang']}"),
              // tampilkan id user pemilik barang
              if (widget.itemMap != null)
                Text("pemilik: ${widget.itemMap!['id_user']}"),
              // tampilkan user saat ini
              if (userWise.isLoggedIn)
                Text("user now: ${userWise.userData['id_user']}")
              else
                Text("tanpa akun: ${deviceData.id}"), */

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
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.purPrice,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
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
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.selPrice,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        clearNotNumber(value, _sellingPriceController);
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              // algoritma: jika widget.itemMap!['img'] != "" maka tampilkan gambar, jika tidak maka tampilkan "Tambahkan Gambar", bisa ngambil gambar dari kamera dan file
              cardFotoBarang(context),
              Container(
                height: 10,
              ),
              img != ""
                  ? Text(
                      AppLocalizations.of(context)!.holdToRemoveImg,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    )
                  : Container(),
              Container(
                height: isImgLscape == true || img == "" ? 250 : 100,
              )
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
        source: ImageSource.gallery, maxHeight: 700);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final encodedImage = base64Encode(bytes);

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
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 350),
        child: Card(
          elevation: 5,
          color: Color.fromARGB(255, 232, 232, 232),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  : InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onLongPress: () {
                        confirmDialog(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          Uint8List.fromList(base64.decode(img)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!.deleteImgCfrmation),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: greyButton(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  img = "";
                  isImgLscape = true;
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

  Widget saveButton(BuildContext context) {
    return Tooltip(
      message: "",
      child: InkWell(
        onTap: () async {
          if (_itemNameController.text.trim() != "" &&
              _itemStockController.text.trim() != "") {
            // add item
            if (widget.itemMap == null) {
              String nama_barang = _itemNameController.text;
              String catatan = _itemDescriptionController.text;
              int stok_barang = int.parse(_itemStockController.text);
              int harga_beli = int.parse(_purchasePriceController.text);
              int harga_jual = int.parse(_sellingPriceController.text);
              String id_user = userWise.userData["id_user"] != ""
                  ? userWise.userData["id_user"]
                  : deviceData.id;
              String id_barang =
                  "${id_user}brg${DateTime.now().millisecondsSinceEpoch.toString()}";

              setState(() {
                ItemWise().create(id_barang, id_user, nama_barang, stok_barang,
                    harga_beli, harga_jual,
                    catatan: catatan);
              });

              clearTextController();
              // ignore: use_build_context_synchronously
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MyHomePage()),
                  (route) => false);
            }
            // edit item
            else if (widget.itemMap != null) {
              String nama_barang = _itemNameController.text.trim();
              String catatan = _itemDescriptionController.text.trim();
              int stok_barang = int.parse(_itemStockController.text.trim());
              int harga_beli = int.parse(_purchasePriceController.text.trim());
              int harga_jual = int.parse(_sellingPriceController.text.trim());

              List lama = [
                widget.itemMap!['nama_barang'],
                widget.itemMap!["catatan"],
                widget.itemMap!["stok_barang"],
                widget.itemMap!["harga_beli"],
                widget.itemMap!["harga_jual"],
                widget.itemMap!["photo_barang"],
              ];
              List baru = [
                nama_barang,
                catatan,
                stok_barang,
                harga_beli,
                harga_jual,
                img
              ];

              // cek apakah data berbeda, jika beda berarti diedit
              for (var i = 0; i < lama.length; i++) {
                if (lama[i] != baru[i]) {
                  isEdited = true;
                }
              }

              // jika menekan tombol save dan diedit maka simpan
              // jadi ketika tidak ada perubahan maka sistem tidak melakukan proses edit
              if (isEdited) {
                ItemWise().update(widget.itemMap!['id_barang'],
                    nama_barang: nama_barang,
                    catatan: catatan,
                    stok_barang: stok_barang,
                    harga_beli: harga_beli,
                    harga_jual: harga_jual,
                    photo_barang: img);
              }
            }
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(successSnackbar(
                context, AppLocalizations.of(context)!.successSave));
          } else {
            if (_itemNameController.text.trim() == "") {
              ScaffoldMessenger.of(context).showSnackBar(dangerSnackbar(
                  context, AppLocalizations.of(context)!.itemNameAlert));
            } else if (_itemStockController.text.trim() == "") {
              ScaffoldMessenger.of(context).showSnackBar(dangerSnackbar(
                  context, AppLocalizations.of(context)!.itemStockAlert));
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

  SnackBar dangerSnackbar(BuildContext context, String msg) {
    return SnackBar(
      content: Text(msg),
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: Colors.redAccent,
    );
  }

  SnackBar successSnackbar(BuildContext context, String msg) {
    return SnackBar(
      content: Text(msg),
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: Colors.green,
    );
  }
}
