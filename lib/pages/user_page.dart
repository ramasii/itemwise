import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:itemwise/allpackages.dart';
import 'pages.dart';

class userPage extends StatefulWidget {
  const userPage({super.key});

  @override
  State<userPage> createState() => _userPageState();
}

class _userPageState extends State<userPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
        onPressed: () {
          // login
          if (userWise.isLoggedIn == false) {
            log("login");

            if (emailValid && passwordValid) {
              // buat id
              String email_user = emailController.text.trim();
              String namaEmail =
                  RegExp(r'^\w+(?=@)').firstMatch(email_user)![0]!;
              String id_user =
                  "${deviceData.id}${DateTime.now().millisecondsSinceEpoch}";

              // cek ke database apakah ada email yang cocok
              /* 
                    if(adaInternet){
                      cocokkan dengan database
                      if(emailAda){
                        if(passwordCocok){
                          login: ubah value dari class userWise
                        }else{
                          login gagal "password salah"
                        }
                      }else{
                        tambah ke database bahwa ini akun baru
                        login: ubah value dari class userWise
                      }
                    }
                    */
              // ubah nilai class user (ini jika 'tambah baru' atau 'login'), kalau 'login' ubah userWise berdasarkan data dari DB
              setState(() {
                userWise().edit(
                    username_user: namaEmail,
                    email_user: email_user,
                    password_user: passwordController.text.trim(),
                    id_user: id_user);
                userWise.isLoggedIn = true;
              });

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MyHomePage()), (route) {
              return true;
            });

              log("$id_user");
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
