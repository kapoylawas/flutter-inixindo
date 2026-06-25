import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inixindo_flutter/consts/api.dart';
import 'package:inixindo_flutter/modules/login/models/loginResponseModel.dart';

class Loginapi {
  Future<LoginResponseModel?> login(String email, String password) async {
    try {
      final url = BASE_LOGIN_URL.startsWith('http')
          ? Uri.parse(BASE_LOGIN_URL)
          : Uri.parse('http://$BASE_LOGIN_URL');

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'identifier': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return LoginResponseModel.fromJson(jsonResponse);
      } else {
        print('Login gagal: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan saat login: $e');
      return null;
    }
  }
}
