import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:persuratan/api/api_form.dart';
import 'package:persuratan/api/api_jenis_peminjaman.dart';
import 'package:persuratan/detail_form.dart';
import 'package:persuratan/home.dart';
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/jenis_peminjaman.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RequestForm extends StatefulWidget {
  final String permohonan_id;
  final String form_id;
  final String form;

  const RequestForm(
      {super.key,
      required this.form_id,
      required this.form,
      this.permohonan_id = "0"});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  TextEditingController date_start = TextEditingController();
  TextEditingController date_end = TextEditingController();

  TextEditingController input_perihal = TextEditingController();
  TextEditingController input_nrp = TextEditingController();
  TextEditingController input_nama = TextEditingController();
  TextEditingController input_universitas = TextEditingController();
  TextEditingController input_keterangan = TextEditingController();

  late String selectedJenisPeminjaman;
  List<DropdownMenuItem<String>> jenisPeminjamanList = [];
  ApiJenisPeminjaman api_jenis_peminjaman = ApiJenisPeminjaman();
  bool isFormPeminjaman = false;

  @override
  void initState() {
    super.initState();
    if (widget.form == 'Peminjaman') {
      isFormPeminjaman = true;
    } else {
      selectedJenisPeminjaman = "0";
    }

    getDataPermohonan(widget.permohonan_id);
  }

  getDataPermohonan(String _id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';
    var api_url =
        'https://192.168.1.66/leap_integra/leap_integra/master/dms/api/form/getdetailpermohonanforedit?user_token=' +
            user_token +
            '&permohonan_id=' +
            _id;
    var response = await http.get(Uri.parse(api_url));
    var jsonResponse = json.decode(response.body);

    setState(() {
      input_perihal.text = jsonResponse['data']['perihal'];
      input_nrp.text = jsonResponse['data']['nrp'];
      input_nama.text = jsonResponse['data']['nama'];
      input_universitas.text = jsonResponse['data']['universitas'];
      input_keterangan.text = jsonResponse['data']['keterangan'];
      date_start.text = jsonResponse['data']['date_start'];
      date_end.text = jsonResponse['data']['date_end'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Permohonan (' + widget.form + ')'),
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
                Visibility(
                  visible: isFormPeminjaman,
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    margin: EdgeInsets.only(bottom: 10),
                    child: FutureBuilder<List<JenisPeminjamanModel>>(
                        future: api_jenis_peminjaman.getJenisPeminjaman(),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasData) {
                            List<JenisPeminjamanModel>? api_data =
                                snapshot.data!;

                            jenisPeminjamanList = api_data
                                .map((data) => DropdownMenuItem<String>(
                                      value: data.jenis_peminjaman_id,
                                      child: Text(data.jenis_peminjaman),
                                    ))
                                .toList();

                            if (api_data.length < 1) {
                              return Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  "Tidak ada data",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600),
                                ),
                              );
                            } else {
                              selectedJenisPeminjaman =
                                  api_data[0].jenis_peminjaman_id;
                            }

                            return DecoratedBox(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.grey),
                                  ),
                                ), //border of dropdown button

                                child: Padding(
                                    padding: EdgeInsets.only(left: 0, right: 0),
                                    child: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter dropDownState) {
                                      return DropdownButton(
                                        value: selectedJenisPeminjaman,
                                        items: jenisPeminjamanList,
                                        onChanged: (String? newValue) {
                                          dropDownState(() {
                                            dropDownState(() {
                                              selectedJenisPeminjaman =
                                                  newValue!;
                                            });
                                          });
                                        },
                                        icon: const Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Icon(
                                              Icons.arrow_circle_down_sharp,
                                              color: Colors.black,
                                            )),
                                        iconEnabledColor:
                                            Colors.white, //Icon color
                                        style: const TextStyle(
                                            color: Colors.black, //Font color
                                            fontSize:
                                                16 //font size on dropdown button
                                            ),

                                        underline:
                                            Container(), //remove underline
                                        isExpanded:
                                            true, //make true to make width 100%
                                      );
                                    })));
                          } else {}
                          return Container();
                        }),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: input_perihal,
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
                    controller: input_nrp,
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
                    controller: input_nama,
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
                    controller: input_universitas,
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
                    controller: input_keterangan,
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
                          labelText: "Tanggal Mulai" //label text of field
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
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          var user_token = prefs.getString("user_token");

                          Map data = {
                            'permohonan_id': widget.permohonan_id,
                            'form_id': widget.form_id,
                            'jenis_peminjaman_id': selectedJenisPeminjaman,
                            'perihal': input_perihal.text,
                            'nrp': input_nrp.text,
                            'nama': input_nama.text,
                            'universitas': input_universitas.text,
                            'keterangan': input_keterangan.text,
                            'date_start': date_start.text,
                            'date_end': date_end.text,
                            'status': 'draft'
                          };

                          var jsonResponse = null;
                          String api_url =
                              "https://192.168.1.66/leap_integra/leap_integra/master/dms/api/form/createpermohonan?user_token=" +
                                  user_token!;

                          var response =
                              await http.post(Uri.parse(api_url), body: data);
                          jsonResponse = json.decode(response.body);

                          if (jsonResponse['status'] == 200) {
                            if (widget.permohonan_id == "0") {
                              final snackbar = SnackBar(
                                  content: Text(
                                      "Surat Permohonan telah berhasil dibuat"));
                              _messangerKey.currentState!
                                  .showSnackBar(snackbar);
                            } else {
                              final snackbar = SnackBar(
                                  content: Text(
                                      "Surat Permohonan telah berhasil diubah"));
                              _messangerKey.currentState!
                                  .showSnackBar(snackbar);
                            }

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DetailForm(
                                    permohonan_id: jsonResponse['data']
                                        ['permohonan_id'],
                                    status: jsonResponse['data']['status'])));
                          } else {
                            print(jsonResponse);
                            final snackbar =
                                SnackBar(content: Text("Failed to load data"));
                            _messangerKey.currentState!.showSnackBar(snackbar);
                          }
                        },
                      ),
                    ))
              ],
            ),
          )),
    );
  }
}
