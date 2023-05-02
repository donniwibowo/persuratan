import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persuratan/api/api_form.dart';
import 'package:persuratan/api/api_jenis_peminjaman.dart';
import 'package:persuratan/api/api_permohonan.dart';
import 'package:persuratan/home.dart';
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/jenis_peminjaman.dart';
import 'package:persuratan/model/permohonan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class DetailForm extends StatefulWidget {
  final String form_id;
  final String status;

  const DetailForm({super.key, required this.form_id, required this.status});

  @override
  State<DetailForm> createState() => _DetailFormState();
}

class _DetailFormState extends State<DetailForm> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  ApiPermohonan api_permohonan = ApiPermohonan();
  late Future<List<PermohonanModel>> detail_permohonan;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    detail_permohonan = api_permohonan.getDetailPermohonan(widget.form_id);
  }

  @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     scaffoldMessengerKey: _messangerKey,
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: Text('Detail Form (' + widget.status + ')'),
  //         leading: GestureDetector(
  //           child: Icon(
  //             Icons.arrow_back_ios,
  //           ),
  //           onTap: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //       ),
  //       backgroundColor: Colors.grey.shade200,
  //       body: Container(
  //           child: SfPdfViewer.network(
  //         'http://www.pdf995.com/samples/pdf.pdf',
  //         key: _pdfViewerKey,
  //       )),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Detail Form (' + widget.status + ')'),
            leading: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          backgroundColor: Colors.grey.shade200,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<PermohonanModel>>(
                    future: detail_permohonan,
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
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 20, right: 0, left: 0),
                              itemCount: api_data.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    padding: EdgeInsets.only(
                                        top: 10,
                                        left: 15,
                                        right: 15,
                                        bottom: 0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text(
                                                'NRP',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                            ),
                                            Container(
                                              child: Text(api_data[index].nrp,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Nama',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: Text(api_data[index].nama,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Universitas',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: Text(
                                                  api_data[index].universitas,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Perihal',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: Text(
                                                  api_data[index].perihal,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Tanggal Mulai',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: Text(
                                                  api_data[index].date_start,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Tanggal Berakhir',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: Text(
                                                  api_data[index].date_end,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Status',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  top: 3,
                                                  bottom: 3,
                                                  right: 10),
                                              child: Text(
                                                  api_data[index].status,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Tanggal Dibuat',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: Text(
                                                  api_data[index].created_on,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Tanggal Diubah',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: Text(
                                                  api_data[index].updated_on,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ));
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
                  Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade400))),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                          padding: EdgeInsets.all(20),
                          height: 500,
                          child: SfPdfViewer.network(
                            'https://dms.tigajayabahankue.com/uploads/documents/11711734.pdf',
                            key: _pdfViewerKey,
                          )),
                    ],
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                        onPressed: () {}, child: Text('Edit Form')),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {},
                              child: Text('Terima')),
                        )),
                        Expanded(
                            child: Container(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {},
                              child: Text('Tolak')),
                        ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          )),
    );
  }
}
