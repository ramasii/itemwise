// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:itemwise/allpackages.dart';
import 'package:flutter/widgets.dart';

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  TextEditingController kodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pass1Controller = TextEditingController();
  TextEditingController pass2Controller = TextEditingController();

  bool isCodeValid = false;
  bool isPasswordSame = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log("di lupa pass page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, "hehe");
            },
            icon: const Icon(Icons.arrow_back)),
        title: Text(AppLocalizations.of(context)!.forgetPassword),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                ),
                Text(
                  AppLocalizations.of(context)!.insertYourEmail,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  AppLocalizations.of(context)!.codeWillBeSentToEmail,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const Divider(
                  color: Colors.transparent,
                ),
                // jika isCodeValid maka tampilkan form password baru, jika tidak maka tampilkan email dan kode
                _crossFadeEmailToPassword(context),
                const Divider(
                  color: Colors.transparent,
                ),
                // TODO: buat tombol 'kembali' yang mengubah isCodeValid jadi false
                // di sebelahnya buat tombol 'ubah password' jika kedua password controller sama lalu ditekan maka akan mengubah password yang emailnya sama di database
                _kirimKodeAndLanjutkan(context)
              ],
            ),
          ),
        ),
      )),
    );
  }

  Row _kirimKodeAndLanjutkan(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _tombolKirimKode(context),
        _tombolLanjutkan(context),
      ],
    );
  }

  /// berisi AnimatedCrossFade, akan menampilkan [_newPasswordForm] atau [_emailAndCode] sesuai kondisi [isCodeValid]
  AnimatedCrossFade _crossFadeEmailToPassword(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: _newPasswordForm(context), // form password baru
        secondChild: _emailAndCode(context), // form email dan kode
        crossFadeState: isCodeValid
            ? CrossFadeState.showFirst // jika isCodeValid == true
            : CrossFadeState.showSecond, // jika isCodeValid == false
        duration: const Duration(milliseconds: 300));
  }

  Column _newPasswordForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: pass1Controller,
          decoration: InputDecoration(
              label: Text("Password baru"), icon: Icon(Icons.lock_outline)),
        ),
        TextFormField(
          controller: pass2Controller,
          decoration: InputDecoration(
              label: Text("Ulangi password"), icon: Icon(Icons.lock)),
          validator: (value) {
            if (value!.trim() != pass1Controller.text.trim()) {
              isPasswordSame = false;
              return "Password tidak sama";
            } else {
              isPasswordSame = true;
            }
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  TextButton _tombolLanjutkan(BuildContext context) {
    return TextButton(
        onPressed: () async {
          log("klik lanjutkan");

          String email = emailController.text.trim();
          String kode_s = kodeController.text.trim();

          // jika email dan kode_s tidak kosong
          if (email.isNotEmpty && kode_s.isNotEmpty) {
            // tampilkan loading
            _tampilkanLoading(context);

            // ambil respon ke API
            Response response =
                await lupaPassword().matchingKodeS(email, kode_s);

            // tutup loading
            Navigator.pop(context);

            // jika sukses
            if (response.statusCode == 200) {
              // jika ketemu
              if ((jsonDecode(response.body) as List).isNotEmpty) {
                // ubah response menjadi JSON/List
                List resBody = jsonDecode(response.body);

                // dapatkan waktu kode sementara ditambahkan
                DateTime waktuKodeS =
                    DateTime.parse(resBody[0]['added']).toLocal();

                // dapatkan waktu sekarang
                DateTime now = DateTime.now().toLocal();

                // hitung selisih
                Duration selisih = now.difference(waktuKodeS);

                log("now: $now - added: $waktuKodeS");
                log(selisih.inMinutes.toString());
                // jika selisih masih dibawah 5 menit (masih berlaku)
                if (selisih.inMinutes < 5) {
                  log("kode masih berlaku");
                  setState(() {
                    isCodeValid = true;
                  });
                }
                // jika tidak (expired)
                else {
                  log("kode sudah expired: ${selisih.inMinutes} menit");
                  _showInfoDialog(context, "Kode sudah tidak berlaku");
                }
              }
              // jika tidak ketemu
              else {
                log("kode tidak ketemu");
                _showInfoDialog(
                    context, "Kemungkinan kode salah atau sudah tidak berlaku");
              }
            } else {
              log("lupaPassPage ${response.statusCode}: ${response.body}");
              _showInfoDialog(context,
                  "Sepertinya terjadi kesalah di server, coba beberapa saat lagi");
            }
          }
        },
        child: Text(
          AppLocalizations.of(context)!.next,
        ));
  }

  Future<dynamic> _showInfoDialog(BuildContext context, String msg) {
    return showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
              content: Text(msg),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.ok))
              ],
            ));
  }

  TextButton _tombolKirimKode(BuildContext context) {
    return TextButton(
        onPressed: () async {
          log("klik kirim kode");
          if (emailController.text.trim().isNotEmpty) {
            // tampilkan loading
            _tampilkanLoading(context);

            Response response =
                await lupaPassword().create(emailController.text.trim());

            // tutup loading
            Navigator.pop(context);

            if (response.statusCode == 200) {
              log("kode sukses dibuat di database");
              showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text("Kode sudah dikirim"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context)!.ok))
                      ],
                    );
                  });
            } else {
              log("eror ${response.statusCode}: ${response.body}");
              // tampilkan popup dialog jika email tidak ditemukan
              showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text("E-mail tidak ditemukan"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context)!.ok))
                      ],
                    );
                  });
            }
          }
        },
        child: Text(AppLocalizations.of(context)!.sendCode,
            style: TextStyle(
                color: emailController.text.trim().isNotEmpty
                    ? Colors.blue
                    : Colors.grey)));
  }

  Future<dynamic> _tampilkanLoading(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
  }

  /// ini adalah TextFormField untuk email dan kode sementara
  Column _emailAndCode(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: emailController,
          onChanged: (value) => setState(() {
            print("emailcontroller changed");
          }),
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.email),
              icon: const Icon(Icons.mail)),
        ),
        TextFormField(
          controller: kodeController,
          onChanged: (value) => setState(() {
            print("kodeController changed");
          }),
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.tempCode),
              icon: const Icon(Icons.pin)),
        ),
      ],
    );
  }
}
