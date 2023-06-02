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
import 'package:persuratan/notification_page.dart';
import 'package:persuratan/request_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:swipe/swipe.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
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

  // late AnimationController _animation_controller;
  // late Animation<double> _animation;

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
        'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/countnotif/' +
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

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.5;
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
                        if (notif_ctr > 0) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NotificatioPage()));
                        }

                        // setState(() {
                        //   notif_ctr = 0;
                        // });
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
            heroTag: "btnCreateNewDoc",
            onPressed: () {
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
                                                  selectedForm = newValue!;
                                                  for (var i = 0;
                                                      i < form_data.length;
                                                      i++) {
                                                    if (selectedForm ==
                                                        form_data[i].form_id) {
                                                      selectedFormLabel =
                                                          form_data[i].form;
                                                    }
                                                  }
                                                });

                                                // dropDownState(() {
                                                //   dropDownState(() {

                                                //   });
                                                // });
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

                                AnimationController _animation_controller =
                                    new AnimationController(
                                  vsync: this,
                                  duration: const Duration(milliseconds: 200),
                                );
                                Animation<double> _animation =
                                    new CurvedAnimation(
                                  parent: _animation_controller,
                                  curve: new Interval(0.0, 1.0,
                                      curve: Curves.linear),
                                );

                                // _animation_controller.reverse();
                                return SlideTransition(
                                  position: new Tween<Offset>(
                                    begin: Offset.zero,
                                    end: const Offset(1.0, 0.0),
                                  ).animate(_animation),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => DetailForm(
                                                    permohonan_id:
                                                        api_data[index]
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
                                      child: Swipe(
                                        verticalMaxWidthThreshold: 50,
                                        verticalMinDisplacement: 100,
                                        verticalMinVelocity: 300,
                                        horizontalMaxHeightThreshold: 50,
                                        horizontalMinDisplacement: 100,
                                        horizontalMinVelocity: 300,
                                        onSwipeLeft: () {
                                          // _animation_controller.reverse();
                                          if (api_data[index].status ==
                                                  'Draft' &&
                                              api_data[index].has_edit_access ==
                                                  "1") {
                                            Widget cancelButton =
                                                ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.white),
                                              child: Text(
                                                "Tutup",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
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
                                                    sharedPreferences.getString(
                                                        "user_token");

                                                var jsonResponse = null;
                                                String api_url =
                                                    "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/deletepermohonan/" +
                                                        user_token!;

                                                var response = await http.post(
                                                    Uri.parse(api_url),
                                                    body: data);

                                                jsonResponse =
                                                    json.decode(response.body);
                                                print(jsonResponse);

                                                if (jsonResponse['status'] ==
                                                    200) {
                                                  reloadData();

                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();

                                                  final snackbar = SnackBar(
                                                      content: Text(
                                                          "Dokumen permohonan telah dihapus"));
                                                  _messangerKey.currentState!
                                                      .showSnackBar(snackbar);
                                                } else {
                                                  print(jsonResponse[
                                                      'field_error']);
                                                }
                                              },
                                            );
                                            AlertDialog alert = AlertDialog(
                                              title: Text("Konfirmasi"),
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
                                              builder: (BuildContext context) {
                                                return alert;
                                              },
                                            );
                                          }
                                        },
                                        onSwipeRight: () async {
                                          if (api_data[index].status ==
                                                  'Draft' &&
                                              api_data[index].has_edit_access ==
                                                  "1") {
                                            _animation_controller.forward();
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            String user_token = await prefs
                                                    .getString('user_token') ??
                                                'unknown';

                                            final api_url =
                                                'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getpermohonanforedit/' +
                                                    user_token +
                                                    '/' +
                                                    api_data[index]
                                                        .permohonan_id;
                                            final response = await http
                                                .get(Uri.parse(api_url));
                                            var jsonResponse =
                                                json.decode(response.body);
                                            // print(jsonResponse['data']['form']);

                                            _animation_controller.reset();
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RequestForm(
                                                          form_id: jsonResponse[
                                                                  'data']
                                                              ['form_id'],
                                                          form: jsonResponse[
                                                              'data']['form'],
                                                          permohonan_id:
                                                              api_data[index]
                                                                  .permohonan_id,
                                                        )));
                                          }
                                        },
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
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: c_width,
                                                        child: Text(
                                                            api_data[index]
                                                                .perihal,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16)),
                                                      ),
                                                      Container(
                                                        width: c_width,
                                                        child: Text(
                                                            api_data[index]
                                                                .nama,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                            "Tanggal Mulai",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16)),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                            api_data[index]
                                                                .date_start,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16)),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                            api_data[index]
                                                                .date_end,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16)),
                                                      ),
                                                      Container(
                                                        width: c_width,
                                                        child: Text(
                                                            api_data[index]
                                                                .pdf_filename,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
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
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16)),
                                                      ),
                                                      Container(
                                                        child: Text(
                                                            api_data[index]
                                                                .created_on,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16)),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                status_label_color,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                top: 3,
                                                                bottom: 3,
                                                                right: 10),
                                                        child: Text(
                                                            api_data[index]
                                                                .status,
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
                                                        child: Text(
                                                            "Approval By",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16)),
                                                      ),
                                                      Container(
                                                        width: c_width,
                                                        child: Text(
                                                            api_data[index]
                                                                .response_by,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16)),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Visibility(
                                                    visible: api_data[index]
                                                                    .alasan ==
                                                                "" ||
                                                            api_data[index]
                                                                    .alasan ==
                                                                "-"
                                                        ? false
                                                        : true,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          // height: 50,
                                                          width: 300,
                                                          padding: EdgeInsets
                                                              .fromLTRB(15, 10,
                                                                  15, 10),
                                                          decoration: BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text("Alasan"),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(api_data[
                                                                      index]
                                                                  .alasan)
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible: api_data[index]
                                                                .status ==
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
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop();
                                                            },
                                                          );
                                                          Widget
                                                              continueButton =
                                                              ElevatedButton(
                                                            child:
                                                                Text("Hapus"),
                                                            onPressed:
                                                                () async {
                                                              Map data = {
                                                                'permohonan_id':
                                                                    api_data[
                                                                            index]
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
                                                                  "http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/deletepermohonan/" +
                                                                      user_token!;

                                                              var response =
                                                                  await http.post(
                                                                      Uri.parse(
                                                                          api_url),
                                                                      body:
                                                                          data);

                                                              jsonResponse =
                                                                  json.decode(
                                                                      response
                                                                          .body);
                                                              print(
                                                                  jsonResponse);

                                                              if (jsonResponse[
                                                                      'status'] ==
                                                                  200) {
                                                                reloadData();

                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();

                                                                final snackbar =
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Dokumen permohonan telah dihapus"));
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
                                                            title: Text(
                                                                "Konfirmasi"),
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
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return alert;
                                                            },
                                                          );
                                                        },
                                                        color: Colors.red,
                                                        icon: Icon(
                                                            Icons.delete))),
                                              )
                                            ],
                                          ),
                                        ),
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
