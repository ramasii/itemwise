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
  bool isCodeValid = false;

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
                _emailAndCode(context),
                const Divider(
                  color: Colors.transparent,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tombolKirimKode(context),
                    // TODO: buat fungsi untuk lanjutkan setelah mengisi kode sementara, kode yang ada di textForm akan dicocokkan dengan database
                    TextButton(
                        onPressed: () {
                          log("klik lanjutkan");
                          if (emailController.text.trim().isNotEmpty &&
                              kodeController.text.trim().isNotEmpty) {}
                        },
                        child: Text(AppLocalizations.of(context)!.next)),
                  ],
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  TextButton _tombolKirimKode(BuildContext context) {
    return TextButton(
        onPressed: () async {
          log("klik kirim kode");
          if (emailController.text.trim().isNotEmpty) {
            // tampilkan loading
            showCupertinoDialog(
                context: context,
                builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ));

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
        child: Text(AppLocalizations.of(context)!.sendCode));
  }

  Column _emailAndCode(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.email),
              icon: const Icon(Icons.mail)),
        ),
        TextFormField(
          controller: kodeController,
          decoration: InputDecoration(
              label: Text(AppLocalizations.of(context)!.tempCode),
              icon: const Icon(Icons.lock)),
        ),
      ],
    );
  }
}
