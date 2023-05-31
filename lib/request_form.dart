import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:string_extensions/string_extensions.dart';

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
  late String selectedJenisPeminjamanLabel;

  List<DropdownMenuItem<String>> jenisPeminjamanList = [];
  ApiJenisPeminjaman api_jenis_peminjaman = ApiJenisPeminjaman();
  bool isFormPeminjaman = true;
  String dokumen_terlampir = "";
  File? _selectedFile;
  bool isChecked = false;
  @override
  void initState() {
    super.initState();
    selectedJenisPeminjaman = "0";
    if (widget.permohonan_id != "0") {
      getDataPermohonan(widget.permohonan_id);
    }

    setState(() {
      input_perihal.text = widget.form;
    });

    getJenisPeminjaman(widget.form_id);
  }

  getDataPermohonan(String _id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';
    var api_url =
        'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getpermohonanforedit/' +
            user_token +
            '/' +
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

  getJenisPeminjaman(String _id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';
    var api_url =
        'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getalljenispeminjaman/' +
            user_token +
            '/' +
            _id;
    var response = await http.get(Uri.parse(api_url));
    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 200 && jsonResponse['len_data'] > 0) {
      // print(jsonResponse['data'][0]);
      setState(() {
        input_perihal.text =
            widget.form + ' ' + jsonResponse['data'][0]['jenis_peminjaman'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

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
                // Navigator.of(context)
                //     .push(MaterialPageRoute(builder: (context) => Home()));
              },
            ),
          ),
          backgroundColor: Colors.grey.shade200,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Container(
                    padding: EdgeInsets.only(right: 20, left: 3),
                    // margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          value: isChecked,
                          onChanged: (bool? value) async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String fullname =
                                await prefs.getString('fullname') ?? '';
                            setState(() {
                              isChecked = value!;

                              if (isChecked) {
                                input_nama.text = fullname;
                              } else {
                                input_nama.text = "";
                              }
                            });
                          },
                        ),
                        Text('Gunakan data pribadi?')
                      ],
                    )),
                Visibility(
                  visible: isFormPeminjaman,
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    margin: EdgeInsets.only(bottom: 10),
                    child: FutureBuilder<List<JenisPeminjamanModel>>(
                        future: api_jenis_peminjaman
                            .getJenisPeminjaman(widget.form_id),
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
                              return Container();
                            } else {
                              if (selectedJenisPeminjaman == "0") {
                                selectedJenisPeminjaman =
                                    api_data[0].jenis_peminjaman_id;
                                selectedJenisPeminjamanLabel =
                                    api_data[0].jenis_peminjaman;
                              }
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
                                            selectedJenisPeminjaman = newValue!;

                                            for (var i = 0;
                                                i < api_data.length;
                                                i++) {
                                              if (selectedJenisPeminjaman ==
                                                  api_data[i]
                                                      .jenis_peminjaman_id) {
                                                selectedJenisPeminjamanLabel =
                                                    api_data[i]
                                                        .jenis_peminjaman;
                                                setState(() {
                                                  input_perihal.text = widget
                                                          .form +
                                                      ' ' +
                                                      selectedJenisPeminjamanLabel;
                                                });
                                              }
                                            }
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
                              DateFormat('dd MMM yyyy').format(pickedDate);
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
                              DateFormat('dd MMM yyyy').format(pickedDate);
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
                    padding: EdgeInsets.only(left: 10),
                    child: TextButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['docx', 'pdf', 'doc'],
                          );

                          if (result != null) {
                            // Do something with the file
                            try {
                              _selectedFile = File(result.files.single.path!);
                              PlatformFile file_data = result.files.first;

                              if (file_data.size / 1024 > 1000) {
                                final snackbar = SnackBar(
                                    content: Text(
                                        "Batas maksimal ukuran dokumen adalah 1 MB"));
                                _messangerKey.currentState!
                                    .showSnackBar(snackbar);
                              } else {
                                setState(() {
                                  dokumen_terlampir = file_data.name;
                                });
                              }
                            } catch (e) {
                              final snackbar = SnackBar(
                                  content: Text(
                                      "Pelampiran dokumen pendukung gagal"));
                              _messangerKey.currentState!
                                  .showSnackBar(snackbar);
                            }
                          }
                        },
                        child: Container(
                          child: Row(
                            children: [
                              Icon(Icons.attach_file),
                              Text('Lampirkan Dokumen')
                            ],
                          ),
                        ))),
                Visibility(
                    visible: dokumen_terlampir == "" ? false : true,
                    child: Container(
                      padding: EdgeInsets.only(left: 45),
                      child: Row(
                        children: [
                          Text("Dokumen Terlampir : "),
                          Text(dokumen_terlampir)
                        ],
                      ),
                    )),
                Visibility(
                  visible: true,
                  child: Container(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                              // style: ElevatedButton.styleFrom(
                              //     backgroundColor: Colors.green),
                              onPressed: () {
                                Navigator.pop(context);
                                // submitData('draft');
                              },
                              child: Text('BATAL')),
                        )),
                        Expanded(
                            child: Container(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                if (_selectedFile == null) {
                                  print('no attached file');
                                  submitDataNoAttachedFile('draft');
                                } else {
                                  print('file attached');
                                  submitData('draft', {'file': _selectedFile!});
                                }
                                // submitData('pending');
                                // submitData('draft', {'file': _selectedFile!});
                              },
                              child: Text('DRAFT')),
                        ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future<void> generatePDFFile(
      String _permohonan_id, String _status, String pdf_filename) async {
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
                pw.Container(width: 150, child: pw.Text(input_nrp.text))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Nama")),
                pw.Container(
                    width: 150, child: pw.Text(input_nama.text.toUpperCase()))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Universitas")),
                pw.Container(
                    width: 150,
                    child: pw.Text(input_universitas.text.toUpperCase()))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Perihal")),
                pw.Container(width: 150, child: pw.Text(input_perihal.text))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Tanggal Mulai")),
                pw.Container(width: 150, child: pw.Text(date_start.text))
              ]),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Container(width: 150, child: pw.Text("Tanggal Berakhir")),
                pw.Container(width: 150, child: pw.Text(date_end.text))
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
                      margin: pw.EdgeInsets.only(top: 10), child: pw.Text("-"))
                ])
              ]),
            ])),
          ); // Center
        })); // Page

    final directory = await getExternalStorageDirectory();
    final file = File("${directory?.path}/" + pdf_filename);
    print(directory?.path);
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

  submitDataNoAttachedFile(String _status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var user_token = prefs.getString("user_token");
    Map<String, dynamic> data = {
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
      'status': _status,
      'alasan': '',
    };

    var jsonResponse = null;
    String api_url =
        "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/createpermohonan/" +
            user_token!;

    var response = await http.post(Uri.parse(api_url), body: data);
    jsonResponse = json.decode(response.body);

    if (jsonResponse['status'] == 200) {
      String generate_pdf_url =
          "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/generatepdf/" +
              user_token +
              "/" +
              jsonResponse['data']['permohonan_id'];

      var response_pdf = await http.get(Uri.parse(generate_pdf_url));

      if (widget.permohonan_id == "0") {
        final snackbar =
            SnackBar(content: Text("Surat Permohonan telah berhasil dibuat"));
        _messangerKey.currentState!.showSnackBar(snackbar);
      } else {
        final snackbar =
            SnackBar(content: Text("Surat Permohonan telah berhasil diubah"));
        _messangerKey.currentState!.showSnackBar(snackbar);
      }

      generatePDFFile(jsonResponse['data']['permohonan_id'],
          jsonResponse['data']['status'], jsonResponse['data']['pdf_filename']);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DetailForm(
                permohonan_id: jsonResponse['data']['permohonan_id'],
                status: jsonResponse['data']['status'],
                has_edit_access: jsonResponse['data']['has_edit_access'],
              )));
    } else {
      print(jsonResponse);
      final snackbar = SnackBar(content: Text("Failed to load data"));
      _messangerKey.currentState!.showSnackBar(snackbar);
    }
  }

  submitData(String _status, Map<String, File> files) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var user_token = prefs.getString("user_token");
    Map<String, dynamic> data = {
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
      'status': _status,
      'alasan': '',
    };

    Map<String, dio.MultipartFile> fileMap = {};
    for (MapEntry fileEntry in files.entries) {
      File file = fileEntry.value;
      String fileName = path.basename(file.path);
      fileMap[fileEntry.key] = dio.MultipartFile(
          file.openRead(), await file.length(),
          filename: fileName);
    }
    data.addAll(fileMap);
    var formData = FormData.fromMap(data);

    var jsonResponse = null;
    String api_url =
        "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/createpermohonan/" +
            user_token!;

    // var response = await http.post(Uri.parse(api_url), body: data);
    // jsonResponse = json.decode(response.body);

    Dio _dio = new Dio();
    var response = await _dio.post(api_url,
        data: formData, options: Options(contentType: 'multipart/form-data'));

    // if (jsonResponse['status'] == 200) {
    if (response.data['status'] == 200) {
      // print(response.data['data']['permohonan_id']);
      String generate_pdf_url =
          "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/generatepdf/" +
              user_token +
              "/" +
              response.data['data']['permohonan_id'];
      var response_pdf = await http.get(Uri.parse(generate_pdf_url));

      if (widget.permohonan_id == "0") {
        final snackbar =
            SnackBar(content: Text("Surat Permohonan telah berhasil dibuat"));
        _messangerKey.currentState!.showSnackBar(snackbar);
      } else {
        final snackbar =
            SnackBar(content: Text("Surat Permohonan telah berhasil diubah"));
        _messangerKey.currentState!.showSnackBar(snackbar);
      }

      generatePDFFile(
          response.data['data']['permohonan_id'],
          response.data['data']['status'],
          response.data['data']['pdf_filename']);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DetailForm(
                permohonan_id: response.data['data']['permohonan_id'],
                status: response.data['data']['status'],
                has_edit_access: response.data['data']['has_edit_access'],
              )));
    } else {
      print(jsonResponse);
      final snackbar = SnackBar(content: Text("Failed to load data"));
      _messangerKey.currentState!.showSnackBar(snackbar);
    }
  }
}
