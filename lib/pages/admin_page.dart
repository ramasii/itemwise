import 'package:flutter/material.dart';
import 'package:itemwise/pages/home_page.dart';
import '../allpackages.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String tableState = "account";
  TextEditingController idUser = TextEditingController();
  TextEditingController emailUser = TextEditingController();
  TextEditingController usernameUser = TextEditingController();
  TextEditingController passwordUser = TextEditingController();
  String roleState = "";
  List role = ["user", "admin"];
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selaraskanData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.adminPanel)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stateButton(Icons.account_circle, "account"),
                _stateButton(Icons.inventory_2_rounded, "inventory"),
                _stateButton(Icons.apps_rounded, "item"),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: loading
                  ? Container(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()))
                  : _controllUser(context),
            )
          ],
        ),
      ),
    );
  }

  Column _controllUser(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(adminAccess.userList.length, (index) {
        Map user = adminAccess.userList[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Column(
            children: [
              ListTile(
                leading:
                    user['photo_user'] == "null" || user['photo_user'] == null
                        ? Icon(Icons.person_2_rounded)
                        : Container(
                            height: 70,
                            width: 70,
                            child: Image.memory(Uint8List.fromList(
                                base64.decode(user['photo_user']))),
                          ),
                title: Text(
                  user['email_user'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "${AppLocalizations.of(context)!.password}: ${user['password_user']}",
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  setState(() {
                    roleState = user['role'];
                    idUser.text = user['id_user'];
                    emailUser.text = user['email_user'];
                    usernameUser.text = user['username_user'];
                    passwordUser.text = user['password_user'];
                  });
                  _viewUser(context, user);
                },
              ),
              Divider(
                indent: 50,
                endIndent: 50,
              )
            ],
          ),
        );
      }),
    );
  }

  Future<dynamic> _viewUser(BuildContext context, Map<dynamic, dynamic> user) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  user['photo_user'] != "null"
                      // render foto
                      ? Container(
                          height: 100,
                          width: 100,
                          child: ClipOval(
                            child: Image.memory(Uint8List.fromList(
                                base64.decode(user['photo_user']))),
                          ),
                        )
                      // tampilkan tombol tambah foto
                      : Container(
                          height: 100,
                          width: 100,
                          child: ClipOval(
                              child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              log("add user photo");
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      content: Text("TAMBAH FOTO USER"),
                                    );
                                  });
                            },
                            child: Container(
                              decoration:
                                  BoxDecoration(color: Colors.grey[300]),
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          )),
                        ),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo(user, "id_user", ctrler: idUser, enable: false),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo(user, "email_user", ctrler: emailUser),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo(user, "username_user", ctrler: usernameUser),
                  Container(
                    height: 20,
                  ),
                  _fieldInfo(user, "password_user", ctrler: passwordUser),
                  Container(
                    height: 20,
                  ),
                  _roleDropDown(),
                  Container(
                    height: 20,
                  ),
                  TextButton(
                      onPressed: () async {
                        log("update");
                        Navigator.pop(context);
                        //loading
                        showDialog(
                            context: context,
                            builder: (_) => Center(
                                  child: CircularProgressIndicator(),
                                ));
                        await userApiWise().update(
                          id_user: user['id_user'],
                          username_user: usernameUser.text,
                          email_user: emailUser.text,
                          password_user: passwordUser.text,
                          photo_user: user['photo_user'],
                          role: roleState,
                        );
                        // selaraskan data dengan database
                        await selaraskanData();
                        //tutup loading
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(AppLocalizations.of(context)!.update),
                      ))
                ],
              ),
            ),
          );
        });
  }

  StatefulBuilder _roleDropDown() {
    return StatefulBuilder(builder: ((context, setState) {
      return DropdownButton(
        borderRadius: BorderRadius.circular(10),
        onChanged: (value) {
          log("role berubah");
          setState(() {
            log("$value");
            roleState = (value) as String;
          });
        },
        value: roleState,
        items: List.generate(
            role.length,
            (index) => DropdownMenuItem(
                  value: role[index],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(role[index]),
                  ),
                )),
      );
    }));
  }

  TextFormField _fieldInfo(Map<dynamic, dynamic> row, String field,
      {bool enable = true, TextEditingController? ctrler}) {
    return TextFormField(
      enabled: enable,
      controller: ctrler,
      maxLines: enable ? 1 : null,
      decoration: InputDecoration(
          labelText: "${field}${enable ? '' : '🔒'}",
          labelStyle: TextStyle(color: enable ? Colors.blue : Colors.red),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2))),
    );
  }

  // ----------------------------------------------------------------------

  Widget _stateButton(IconData icon, String state) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: tableState == state ? Colors.white : Colors.transparent),
      child: AnimatedScale(
        scale: tableState == state ? 1.3 : 1,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: IconButton(
            onPressed: () {
              setState(() {
                switch (state) {
                  case "account":
                    log("set state to account controll");
                    tableState = "account";
                    break;
                  case "inventory":
                    log("set state to inventory controll");
                    tableState = "inventory";
                    break;
                  case "item":
                    log("set state to item controll");
                    tableState = "item";
                    break;
                  default:
                }
              });
            },
            icon: Icon(icon)),
      ),
    );
  }

  // selaraskan data dari database
  Future selaraskanData() async {
    if (await isConnected()) {
      // ambil semua data dari database
      await userApiWise().readAll();
      await inventoryApiWise().readAll();
      await itemApiWise().readAll();
      // simpan list
      await adminAccess().saveList();
      // tutup loading
      setState(() {
        loading = false;
      });
    } else {
      await adminAccess().readList();
      // tutup loading
      setState(() {
        loading = false;
      });
    }
  }

  // cek koneksi internet
  Future<bool> isConnected() async {
    var a = await InternetConnectionCheckerPlus.createInstance(
        addresses: [AddressCheckOptions(Uri.parse(anu.emm))]);
    var internet = await a.connectionStatus;
    if (internet == InternetConnectionStatus.connected) {
      print('Tidak terhubung ke internet');
      return false;
    } else {
      print('Terhubung ke internet');
      return true;
    }
  }
}
