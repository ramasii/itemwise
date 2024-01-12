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
      addresses: [AddressCheckOptions(Uri.parse(anu.emm))]);

  bool emailValid = false;
  bool passwordValid = false;

  @override
  void initState() {
    // TODO: implement initState
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
        child: SingleChildScrollView(
          child: _tampilanUser(),
        ),
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
      child: Column(children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.30,
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
        _customSpace(25),
        Row(
          mainAxisAlignment: userWise.isLoggedIn
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceEvenly,
          children: [
            userWise.isLoggedIn ? Container() : _tombolSkip(),
            _tombolLogInOut()
          ],
        )
      ]),
    );
  }

  Container _customSpace(double pixel) {
    return Container(
      height: pixel,
    );
  }

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
                            photo_user: respon['result']['photo_user'],
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
                      // fungsi ini sekaligus nambahin data user ke device
                      await userApiWise().create(
                          id_user: id_user,
                          // username_user: namaEmail,
                          email_user: email_user,
                          password_user: password_user);

                      // tutup loading
                      Navigator.pop(context);

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MyHomePage()),
                          (route) {
                        return true;
                      });
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
            setState(() {
              userWise().logout();
              emailController.clear();
              passwordController.clear();
            });
            // tutup loading
            Navigator.pop(context);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MyHomePage()), (route) {
              return true;
            });
            log("logged-out");
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
      textAlign: TextAlign.center,
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
        RegExp emailExp =
            RegExp(r'[a-zA-Z0-9]+\@(gmail|yahoo)\.(com|co(\.\w(\w|\w\w|)|))$');
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
      obscureText: isPass && userWise.isLoggedIn == false,
      enabled: userWise.isLoggedIn == false,
      textInputAction: isPass ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          floatingLabelAlignment: FloatingLabelAlignment.center),
    );
  }
}
