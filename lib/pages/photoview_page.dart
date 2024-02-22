import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itemwise/allpackages.dart';
import 'package:flutter/widgets.dart';

class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage(
    this.id_barang,
    this.imgBytes, {
    super.key,
  });

  final Uint8List imgBytes; // img
  final String id_barang;

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  // late Uint8List imgBytes;
  bool showAppBar = true;
  late Uint8List gambarByte;

  @override
  void initState() {
    super.initState();
    gambarByte = widget.imgBytes;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(base64Encode(gambarByte));
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
            child: _appBar(context), preferredSize: const Size.fromHeight(56)),
        body: _tempatFoto(),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return AnimatedOpacity(
      opacity: showAppBar ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: AppBar(
        backgroundColor: const Color.fromARGB(84, 0, 0, 0),
        leading: IconButton(
            splashRadius: 25,
            onPressed: () =>
                Navigator.of(context).pop(base64Encode(gambarByte)),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            )),
        actions: [
          IconButton(
              onPressed: () async {
                log("ubah foto");
                // pilih sumber foto
                log("pilih sumber foto");
                bool? fromCam = await fungsies().konfirmasiDialog(context,
                    msg: AppLocalizations.of(context)!.choosePhotoSource,
                    trueText: AppLocalizations.of(context)!.camera,
                    falseText: AppLocalizations.of(context)!.gallery,
                    trueColor: Colors.blue);
                var imeg = "";

                // ambil foto
                if (fromCam != null) {
                  log("ambil foto");
                  String base64img = await fungsies().pickImage(
                      from: fromCam
                          ? PickImageFrom.camera
                          : PickImageFrom.gallery);
                  // jika foto sudah dipilih
                  if (base64img != "") {
                    log("foto sudah dipilih");
                    // ubah base64img menjadi Uint8List
                    Uint8List imgBytes = base64Decode(base64img);
                    // cek apakah ada barangnya
                    // jika ga ada berarti sedang menambah barang
                    // jika da berarti sedang mengedit
                    var cek = ItemWise().readByIdBarang(widget.id_barang);
                    // edit photo_barang
                    if (cek != -1) {
                      await ItemWise()
                          .update(widget.id_barang, photo_barang: base64img);
                    }
                    // ubah nilai widget.imgBytes
                    setState(() {
                      gambarByte = imgBytes;
                    });
                  }
                }
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ))
        ],
      ),
    );
  }

  Widget _tempatFoto() {
    return Hero(
      tag: "image${widget.id_barang}",
      child: PhotoView(
        imageProvider: MemoryImage(gambarByte),
        maxScale: 10.0,
        minScale: PhotoViewComputedScale.contained,
        initialScale: PhotoViewComputedScale.contained,
        scaleStateChangedCallback: (value) {
          log(value.toString());
          setState(() {
            if (value == PhotoViewScaleState.zoomedIn) {
              showAppBar = false;
            } else if (value == PhotoViewScaleState.zoomedOut) {
              showAppBar = true;
            }
          });
        },
        onTapDown: (context, details, controllerValue) {
          // log("$details, $controllerValue");
          setState(() {
            showAppBar = !showAppBar;
          });
        },
      ),
    );
  }
}
