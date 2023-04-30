import 'dart:convert';

List<PermohonanModel> welcomeFromJson(String str) => List<PermohonanModel>.from(
    json.decode(str).map((x) => PermohonanModel.fromJson(x)));

class PermohonanModel {
  String permohonan_id;
  String form;
  String jenis_peminjaman;
  String perihal;
  String nrp;
  String nama;
  String universitas;
  String keterangan;
  String date_start;
  String date_end;
  String status;
  String is_open_for_notif;
  String alasan;
  String created_on;
  String created_by;
  String updated_on;
  String updated_by;

  PermohonanModel({
    required this.permohonan_id,
    required this.form,
    required this.jenis_peminjaman,
    required this.perihal,
    required this.nrp,
    required this.nama,
    required this.universitas,
    required this.keterangan,
    required this.date_start,
    required this.date_end,
    required this.status,
    required this.is_open_for_notif,
    required this.alasan,
    required this.created_on,
    required this.created_by,
    required this.updated_on,
    required this.updated_by,
  });
  //FORMAT TO JSON
  factory PermohonanModel.fromJson(Map<String, dynamic> json) =>
      PermohonanModel(
        permohonan_id: json["permohonan_id"],
        form: json["form"],
        jenis_peminjaman: json["jenis_peminjaman"],
        perihal: json["perihal"],
        nrp: json["nrp"],
        nama: json["nama"],
        universitas: json["universitas"],
        keterangan: json["keterangan"],
        date_start: json["date_start"],
        date_end: json["date_end"],
        status: json["status"],
        is_open_for_notif: json["is_open_for_notif"],
        alasan: json["alasan"],
        created_on: json["created_on"],
        created_by: json["created_by"],
        updated_on: json["updated_on"],
        updated_by: json["updated_by"],
      );
}
