import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persuratan/api/api_form.dart';
import 'package:persuratan/api/api_permohonan.dart';
import 'package:persuratan/detail_form.dart';
import 'package:persuratan/home.dart';
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/permohonan.dart';
import 'package:persuratan/request_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class NotificatioPage extends StatefulWidget {
  const NotificatioPage({super.key});

  @override
  State<NotificatioPage> createState() => _NotificationState();
}

class _NotificationState extends State<NotificatioPage> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  ApiPermohonan api_permohonan = ApiPermohonan();
  late Future<List<PermohonanModel>> listPermohonan;

  @override
  void initState() {
    super.initState();

    setState(() {
      listPermohonan = api_permohonan.getUnreadPermohonan();
    });
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Notifikasi'),
            leading: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Home()));
              },
            ),
          ),
          backgroundColor: Colors.grey.shade200,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  FutureBuilder<List<PermohonanModel>>(
                    future: listPermohonan,
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Container(
                          padding: EdgeInsets.only(left: 18, top: 15),
                          child: Text("Please wait.."),
                        );
                      }
                      if (snapshot.hasError) {
                        return Container(
                          padding: EdgeInsets.only(left: 18, top: 15),
                          child: Text("Failed to load data"),
                        );
                      }

                      if (snapshot.hasData) {
                        List<PermohonanModel>? api_data = snapshot.data!;
                        if (api_data.length > 0) {
                          return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  top: 0, bottom: 30, right: 0, left: 0),
                              itemCount: api_data.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => DetailForm(
                                                  permohonan_id: api_data[index]
                                                      .permohonan_id,
                                                  status:
                                                      api_data[index].status,
                                                  has_edit_access:
                                                      api_data[index]
                                                          .has_edit_access,
                                                  markasread: "1",
                                                )));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 10,
                                        left: 15,
                                        right: 15,
                                        bottom: 0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade400)),
                                        ),
                                        padding: EdgeInsets.only(
                                            top: 10,
                                            left: 10,
                                            bottom: 10,
                                            right: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: c_width,
                                                  child: Text(
                                                    api_data[index].perihal,
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Pemohon: ",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color:
                                                          Colors.grey.shade500),
                                                ),
                                                Text(api_data[index].created_by,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    )),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "(" +
                                                      api_data[index]
                                                          .date_start +
                                                      " - " +
                                                      api_data[index].date_end +
                                                      ")",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                )
                                              ],
                                            )
                                          ],
                                        )),
                                  ),
                                );
                              });
                        } else {
                          return Container(
                            padding: EdgeInsets.only(left: 18, top: 15),
                            child: Text("Tidak ada data"),
                          );
                        }
                      }
                      return Container(
                        padding: EdgeInsets.only(left: 18, top: 15),
                        child: Text("Tidak ada data"),
                      );
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
