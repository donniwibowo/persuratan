import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:persuratan/model/form.dart';
import 'package:persuratan/model/jenis_peminjaman.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiJenisPeminjaman extends ChangeNotifier {
  List<JenisPeminjamanModel> _data = [];
  List<JenisPeminjamanModel> get dataPeminjaman => _data;

  late SharedPreferences sharedPreferences;
  String email = "unknown";
  String user_id = "";

  ApiJenisPeminjaman() {
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

  Future<List<JenisPeminjamanModel>> getJenisPeminjaman() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_token = await prefs.getString('user_token') ?? 'unknown';

    final api_url =
        'https://192.168.1.25/leap_integra/master/dms/api/form/getjenispeminjaman?user_token=' +
            user_token;
    final response = await http.get(Uri.parse(api_url));

    if (response.statusCode == 200) {
      final result =
          json.decode(response.body)['data'].cast<Map<String, dynamic>>();
      _data = result
          .map<JenisPeminjamanModel>(
              (json) => JenisPeminjamanModel.fromJson(json))
          .toList();
      return _data;
    } else {
      throw Exception('Failed to load Data');
    }
  }
}
