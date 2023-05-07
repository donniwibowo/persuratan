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
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/permohonan.dart';
import 'package:persuratan/request_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  late String selectedForm;
  late String selectedFormLabel;
  List<DropdownMenuItem<String>> formList = [];
  ApiForm api_form = ApiForm();
  ApiPermohonan api_permohonan = ApiPermohonan();
  late Future<List<PermohonanModel>> listPermohonan;

  TextEditingController input_search = TextEditingController();

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('DMS | SUREL');

  int notif_ctr = 0;
  Color status_label_color = Colors.blue;
  Color status_text_color = Colors.white;

  @override
  void initState() {
    super.initState();
    selectedFormLabel = 'Sakit';
    selectedForm = "1";
    setState(() {
      listPermohonan = api_permohonan.getAllPermohonan(input_search.text);
    });
    countNotif();
    reloadData();
  }

  void countNotif() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';
    String api_url =
        'https://192.168.1.25/leap_integra/master/dms/api/form/getnumberofnotif?user_token=' +
            user_token;
    var response = await http.get(Uri.parse(api_url));

    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 200) {
      setState(() {
        notif_ctr = jsonResponse['data'];
      });
    }
  }

  reloadData() {
    setState(() {
      listPermohonan = api_permohonan.getAllPermohonan(input_search.text);
    });
  }

  Future<void> generatePDFFile() async {
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
                pw.Container(width: 150, child: pw.Text("123243443434"))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Nama")),
                pw.Container(width: 150, child: pw.Text("123243443434"))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Universitas")),
                pw.Container(width: 150, child: pw.Text("123243443434"))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Perihal")),
                pw.Container(width: 150, child: pw.Text("123243443434"))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Tanggal Mulai")),
                pw.Container(width: 150, child: pw.Text("123243443434"))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Tanggal Berakhir")),
                pw.Container(width: 150, child: pw.Text("123243443434"))
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
                      child: pw.Text("Menyetujui")),
                  pw.Container(
                      color: PdfColors.red,
                      padding: pw.EdgeInsets.all(10),
                      child: pw.Text('Approved')),
                  pw.Container(
                      margin: pw.EdgeInsets.only(top: 10),
                      child: pw.Text("Delvo Anderson"))
                ])
              ]),
            ])),
          ); // Center
        })); // Page

    final directory = await getExternalStorageDirectory();
    final file = File("${directory?.path}/test_pdf3.pdf");
    print(directory?.path);
    final pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes.toList());

    DocumentFileSavePlus().saveMultipleFiles(
      dataList: [
        pdfBytes,
      ],
      fileNameList: [
        "test_pdf3.pdf",
      ],
      mimeTypeList: [
        "test_pdf2/pdf",
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: customSearchBar,
            // automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    if (customIcon.icon == Icons.search) {
                      customIcon = const Icon(Icons.cancel);
                      customSearchBar = ListTile(
                        leading: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 28,
                        ),
                        title: TextField(
                          controller: input_search,
                          decoration: InputDecoration(
                            hintText: 'kata kunci..',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              listPermohonan =
                                  api_permohonan.getAllPermohonan(value);
                            });
                          },
                        ),
                      );
                    } else {
                      customIcon = const Icon(Icons.search);
                      customSearchBar = const Text('DMS | SUREL');
                    }
                  });
                },
                icon: customIcon,
              ),
              new Stack(
                children: <Widget>[
                  new IconButton(
                      padding: EdgeInsets.only(top: 8, right: 12),
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        setState(() {
                          notif_ctr = 0;
                        });
                      }),
                  notif_ctr != 0
                      ? new Positioned(
                          right: 18,
                          top: 11,
                          child: new Container(
                            padding: EdgeInsets.all(2),
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$notif_ctr',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : new Container()
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.clear();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MainApp()));
                    },
                    child: Icon(Icons.logout),
                  )),
            ],
          ),
          backgroundColor: Colors.grey.shade200,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // generatePDFFile();
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Pilih Form'),
                        content: Container(
                          height: 50,
                          child: FutureBuilder<List<FormModel>>(
                              future: api_form.getAllForms(),
                              builder: (BuildContext context, snapshot) {
                                if (snapshot.hasData) {
                                  List<FormModel>? form_data = snapshot.data!;

                                  formList = form_data
                                      .map((data) => DropdownMenuItem<String>(
                                            value: data.form_id,
                                            child: Text(data.form),
                                          ))
                                      .toList();

                                  if (form_data.length < 1) {
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
                                    selectedForm = form_data[0].form_id;
                                  }

                                  return DecoratedBox(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 1.0, color: Colors.grey),
                                        ),
                                      ), //border of dropdown button

                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter dropDownState) {
                                            return DropdownButton(
                                              value: selectedForm,
                                              items: formList,
                                              onChanged: (String? newValue) {
                                                dropDownState(() {
                                                  dropDownState(() {
                                                    selectedForm = newValue!;
                                                    for (var i = 0;
                                                        i < form_data.length;
                                                        i++) {
                                                      if (selectedForm ==
                                                          form_data[i]
                                                              .form_id) {
                                                        selectedFormLabel =
                                                            form_data[i].form;
                                                      }
                                                    }
                                                  });
                                                });
                                              },
                                              icon: const Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  child: Icon(
                                                    Icons
                                                        .arrow_circle_down_sharp,
                                                    color: Colors.black,
                                                  )),
                                              iconEnabledColor:
                                                  Colors.white, //Icon color
                                              style: const TextStyle(
                                                  color:
                                                      Colors.black, //Font color
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
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Tutup'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => RequestForm(
                                        form_id: selectedForm,
                                        form: selectedFormLabel,
                                      )));
                            },
                            child: const Text('Lanjut'),
                          ),
                        ],
                      ));
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
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
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      padding: EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          bottom: 10,
                                          right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text(
                                                      "Perihal",
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 170,
                                                    child: Text(
                                                        api_data[index].perihal,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16)
                                                        // maxLines: 2,
                                                        // overflow:
                                                        //     TextOverflow.visible,
                                                        ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text("Nama",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16)),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        api_data[index].nama,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text("Tanggal Mulai",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16)),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        api_data[index]
                                                            .date_start,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text(
                                                        "Tanggal Berakhir",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16)),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        api_data[index]
                                                            .date_end,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text("Dokumen",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16)),
                                                  ),
                                                  Container(
                                                    width: 170,
                                                    child: Text(
                                                        api_data[index]
                                                            .pdf_filename,
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 16)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text(
                                                        "Tanggal Dibuat",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16)),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        api_data[index]
                                                            .created_on,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text("Status",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16)),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            status_label_color,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    padding: EdgeInsets.only(
                                                        left: 10,
                                                        top: 3,
                                                        bottom: 3,
                                                        right: 10),
                                                    child: Text(
                                                        api_data[index].status,
                                                        style: TextStyle(
                                                            color:
                                                                status_text_color,
                                                            fontSize: 16)),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 135,
                                                    child: Text("Approval By",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16)),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        api_data[index]
                                                            .response_by,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          Visibility(
                                            visible: api_data[index].status ==
                                                        'Draft' &&
                                                    api_data[index]
                                                            .has_edit_access ==
                                                        "1"
                                                ? true
                                                : false,
                                            child: Container(
                                                child: IconButton(
                                                    onPressed: () {
                                                      Widget cancelButton =
                                                          ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white),
                                                        child: Text(
                                                          "Tutup",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        },
                                                      );
                                                      Widget continueButton =
                                                          ElevatedButton(
                                                        child: Text("Hapus"),
                                                        onPressed: () async {
                                                          Map data = {
                                                            'permohonan_id':
                                                                api_data[index]
                                                                    .permohonan_id,
                                                          };
                                                          SharedPreferences
                                                              sharedPreferences =
                                                              await SharedPreferences
                                                                  .getInstance();

                                                          var user_token =
                                                              sharedPreferences
                                                                  .getString(
                                                                      "user_token");

                                                          var jsonResponse =
                                                              null;
                                                          String api_url =
                                                              "https://192.168.1.66/leap_integra/leap_integra/master/dms/api/form/deletedocument?user_token=" +
                                                                  user_token!;

                                                          var response =
                                                              await http.post(
                                                                  Uri.parse(
                                                                      api_url),
                                                                  body: data);

                                                          jsonResponse = json
                                                              .decode(response
                                                                  .body);
                                                          print(jsonResponse);

                                                          if (jsonResponse[
                                                                  'status'] ==
                                                              200) {
                                                            reloadData();

                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();

                                                            final snackbar = SnackBar(
                                                                content: Text(
                                                                    "Dokumen permohonan telah dihapus"));
                                                            _messangerKey
                                                                .currentState!
                                                                .showSnackBar(
                                                                    snackbar);
                                                          } else {
                                                            print(jsonResponse[
                                                                'field_error']);
                                                          }
                                                        },
                                                      );
                                                      AlertDialog alert =
                                                          AlertDialog(
                                                        title:
                                                            Text("Konfirmasi"),
                                                        content: Text(
                                                            "Apakah anda yakin untuk menghapus dokumen ini?"),
                                                        actions: [
                                                          cancelButton,
                                                          continueButton,
                                                        ],
                                                      );
                                                      // show the dialog
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return alert;
                                                        },
                                                      );
                                                    },
                                                    color: Colors.red,
                                                    icon: Icon(Icons.delete))),
                                          )
                                        ],
                                      ),
                                    ),
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
