// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:itemwise/allpackages.dart';

class userPage extends StatefulWidget {
  const userPage({super.key});

  @override
  State<userPage> createState() => _userPageState();
}

class _userPageState extends State<userPage> {
  // TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final connection = InternetConnectionCheckerPlus.createInstance(
      addresses: [AddressCheckOptions(Uri.parse(apiAddress.address))]);

  bool emailValid = false;
  bool passwordValid = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    log("---\n${userWise.userData}\n${userWise.isLoggedIn}\n---");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userWise.isLoggedIn
            ? AppLocalizations.of(context)!.profile
            : AppLocalizations.of(context)!.login),
      ),
      body: SafeArea(
        child: _tampilanUser(),
      ),
    );
  }

  Widget _tampilanUser() {
    if (userWise.isLoggedIn) {
      emailController.text = userWise.userData["email_user"];
      passwordController.text = userWise.userData["password_user"];
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Container(
        //   height: MediaQuery.of(context).size.height * 0.30,
        // ),
        // jika belum login tampilkan intro
        if (userWise.isLoggedIn == false) _introWidget(),
        Divider(
          color: Colors.transparent,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child:
              _loginForm(AppLocalizations.of(context)!.email, emailController),
        ),
        _customSpace(25),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: _loginForm(
              AppLocalizations.of(context)!.password, passwordController),
        ),
        _customSpace(5),
        // tombol lupa password
        userWise.isLoggedIn
            ? Container()
            : ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Align(
                    alignment: Alignment.centerLeft, child: _tombolLupaPass()),
              ),
        _customSpace(25),
        Row(
          mainAxisAlignment: userWise.isLoggedIn
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceEvenly,
          children: [
            // jika sudah login maka tampilkan kosongan, jika belum login maka tampilkan tombol lewati
            // TODO : wajib login
            // userWise.isLoggedIn ? Container() : _tombolSkip(),

            // jika sudah login maka otomatis berubah jadi tombol logout, jika belum login maka otomatis menjadi tombol login
            _tombolLogInOut()
          ],
        )
      ]),
    );
  }

  Padding _introWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Hai, Selamat datang di\nItem Wise!",
            style: TextStyle(fontSize: 30),
          ),
          Divider(
            color: Colors.transparent,
          ),
          Text(
            "Silahkan buat akun atau masuk ke akun yang sudah ada",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// user akan diarahkan ke halaman lupa password
  TextButton _tombolLupaPass() {
    return TextButton(
        onPressed: () async {
          log("tekan lupa password");
          // beri await untuk menyederhanakan kode, karena nanti kembali ke sini lagi
          await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LupaPasswordPage()))
              .then((value) {
            log("dari halaman lupa password: $value");
          });
        },
        child: Text("${AppLocalizations.of(context)!.forgetPassword}?"));
  }

  Container _customSpace(double pixel) {
    return Container(
      height: pixel,
    );
  }

  /// jika sudah login maka otomatis berubah jadi tombol logout, jika belum login maka otomatis menjadi tombol login
  TextButton _tombolLogInOut() {
    return TextButton(
        onPressed: () async {
          // berikan loading
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) => Center(
                    child: CircularProgressIndicator(),
                  ));

          // login
          if (userWise.isLoggedIn == false) {
            log("login");

            if (emailValid && passwordValid) {
              // buat id
              String id_user =
                  "${deviceData.id}${DateTime.now().millisecondsSinceEpoch}";
              String email_user = emailController.text.trim();
              String password_user = passwordController.text.trim();
              String namaEmail =
                  RegExp(r'^\w+(?=@)').firstMatch(email_user)![0]!;

              // cek koneksi internet
              bool tekonekKah = await fungsies().isConnected();
              if (tekonekKah) {
                try {
                  // coba hubungkan dengan api
                  Response tryLogin = await userApiWise()
                      .readByEmail(email_user, password_user);
                  // ubah respon api ke json
                  Map respon = jsonDecode(tryLogin.body);

                  // pengondisian status respon
                  switch (tryLogin.statusCode) {
                    // login sukses: ubah data user di device berdasarkan respon
                    case 200:
                      log(tryLogin.body);
                      setState(() {
                        userWise().edit(
                            // username_user: respon['result']['username_user'],
                            email_user: respon['result']['email_user'],
                            password_user: respon['result']['password_user'],
                            id_user: respon['result']['id_user'],
                            role: respon['result']['role']);
                        userWise.isLoggedIn = true;
                      });

                      await authapi().auth(respon['result']['email_user'],
                          respon['result']['password_user']);
                      // tutup loading
                      Navigator.pop(context);

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MyHomePage()),
                          (route) {
                        return true;
                      });
                      break;
                    // password salah
                    case 406:
                      log("password salah");
                      // tutup loading
                      Navigator.pop(context);

                      // ignore: use_build_context_synchronously
                      showCupertinoDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => AlertDialog(
                                content: Text(AppLocalizations.of(context)!
                                    .wrongPassword),
                              ));
                      break;
                    // kalo user ga ada, maka tambahkan user
                    case 202:
                      log("user ga ada");

                      // TODO: info kalau email atau akun belum ada
                      bool? setujuRegister = await fungsies().konfirmasiDialog(
                          context,
                          judul: "Akun belum ditambahkan",
                          msg:
                              "Akun akan didaftarkan, pastikan data berikut benar\n \n📧: ${emailController.text.trim()}\n🔑: ${passwordController.text.trim()}\n \nEmail akan digunakan jika anda lupa password",
                          trueText: "Daftar",
                          trueColor: Colors.blue,
                          falseText: "Batal",
                          falseColor: Colors.grey);

                      // jika setuju register
                      if (setujuRegister == true) {
                        log("setuju register");
                        // fungsi ini sekaligus nambahin data user ke device
                        await userApiWise().create(
                            id_user: id_user,
                            // username_user: namaEmail,
                            email_user: emailController.text.trim(),
                            password_user: passwordController.text.trim());

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const MyHomePage()), (route) {
                          return true;
                        });
                      } else {
                        log("tidak register");
                        // tutup loading
                        Navigator.pop(context);
                      }

                      break;
                    default:
                      log('mungkin server eror: ${tryLogin.statusCode}');
                  }
                } catch (e) {
                  print(e);
                }
              } else {
                Navigator.pop(context);
                showCupertinoDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) {
                      return AlertDialog(
                        content: Text(AppLocalizations.of(context)!.noInternet),
                      );
                    });
              }
            }
            log("$emailValid,$passwordValid");
          }
          // logout
          else {
            log("logging-out");

            // tampilkan dialog konfirmasi logout
            bool? setujuLogout = await fungsies().konfirmasiDialog(context,
                msg: "Apakah anda yakin ingin logout?",
                trueText: "Logout",
                falseText: "Batal");

            if (setujuLogout == true) {
              setState(() {
                userWise().logout();
                emailController.clear();
                passwordController.clear();
              });
              log("logged-out");
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const userPage()), (route) {
                return false;
              });
            } else {
              // tutup loading
              Navigator.pop(context);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: userWise.isLoggedIn
                  ? Colors.red
                  : emailValid && passwordValid
                      ? Colors.blue
                      : Colors.grey[400],
              borderRadius: BorderRadius.circular(10)),
          child: userWise.isLoggedIn
              ? Text(AppLocalizations.of(context)!.logout,
                  style: const TextStyle(color: Colors.white))
              : Text(AppLocalizations.of(context)!.login,
                  style: const TextStyle(color: Colors.white)),
        ));
  }

  TextButton _tombolSkip() {
    return TextButton(
        onPressed: () {
          log("skip dulu");
          log("skip dulu");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                        title: "Item Wise",
                      )));
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
          child: Text(
            AppLocalizations.of(context)!.skip,
            style: const TextStyle(color: Colors.white),
          ),
        ));
  }

  TextFormField _loginForm(String label, TextEditingController controller) {
    bool isPass = controller == passwordController;
    return TextFormField(
      // textAlign: TextAlign.center,
      maxLines: 1,
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == "") {
          return AppLocalizations.of(context)!.required;
        }
        // cek password
        else if (controller == passwordController) {
          // password minimal 8 karakter
          if (passwordController.text.trim().length < 8) {
            return AppLocalizations.of(context)!.minimum8Characters;
          }
          // password tidak boleh lebih dari 50 karakter
          else if (passwordController.text.trim().length > 50) {
            return AppLocalizations.of(context)!.max50Characters;
          }
        }
        // cek email
        else if (controller == emailController) {
          String email_user = emailController.text.trim();
          // regex format email
          bool isValid =
              RegExp(r'[a-zA-Z0-9]+\@(gmail|yahoo)\.(com|co(\.\w(\w|\w\w|)|))$')
                  .hasMatch(email_user);
          // email harus cocok denga format email
          if (isValid == false) {
            return AppLocalizations.of(context)!.enterValidEmail;
          }
        }
      },
      onChanged: (value) {
        RegExp emailExp = RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$');
        // RegExp(r'[a-zA-Z0-9]+\@(gmail|yahoo)\.(com|co(\.\w(\w|\w\w|)|))$');
        // email
        if (controller == emailController) {
          switch (emailExp.hasMatch(value.trim())) {
            case true:
              setState(() {
                emailValid = true;
              });
              break;
            case false:
              setState(() {
                emailValid = false;
              });
              break;
            default:
          }
        }
        // password
        if (controller == passwordController) {
          // password minimal 8 karakter
          if (value.trim().length < 8) {
            setState(() {
              passwordValid = false;
            });
          }
          // password tidak boleh lebih dari 50 karakter
          else if (value.trim().length > 50) {
            setState(() {
              passwordValid = false;
            });
          }
          // password valid
          else {
            setState(() {
              passwordValid = true;
            });
          }
        }
      },
      obscureText: !showPassword && isPass && userWise.isLoggedIn == false,
      enabled: userWise.isLoggedIn == false,
      textInputAction: isPass ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
          suffixIcon: isPass && userWise.isLoggedIn == false
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off),
                  splashRadius: 25,
                )
              : null,
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          floatingLabelAlignment: FloatingLabelAlignment.center),
    );
  }
}
