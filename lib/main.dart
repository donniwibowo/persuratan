import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainApp createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  late SharedPreferences sharedPreferences;

  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool _obscureText1 = true;

  void _togglevisibility() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final key = GlobalObjectKey<ExpandableFabState>(context);
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Center(
          child: Wrap(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        children: [
                          Container(
                              child: Text(
                            'Hello',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 40),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      margin: EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          suffixIcon: Icon(Icons.email),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      margin: EdgeInsets.only(bottom: 20),
                      child: TextField(
                        obscureText: _obscureText1,
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _togglevisibility();
                            },
                            child: Icon(
                              _obscureText1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            elevation: 10,
                            clipBehavior: Clip.antiAlias,
                            child: MaterialButton(
                              minWidth: 200,
                              height: 50,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              color: Color(0xff132137),
                              onPressed: () {
                                doLogin(emailController.text,
                                    passwordController.text);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  doLogin(String _email, _password) async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': _email, 'password': _password};
    var jsonResponse = null;
    var api_url =
        'https://192.168.1.66/leap_integra/leap_integra/master/dms/api/user/login';
    var response = await http.post(Uri.parse(api_url), body: data);
    jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse != null) {
        sharedPreferences.setString("user_token", jsonResponse['user_token']);
        sharedPreferences.setString("email", jsonResponse['data']['email']);
        sharedPreferences.setString(
            "fullname", jsonResponse['data']['fullname']);
        sharedPreferences.setString("phone", jsonResponse['data']['phone']);
        sharedPreferences.setString("user_id", jsonResponse['data']['user_id']);

        const SnackBarMsg = SnackBar(
          content: Text('Login berhasil'),
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBarMsg);
      }
    } else {
      _messangerKey.currentState!.showSnackBar(
          SnackBar(content: Text('Email atau password tidak cocok')));
    }
  }
}
