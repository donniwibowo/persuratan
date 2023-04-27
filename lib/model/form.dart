import 'dart:convert';

List<FormModel> welcomeFromJson(String str) =>
    List<FormModel>.from(json.decode(str).map((x) => FormModel.fromJson(x)));

class FormModel {
  String form_id;
  String form;

  FormModel({
    required this.form_id,
    required this.form,
  });
  //FORMAT TO JSON
  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
        form_id: json["form_id"],
        form: json["form"],
      );
}
