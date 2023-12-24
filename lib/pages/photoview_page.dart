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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // imgBytes = base64Decode(widget.base64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: Hero(
                tag: "image${widget.id_barang}",
                child: PhotoView(
                  enableRotation: true,
                  imageProvider: MemoryImage(widget.imgBytes),
                  maxScale: PhotoViewComputedScale.covered,
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
                    log("$details, $controllerValue");
                    setState(() {
                      showAppBar = !showAppBar;
                    });
                  },
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: showAppBar ? 50 : 0,
              child: AppBar(
                backgroundColor: Color.fromARGB(84, 0, 0, 0),
                leading: IconButton(
                    splashRadius: 25,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
