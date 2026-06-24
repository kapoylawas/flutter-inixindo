import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inixindo_flutter/consts/api.dart';
import 'package:inixindo_flutter/modules/login/data/loginDb.dart';
import 'package:inixindo_flutter/modules/location/models/locationResponseModel.dart';

class Locationapi {
  final LoginDb _loginDb = LoginDb.instance;

  Future<LocationResponseModel?> getTrackings() async {
    try {
      final session = await _loginDb.getSession();
      final jwt = session?.jwt;

      if (jwt == null) {
        print('Error: Token JWT tidak ditemukan, silakan login kembali.');
        return null;
      }

      final url = BASE_LOGIN_TRACKING_URL.startsWith('http')
          ? Uri.parse(BASE_LOGIN_TRACKING_URL)
          : Uri.parse('http://$BASE_LOGIN_TRACKING_URL');

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return LocationResponseModel.fromJson(jsonResponse);
      } else {
        print(
          'Gagal mengambil data trackings: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan saat memanggil API trackings: $e');
      return null;
    }
  }
}
