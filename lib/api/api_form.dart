import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:persuratan/model/form.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiForm extends ChangeNotifier {
  List<FormModel> _data = [];
  List<FormModel> get dataForm => _data;

  late SharedPreferences sharedPreferences;
  String email = "unknown";
  String user_id = "";

  ApiForm() {
    notifyListeners();
    setup();
  }

  void setup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = (await prefs.getString('email') ?? 'unknown');
    String url2 = await prefs.getString('user_id') ?? 'unknown';
    String user_token = await prefs.getString('user_token') ?? 'unknown';
    email = url;
    user_id = url2;
    notifyListeners();
  }

  Future<List<FormModel>> getAllForms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';

    final api_url =
        'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getallform/' + user_token;
    final response = await http.get(Uri.parse(api_url));
    var jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 200) {
      final result =
          json.decode(response.body)['data'].cast<Map<String, dynamic>>();
      _data =
          result.map<FormModel>((json) => FormModel.fromJson(json)).toList();
      return _data;
    } else {
      throw Exception('Failed to load Data');
    }
  }
}
