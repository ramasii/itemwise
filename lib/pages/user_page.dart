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
        title: Text(userWise.isLoggedIn ? "Profil" : "Login"),
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
          child: _loginForm("E-mail", emailController),
        ),
        Container(
          height: 20,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: _loginForm("Kata sandi", passwordController),
        ),
        Container(
          height: 25,
        ),
        Row(
          mainAxisAlignment: userWise.isLoggedIn
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceEvenly,
          children: [
            userWise.isLoggedIn
                ? Container()
                : TextButton(
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
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text(
                        "skip dulu",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
            TextButton(
                onPressed: () {
                  // login
                  if (userWise.isLoggedIn == false) {
                    log("login");

                    // cek email
                    String email_user = emailController.text.trim();
                    bool emailValid = RegExp(
                            r'[a-zA-Z0-9]+\@(gmail|yahoo)\.(com|co(\.\w(\w|\w\w|)|))$')
                        .hasMatch(email_user);
                    // cek password
                    String password_user = passwordController.text.trim();
                    bool passwordValid =
                        password_user != "" && password_user.length >= 8;

                    if (emailValid && passwordValid) {
                      // buat id
                      String namaEmail =
                          RegExp(r'^\w+(?=@)').firstMatch(email_user)![0]!;
                      String id_user =
                          "${DateTime.now().millisecondsSinceEpoch}$namaEmail";

                      // cek ke database apakah ada email yang cocok
                      // jika iya maka cocokkan password
                      // jika tidak maka tambahkan baru
                      // ubah nilai class user (ini jika 'tambah baru' atau 'login')
                      setState(() {
                        userWise().edit(
                            username_user: namaEmail,
                            email_user: email_user,
                            password_user: password_user,
                            id_user: id_user);
                        userWise.isLoggedIn = true;
                      });

                      log("$id_user");
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage(
                                title: "Item Wise",
                              )),
                    );

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
                    log("logged-out");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: userWise.isLoggedIn ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: userWise.isLoggedIn
                      ? const Text("logout",
                          style: TextStyle(color: Colors.white))
                      : const Text("login",
                          style: TextStyle(color: Colors.white)),
                ))
          ],
        )
      ]),
    );
  }

  Widget _tampilanLogin() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.30,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: _loginForm("E-mail", emailController),
        ),
        Container(
          height: 20,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: _loginForm("Kata sandi", passwordController),
        ),
        Container(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {
                  log("skip dulu");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage(
                              title: "Item Wise",
                            )),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text(
                    "skip dulu",
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            TextButton(
                onPressed: () {
                  log("login");

                  // cek email
                  String email_user = emailController.text.trim();
                  bool emailValid = RegExp(
                          r'[a-zA-Z0-9]+\@(gmail|yahoo)\.(com|co(\.\w(\w|\w\w|)|))$')
                      .hasMatch(email_user);
                  // cek password
                  String password_user = passwordController.text.trim();
                  bool passwordValid =
                      password_user != "" && password_user.length >= 8;

                  if (emailValid && passwordValid) {
                    // buat id
                    String namaEmail =
                        RegExp(r'^\w+(?=@)').firstMatch(email_user)![0]!;
                    String id_user =
                        "${DateTime.now().millisecondsSinceEpoch}$namaEmail";

                    // cek ke database apakah ada email yang cocok
                    // jika iya maka cocokkan password
                    // jika tidak maka tambahkan baru
                    // ubah nilai class user (ini jika 'tambah baru' atau 'login')
                    setState(() {
                      userWise().edit(
                          username_user: namaEmail,
                          email_user: email_user,
                          password_user: password_user,
                          id_user: id_user);
                      userWise.isLoggedIn = true;
                    });

                    log("$id_user");
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage(
                              title: "Item Wise",
                            )),
                  );

                  log("$emailValid,$passwordValid");
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text("login",
                      style: TextStyle(color: Colors.white)),
                ))
          ],
        )
      ]),
    );
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
          return "Wajib diisi";
        } else if (controller == passwordController &&
            passwordController.text.trim().length <= 8) {
          return "Minimal 8 karakter";
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
