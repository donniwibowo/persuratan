import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:persuratan/api/api_form.dart';
import 'package:persuratan/api/api_permohonan.dart';
import 'package:persuratan/login.dart';
import 'package:persuratan/main.dart';
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/permohonan.dart';
import 'package:persuratan/request_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  late SharedPreferences sharedPreferences;
  late String selectedForm;
  late String selectedFormLabel;
  List<DropdownMenuItem<String>> formList = [];
  ApiForm api_form = ApiForm();
  ApiPermohonan api_permohonan = ApiPermohonan();
  late Future<List<PermohonanModel>> listPermohonan;

  TextEditingController input_search = TextEditingController();

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('DMS | SUREL');

  @override
  void initState() {
    super.initState();
    selectedFormLabel = 'Sakit';
    listPermohonan = api_permohonan.getAllPermohonan(input_search.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: customSearchBar,
            automaticallyImplyLeading: false,
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
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.notifications,
                      size: 26.0,
                    ),
                  )),
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
          body: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 50),
            child: FutureBuilder<List<PermohonanModel>>(
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
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                            top: 0, bottom: 150, right: 0, left: 0),
                        itemCount: api_data.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: EdgeInsets.only(
                                top: 10, left: 15, right: 15, bottom: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              padding: EdgeInsets.only(
                                  top: 10, left: 10, bottom: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 0,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                'Perihal',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 0,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                'Tgl Dibuat',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 0,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                'Tgl Diubah',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 0,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                'Form',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 7),
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 0,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                'Approval',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 0,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                'Status',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 30),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 0,
                                                  right: 10,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                api_data[index].perihal,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 0,
                                                  right: 10,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                api_data[index].created_on,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 0,
                                                  right: 10,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                api_data[index].updated_on,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 0,
                                                  right: 10,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                '6043543545.pdf',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 7),
                                              padding: EdgeInsets.only(
                                                  left: 0,
                                                  right: 10,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Text(
                                                api_data[index].response_by,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.red,
                                              // margin: EdgeInsets.only(left: 10),
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 3,
                                                  bottom: 2),
                                              child: Text(
                                                api_data[index].status,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
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
          )),
    );
  }
}
