import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:persuratan/api/api_form.dart';
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:persuratan/model/form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RequestForm extends StatefulWidget {
  final String form_id;
  final String form;

  const RequestForm({super.key, required this.form_id, required this.form});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  late SharedPreferences sharedPreferences;
  TextEditingController date_start = TextEditingController();
  TextEditingController date_end = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Pemohonan ' + widget.form),
            // backgroundColor: Colors.green,
            leading: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                // color: Colors.black,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          backgroundColor: Colors.grey.shade200,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                // Container(
                //   padding: EdgeInsets.only(left: 20, right: 20),
                //   margin: EdgeInsets.only(bottom: 10),
                //   child: Row(
                //     children: [
                //       Text(
                //         "Form : ",
                //         style: TextStyle(
                //             fontWeight: FontWeight.bold, fontSize: 20),
                //       ),
                //       Text(
                //         widget.form,
                //         style: TextStyle(
                //             fontWeight: FontWeight.bold, fontSize: 20),
                //       )
                //     ],
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    // controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Perihal',
                      // suffixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    // controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'NRP',
                      // suffixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    // controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Nama',
                      // suffixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    // controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Universitas',
                      // suffixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    // controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Keterangan',
                      // suffixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    margin: EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller:
                          date_start, //editing controller of this TextField
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Tanggal Peminjaman" //label text of field
                          ),
                      readOnly:
                          true, //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(
                                2000), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            date_start.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    )),
                Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    margin: EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller:
                          date_end, //editing controller of this TextField
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Tanggal Berakhir" //label text of field
                          ),
                      readOnly:
                          true, //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(
                                2000), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            date_end.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    )),

                Container(
                    margin: EdgeInsets.only(top: 40),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      elevation: 10,
                      clipBehavior: Clip.antiAlias,
                      child: MaterialButton(
                        minWidth: 200,
                        height: 50,
                        child: Text(
                          'KIRIM',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Color(0xff132137),
                        onPressed: () async {},
                      ),
                    ))
              ],
            ),
          )),
    );
  }
}
