import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:persuratan/api/api_form.dart';
import 'package:persuratan/api/api_jenis_peminjaman.dart';
import 'package:persuratan/api/api_permohonan.dart';
import 'package:persuratan/home.dart';
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/jenis_peminjaman.dart';
import 'package:persuratan/model/permohonan.dart';
import 'package:persuratan/request_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DetailForm extends StatefulWidget {
  final String permohonan_id;
  final String status;
  final String has_edit_access;
  final String markasread;

  const DetailForm(
      {super.key,
      required this.permohonan_id,
      required this.status,
      this.has_edit_access = "0",
      this.markasread = "0"});

  @override
  State<DetailForm> createState() => _DetailFormState();
}

class _DetailFormState extends State<DetailForm> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  ApiPermohonan api_permohonan = ApiPermohonan();
  late Future<List<PermohonanModel>> detail_permohonan;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  String is_superadmin = "0";
  Color status_label_color = Colors.blue;
  Color status_text_color = Colors.white;
  late String current_status;
  TextEditingController input_alasan = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkIsSuperadmin();

    detail_permohonan = api_permohonan.getDetailPermohonan(
        widget.permohonan_id, widget.markasread);
    current_status = widget.status;
  }

  checkIsSuperadmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      is_superadmin = prefs.getString('is_superadmin') ?? "0";
    });
  }

  reloadData() {
    setState(() {
      detail_permohonan = api_permohonan.getDetailPermohonan(
          widget.permohonan_id, widget.markasread);
    });
  }

  Future<File> getLocalDirectory(String _permohonan_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';
    var api_url =
        'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getpdffilename/' +
            user_token +
            '/' +
            _permohonan_id;

    var response = await http.get(Uri.parse(api_url));
    var jsonResponse = json.decode(response.body);
    String pdf_filename = 'test_pdf3.pdf';
    if (jsonResponse['data'] != null) {
      pdf_filename = jsonResponse['data'];
    }

    final directory = await getExternalStorageDirectory();
    final file = File("${directory?.path}/" + pdf_filename);
    return file;
  }

  Future<String> getPDF(String _permohonan_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';
    var api_url =
        'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getpdffilename/' +
            user_token +
            '/' +
            _permohonan_id;

    var response = await http.get(Uri.parse(api_url));
    var jsonResponse = json.decode(response.body);
    String pdf_filename = '';
    if (jsonResponse['data'] != null) {
      pdf_filename =
          'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/documents/' +
              jsonResponse['data'];
    }

    return pdf_filename;
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.5;
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Detail Form (' + current_status + ')'),
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
                                if (api_data[index].status == 'Pending') {
                                  status_label_color = Colors.yellow;
                                  status_text_color = Colors.black;
                                } else if (api_data[index].status ==
                                    'Approved') {
                                  status_label_color = Colors.green;
                                  status_text_color = Colors.white;
                                } else if (api_data[index].status ==
                                    'Rejected') {
                                  status_label_color = Colors.red;
                                  status_text_color = Colors.white;
                                } else {
                                  status_label_color = Colors.blue;
                                  status_text_color = Colors.white;
                                }

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
                                              width: c_width,
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
                                              width: c_width,
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
                                              width: c_width,
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
                                              width: c_width,
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
                                          height: 4,
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
                                                  color: status_label_color,
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
                                                      color:
                                                          status_text_color)),
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
                                              child: Text('Approval By',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              width: c_width,
                                              child: Text(
                                                  api_data[index].response_by,
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 6,
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
                                        // SizedBox(
                                        //   height: 4,
                                        // ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Text('Lampiran',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ),
                                            Container(
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                    padding: EdgeInsets.only(
                                                        left: 0)),
                                                onPressed: () {
                                                  FileDownloader.downloadFile(
                                                      url:
                                                          'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/documents/' +
                                                              api_data[index]
                                                                  .lampiran,
                                                      // url:
                                                      //     'https://github.com/c14190074/leap_integra/blob/main/master/dms/uploads/documents/FilePDF.pdf',
                                                      onProgress:
                                                          (name, progress) {
                                                        print(progress);
                                                        final snackbar = SnackBar(
                                                            content: Text(
                                                                "Downloading..."));
                                                        _messangerKey
                                                            .currentState!
                                                            .showSnackBar(
                                                                snackbar);
                                                      },
                                                      onDownloadCompleted:
                                                          (value) {
                                                        print("Downloaded!");
                                                        final snackbar = SnackBar(
                                                            content: Text(
                                                                "Dokumen berhasil didownload"));
                                                        _messangerKey
                                                            .currentState!
                                                            .showSnackBar(
                                                                snackbar);
                                                      });
                                                },
                                                child: Text(
                                                    api_data[index].lampiran ==
                                                            ""
                                                        ? "-"
                                                        : api_data[index]
                                                            .lampiran,
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ));
                              });
                        } else {
                          return Container(
                            padding: EdgeInsets.only(left: 18, top: 15),
                            child: Text(widget.permohonan_id),
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
                  Container(
                    child: FutureBuilder(
                        future: getPDF(widget.permohonan_id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            String pdf_file = snapshot.data as String;
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 10,
                              ),
                              child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue),
                                  onPressed: () {
                                    FileDownloader.downloadFile(
                                        url: pdf_file,
                                        // url:
                                        //     'https://github.com/c14190074/leap_integra/blob/main/master/dms/uploads/documents/FilePDF.pdf',
                                        onProgress: (name, progress) {
                                          print(progress);
                                          final snackbar = SnackBar(
                                              content: Text("Downloading..."));
                                          _messangerKey.currentState!
                                              .showSnackBar(snackbar);
                                        },
                                        onDownloadCompleted: (value) {
                                          print("Downloaded!");
                                          final snackbar = SnackBar(
                                              content: Text(
                                                  "Dokumen berhasil didownload"));
                                          _messangerKey.currentState!
                                              .showSnackBar(snackbar);
                                        });
                                  },
                                  icon: Icon(Icons.download),
                                  label: Text("Unduh Dokumen")),
                            );
                          }

                          return Container();
                        }),
                  ),

                  Stack(
                    children: [
                      FutureBuilder(
                          future: getPDF(widget.permohonan_id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              String pdf_file = snapshot.data as String;
                              if (pdf_file != '') {
                                print(pdf_file);
                                return Container(
                                    padding: EdgeInsets.all(20),
                                    height: 500,
                                    child: SfPdfViewer.network(
                                      pdf_file,
                                      key: _pdfViewerKey,
                                    ));
                              } else {
                                return Container();
                              }
                            }

                            return Container();
                          })
                    ],
                  ),
                  // Stack(
                  //   children: [
                  //     FutureBuilder(
                  //         future: getLocalDirectory(widget.permohonan_id),
                  //         builder: (context, snapshot) {
                  //           if (snapshot.hasData) {
                  //             final pdf_file = snapshot.data as File;
                  //             return Container(
                  //                 padding: EdgeInsets.all(20),
                  //                 height: 500,
                  //                 child: SfPdfViewer.file(
                  //                   pdf_file,
                  //                   key: _pdfViewerKey,
                  //                 ));
                  //           }

                  //           return Container();
                  //         })
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Stack(
                  //   children: [
                  //     Container(
                  //         padding: EdgeInsets.all(20),
                  //         height: 500,
                  //         child: SfPdfViewer.network(
                  //           'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/documents/report2.pdf',
                  //           key: _pdfViewerKey,
                  //         )),
                  //   ],
                  // ),
                  Visibility(
                    visible: widget.status == 'Draft' &&
                            widget.has_edit_access == '1'
                        ? true
                        : false,
                    child: Container(
                      padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  String user_token =
                                      await prefs.getString('user_token') ??
                                          'unknown';

                                  final api_url =
                                      'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getpermohonanforedit/' +
                                          user_token +
                                          '/' +
                                          widget.permohonan_id;
                                  final response =
                                      await http.get(Uri.parse(api_url));
                                  var jsonResponse = json.decode(response.body);
                                  // print(jsonResponse['data']['form']);

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => RequestForm(
                                            form_id: jsonResponse['data']
                                                ['form_id'],
                                            form: jsonResponse['data']['form'],
                                            permohonan_id: widget.permohonan_id,
                                          )));
                                },
                                child: Text('EDIT')),
                          )),
                          Expanded(
                              child: Container(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () async {
                                  Map data = {
                                    'permohonan_id': widget.permohonan_id,
                                    'status': 'pending',
                                    'alasan': '',
                                  };

                                  SharedPreferences sharedPreferences =
                                      await SharedPreferences.getInstance();

                                  var user_token =
                                      sharedPreferences.getString("user_token");

                                  var jsonResponse = null;
                                  String api_url =
                                      "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/updatestatus/" +
                                          user_token!;

                                  var response = await http
                                      .post(Uri.parse(api_url), body: data);

                                  jsonResponse = json.decode(response.body);

                                  if (jsonResponse['status'] == 200) {
                                    String generate_pdf_url =
                                        "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/generatepdf/" +
                                            user_token +
                                            "/" +
                                            widget.permohonan_id;
                                    var response_pdf = await http
                                        .get(Uri.parse(generate_pdf_url));

                                    final snackbar = SnackBar(
                                        content: Text(
                                            "Dokumen permohonan telah dikirim"));
                                    _messangerKey.currentState!
                                        .showSnackBar(snackbar);

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => DetailForm(
                                                  permohonan_id:
                                                      widget.permohonan_id,
                                                  status: 'Pending',
                                                  has_edit_access:
                                                      widget.has_edit_access,
                                                )));
                                  } else {
                                    print(jsonResponse['field_error']);
                                  }
                                },
                                child: Text('KIRIM')),
                          ))
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: is_superadmin == "1" && current_status == 'Pending'
                        ? true
                        : false,
                    child: Container(
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
                                onPressed: () {
                                  Widget cancelButton = ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    child: Text(
                                      "Tutup",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                  );
                                  Widget continueButton = ElevatedButton(
                                    child: Text("Terima"),
                                    onPressed: () async {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();

                                      Map data = {
                                        'permohonan_id': widget.permohonan_id,
                                        'status': 'approved',
                                        'alasan': '',
                                      };

                                      SharedPreferences sharedPreferences =
                                          await SharedPreferences.getInstance();

                                      var user_token = sharedPreferences
                                          .getString("user_token");

                                      var jsonResponse = null;
                                      String api_url =
                                          "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/updatestatus/" +
                                              user_token!;

                                      var response = await http
                                          .post(Uri.parse(api_url), body: data);
                                      jsonResponse = json.decode(response.body);
                                      print(jsonResponse);
                                      if (jsonResponse['status'] == 200) {
                                        String generate_pdf_url =
                                            "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/generatepdf/" +
                                                user_token +
                                                "/" +
                                                widget.permohonan_id;
                                        var response_pdf = await http
                                            .get(Uri.parse(generate_pdf_url));

                                        setState(() {
                                          current_status = 'Approved';
                                        });
                                        reloadData();

                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailForm(
                                                      permohonan_id:
                                                          widget.permohonan_id,
                                                      status: widget.status,
                                                      has_edit_access: widget
                                                          .has_edit_access,
                                                    )));

                                        final snackbar = SnackBar(
                                            content: Text(
                                                "Dokumen permohonan telah disetujui"));
                                        _messangerKey.currentState!
                                            .showSnackBar(snackbar);
                                      } else {
                                        print(jsonResponse['field_error']);
                                      }
                                    },
                                  );
                                  AlertDialog alert = AlertDialog(
                                    title: Text("Konfirmasi"),
                                    content: Text(
                                        "Apakah anda yakin untuk menyetujui permohonan ini?"),
                                    actions: [
                                      cancelButton,
                                      continueButton,
                                    ],
                                  );
                                  // show the dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                },
                                child: Text('Terima')),
                          )),
                          Expanded(
                              child: Container(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  Widget cancelButton = ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    child: Text(
                                      "Tutup",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                  );
                                  Widget continueButton = ElevatedButton(
                                    child: Text("Tolak"),
                                    onPressed: () async {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      Map data = {
                                        'permohonan_id': widget.permohonan_id,
                                        'status': 'rejected',
                                        'alasan': input_alasan.text
                                      };

                                      SharedPreferences sharedPreferences =
                                          await SharedPreferences.getInstance();

                                      var user_token = sharedPreferences
                                          .getString("user_token");

                                      var jsonResponse = null;
                                      String api_url =
                                          "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/updatestatus/" +
                                              user_token!;

                                      var response = await http
                                          .post(Uri.parse(api_url), body: data);

                                      jsonResponse = json.decode(response.body);

                                      if (jsonResponse['status'] == 200) {
                                        String generate_pdf_url =
                                            "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/generatepdf/" +
                                                user_token +
                                                "/" +
                                                widget.permohonan_id;
                                        var response_pdf = await http
                                            .get(Uri.parse(generate_pdf_url));
                                        // generatePDFFile(
                                        //     jsonResponse['data']
                                        //         ['permohonan_id'],
                                        //     jsonResponse['data']['status'],
                                        //     jsonResponse['data']
                                        //         ['pdf_filename'],
                                        //     jsonResponse['data']['nrp'],
                                        //     jsonResponse['data']['nama'],
                                        //     jsonResponse['data']['universitas'],
                                        //     jsonResponse['data']['perihal'],
                                        //     jsonResponse['data']['date_start'],
                                        //     jsonResponse['data']['date_end'],
                                        //     jsonResponse['data']
                                        //         ['response_by']);

                                        setState(() {
                                          current_status = 'Rejected';
                                        });
                                        reloadData();

                                        // Navigator.of(context,
                                        //         rootNavigator: true)
                                        //     .pop();

                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailForm(
                                                      permohonan_id:
                                                          widget.permohonan_id,
                                                      status: widget.status,
                                                      has_edit_access: widget
                                                          .has_edit_access,
                                                    )));

                                        final snackbar = SnackBar(
                                            content: Text(
                                                "Dokumen permohonan telah ditolak"));
                                        _messangerKey.currentState!
                                            .showSnackBar(snackbar);
                                      } else {
                                        print(jsonResponse['field_error']);
                                      }
                                    },
                                  );
                                  AlertDialog alert = AlertDialog(
                                    title: Text("Konfirmasi"),
                                    content: Container(
                                      height: 100,
                                      child: Column(
                                        children: [
                                          Text(
                                              "Apakah anda yakin untuk menolak permohonan ini?"),
                                          TextField(
                                            controller: input_alasan,
                                            decoration: InputDecoration(
                                              hintText: 'Alasan..',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      cancelButton,
                                      continueButton,
                                    ],
                                  );
                                  // show the dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                },
                                child: Text('Tolak')),
                          ))
                        ],
                      ),
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

  Future<void> generatePDFFile(
      String _permohonan_id,
      String _status,
      String pdf_filename,
      String _nrp,
      String _nama,
      String _universitas,
      String _perihal,
      String _date_start,
      String _date_end,
      String _response_by) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
                child: pw.Column(children: [
              pw.Container(
                  padding: pw.EdgeInsets.only(bottom: 20),
                  decoration: pw.BoxDecoration(
                      border: const pw.Border(
                          bottom: pw.BorderSide(color: PdfColors.black))),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Container(
                            child: pw.Text('LOGO',
                                style: pw.TextStyle(fontSize: 20))),
                        pw.Container(
                            padding: pw.EdgeInsets.only(left: 20),
                            child: pw.Column(children: [
                              pw.Text('PT. INTEGRA TEKNOLOGI SOLUSI'),
                              pw.Text(
                                  'Wisma Medokan Asri, Jl. Medokan Asri Utara XV No.10, Medokan Ayu'),
                              pw.Text('Rungkut, Surabaya City, East Java 60295')
                            ]))
                      ])),
              pw.SizedBox(height: 40),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("NRP")),
                pw.Container(width: 150, child: pw.Text(_nrp))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Nama")),
                pw.Container(width: 150, child: pw.Text(_nama))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Universitas")),
                pw.Container(width: 150, child: pw.Text(_universitas))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Perihal")),
                pw.Container(width: 150, child: pw.Text(_perihal))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Tanggal Mulai")),
                pw.Container(width: 150, child: pw.Text(_date_start))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Tanggal Berakhir")),
                pw.Container(width: 150, child: pw.Text(_date_end))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Status Permohonan")),
                pw.Container(width: 150, child: pw.Text(_status.toUpperCase()))
              ]),
              pw.SizedBox(height: 30),
              pw.Container(
                  child: pw.Text(
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.')),
              pw.SizedBox(height: 40),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Column(children: [
                  pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 10),
                      child: pw.Text("Menyetujui,")),
                  pw.Container(
                      color: PdfColors.red,
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Text(_status)),
                  pw.Container(
                      margin: pw.EdgeInsets.only(top: 10),
                      child: pw.Text(_response_by))
                ])
              ]),
            ])),
          ); // Center
        })); // Page

    final directory = await getExternalStorageDirectory();
    final file = File("${directory?.path}/" + pdf_filename);

    final pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes.toList());

    DocumentFileSavePlus().saveMultipleFiles(
      dataList: [
        pdfBytes,
      ],
      fileNameList: [
        pdf_filename,
      ],
      mimeTypeList: [
        pdf_filename,
      ],
    );
  }
}
