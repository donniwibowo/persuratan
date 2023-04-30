import 'dart:convert';

List<JenisPeminjamanModel> welcomeFromJson(String str) =>
    List<JenisPeminjamanModel>.from(
        json.decode(str).map((x) => JenisPeminjamanModel.fromJson(x)));

class JenisPeminjamanModel {
  String jenis_peminjaman_id;
  String jenis_peminjaman;

  JenisPeminjamanModel({
    required this.jenis_peminjaman_id,
    required this.jenis_peminjaman,
  });
  //FORMAT TO JSON
  factory JenisPeminjamanModel.fromJson(Map<String, dynamic> json) =>
      JenisPeminjamanModel(
        jenis_peminjaman_id: json["jenis_peminjaman_id"],
        jenis_peminjaman: json["jenis_peminjaman"],
      );
}
