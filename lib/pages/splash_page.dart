import 'package:flutter/material.dart';
import 'package:itemwise/allpackages.dart';
import 'package:itemwise/pages/user_page.dart';
import 'pages.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    inventoryWise().read();
    userWise().read();
    checkDeviceId();

    // anim
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final Animation<double> curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    final Animatable<double> growAnimation = Tween<double>(begin: 0, end: 100);
    final Animatable<double> shrinkAnimation =
        Tween<double>(begin: 100, end: 75);

    _radiusAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: growAnimation, weight: 1),
      TweenSequenceItem(tween: shrinkAnimation, weight: 1),
    ]).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Delay selama 1 detik sebelum berpindah ke halaman utama
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => deviceData.id != ""
                  ? const MyHomePage(
                      title: "Item Wise",
                    )
                  : const userPage() /* MyHomePage(title: 'Item Wise') */,
            ),
          );
        });
      }
    });

    _animationController.forward();
  }

  void checkDeviceId() async {
    var isIdSaved = await deviceData().isKeyAvailable("deviceId");
    // A.K.A pertama kali buka,
    // deviceId ini digunakan untuk pengganti idUser di atribut inv dan brg,
    // ketika login nanti muncul dialog: (judul: "Pindahkan aset saat ini ke akun Anda?", msg: "Jika iya maka aset hanya bisa diakses ketika menggunakan akun ini, jika tidak maka aset hanya bisa diakses ketika tidak terhubung dengan akun apapun, harap pikirkan dengan bijak")
    if (isIdSaved == false) {
      var a = await DeviceInfoPlugin().deviceInfo;
      var b = a.data;
      var c = '${b["deviceId"]}';
      await deviceData().edit(c);
    } else {
      log(deviceData.id);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 250, 255),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CircleAvatar(
              radius: _radiusAnimation.value,
              child: const Text(
                'Item\nWise',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            );
          },
        ),
      ),
    );
  }
}
