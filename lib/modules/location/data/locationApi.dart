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
      ).timeout(const Duration(seconds: 5));

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

  Future<LocationResponseModel?> getLokasiPhp() async {
    try {
      final url = Uri.parse(LOKASI_PHP_URL);

      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return LocationResponseModel.fromJson(jsonResponse);
      } else {
        print(
          'Gagal mengambil data lokasi PHP: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan saat memanggil API lokasi PHP: $e');
      return null;
    }
  }

  Future<bool> postTracking({
    required String placeName,
    required String placeType,
    required String comment,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final session = await _loginDb.getSession();
      final jwt = session?.jwt;

      if (jwt == null) {
        print('Error: Token JWT tidak ditemukan, silakan login kembali.');
        return false;
      }

      final url = BASE_LOGIN_TRACKING_URL.startsWith('http')
          ? Uri.parse(BASE_LOGIN_TRACKING_URL)
          : Uri.parse('http://$BASE_LOGIN_TRACKING_URL');

      final Map<String, String> requestHeaders = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwt',
      };

      final String requestBody = jsonEncode(<String, dynamic>{
        'data': {
          'placeName': placeName,
          'placeType': placeType,
          'comment': comment,
          'latitude': latitude,
          'longitude': longitude,
        },
      });

      // DEBUG: Tampilkan URL, headers, dan body
      print('=== DEBUG: KIRIM DATA TRACKING ===');
      print('URL    : $url');
      print('Headers: $requestHeaders');
      print('Body   : $requestBody');
      print('==================================');

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      ).timeout(const Duration(seconds: 5));

      // DEBUG: Tampilkan respon server
      print('=== DEBUG: HASIL RESPON SERVER ===');
      print('Status Code: ${response.statusCode}');
      print('Body Respon: ${response.body}');
      print('==================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
          'Gagal mengirim data tracking: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi kesalahan saat memanggil API post tracking: $e');
      return false;
    }
  }

  Future<bool> deleteTracking(dynamic id) async {
    try {
      final session = await _loginDb.getSession();
      final jwt = session?.jwt;

      if (jwt == null) {
        print('Error: Token JWT tidak ditemukan, silakan login kembali.');
        return false;
      }

      final baseUrl = BASE_LOGIN_TRACKING_URL.startsWith('http')
          ? BASE_LOGIN_TRACKING_URL
          : 'http://$BASE_LOGIN_TRACKING_URL';

      final url = Uri.parse('$baseUrl/$id');

      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwt',
        },
      ).timeout(const Duration(seconds: 5));

      // DEBUG: Tampilkan respon server
      print('=== DEBUG: DELETE TRACKING ===');
      print('URL        : $url');
      print('Status Code: ${response.statusCode}');
      print('Body Respon: ${response.body}');
      print('==============================');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print(
          'Gagal menghapus data tracking: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi kesalahan saat memanggil API delete tracking: $e');
      return false;
    }
  }

  Future<bool> updateTracking({
    required dynamic id,
    required String placeName,
    required String placeType,
    required String comment,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final session = await _loginDb.getSession();
      final jwt = session?.jwt;

      if (jwt == null) {
        print('Error: Token JWT tidak ditemukan, silakan login kembali.');
        return false;
      }

      final baseUrl = BASE_LOGIN_TRACKING_URL.startsWith('http')
          ? BASE_LOGIN_TRACKING_URL
          : 'http://$BASE_LOGIN_TRACKING_URL';

      final url = Uri.parse('$baseUrl/$id');

      final Map<String, String> requestHeaders = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwt',
      };

      final String requestBody = jsonEncode(<String, dynamic>{
        'data': {
          'placeName': placeName,
          'placeType': placeType,
          'comment': comment,
          'latitude': latitude,
          'longitude': longitude,
        }
      });

      // DEBUG: Tampilkan URL, headers, dan body request di terminal
      print('=== DEBUG: UPDATE DATA TRACKING (PUT) ===');
      print('URL    : $url');
      print('Headers: $requestHeaders');
      print('Body   : $requestBody');
      print('=========================================');

      final response = await http.put(
        url,
        headers: requestHeaders,
        body: requestBody,
      ).timeout(const Duration(seconds: 5));

      // DEBUG: Tampilkan respon server di terminal
      print('=== DEBUG: HASIL RESPON SERVER (PUT) ===');
      print('Status Code: ${response.statusCode}');
      print('Body Respon: ${response.body}');
      print('=========================================');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print(
          'Gagal mengupdate data tracking: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Terjadi kesalahan saat memanggil API update tracking: $e');
      return false;
    }
  }
}
