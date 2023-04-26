import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          backgroundColor: Colors.grey.shade200,
          // appBar: AppBar(
          //   title: Text("Test"),
          // ),
          body: Center(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Container(
                  child: ElevatedButton(
                      onPressed: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.clear();
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => MainApp()));
                      },
                      child: Text('Logout')),
                )
              ],
            ),
          )),
    );
  }
}
