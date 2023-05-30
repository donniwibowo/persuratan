import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/permohonan.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiPermohonan extends ChangeNotifier {
  List<PermohonanModel> _data = [];
  List<PermohonanModel> get dataPermohonan => _data;

  late SharedPreferences sharedPreferences;
  String email = "unknown";
  String user_id = "";

  ApiPermohonan() {
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

  Future<List<PermohonanModel>> getAllPermohonan(String keyword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';

    final api_url = 'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getallpermohonan/' +
        user_token +
        '/' +
        keyword;
    final response = await http.get(Uri.parse(api_url));

    if (response.statusCode == 200) {
      final result =
          json.decode(response.body)['data'].cast<Map<String, dynamic>>();
      _data = result
          .map<PermohonanModel>((json) => PermohonanModel.fromJson(json))
          .toList();
      return _data;
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<List<PermohonanModel>> getDetailPermohonan(
      String permohonan_id, String markasread) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';

    final api_url = 'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getpermohonan/' +
        user_token +
        '/' +
        permohonan_id +
        '/' +
        markasread;
    final response = await http.get(Uri.parse(api_url));
    if (response.statusCode == 200) {
      final result =
          json.decode(response.body)['data'].cast<Map<String, dynamic>>();
      _data = result
          .map<PermohonanModel>((json) => PermohonanModel.fromJson(json))
          .toList();
      return _data;
    } else {
      throw Exception('Failed to load Data');
    }
  }

  Future<List<PermohonanModel>> getUnreadPermohonan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';

    final api_url =
        'http://34.101.208.151/agutask/persuratan/persuratan-api/rest-api-persuratan/public/api/form/getunreadpermohonan/' + user_token;
    final response = await http.get(Uri.parse(api_url));

    if (response.statusCode == 200) {
      final result =
          json.decode(response.body)['data'].cast<Map<String, dynamic>>();
      _data = result
          .map<PermohonanModel>((json) => PermohonanModel.fromJson(json))
          .toList();
      return _data;
    } else {
      throw Exception('Failed to load Data');
    }
  }
}
