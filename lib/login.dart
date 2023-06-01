import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:persuratan/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool _obscureText1 = true;

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  isLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_token = prefs.getString("user_token");
    if (user_token != null) {
      var api_url =
          'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/user/islogin/' +
              user_token;
      var response = await http.get(Uri.parse(api_url));
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] == 0) {
        prefs.clear();
        prefs.commit();
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Home()),
            (Route<dynamic> route) => false);
      }
    }
  }

  void _togglevisibility() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                        'DMS | SUREL',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
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
                  margin: EdgeInsets.only(bottom: 50),
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
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          color: Color(0xff132137),
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            Map data = {
                              'email': emailController.text,
                              'password': passwordController.text
                            };
                            var jsonResponse = null;
                            var api_url =
                                'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/user/login';
                            var response =
                                await http.post(Uri.parse(api_url), body: data);
                            jsonResponse = json.decode(response.body);

                            if (response.statusCode == 200) {
                              if (jsonResponse != null) {
                                prefs.setString("user_token",
                                    jsonResponse['data']['user_token']);
                                prefs.setString(
                                    "email", jsonResponse['data']['email']);
                                prefs.setString("fullname",
                                    jsonResponse['data']['fullname']);
                                prefs.setString(
                                    "phone", jsonResponse['data']['phone']);
                                prefs.setString(
                                    "user_id", jsonResponse['data']['user_id']);
                                prefs.setString("is_superadmin",
                                    jsonResponse['data']['is_superadmin']);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Home()));
                              }
                            } else {
                              const SnackBarMsg = SnackBar(
                                content:
                                    Text('Email atau password tidak cocok'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBarMsg);
                            }
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
    );
  }
}
