import 'dart:convert';

import 'package:http/http.dart'
as http;

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static Future<Map<String, String>>
  getHeaders() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    final token =
    prefs.getString("token");

    return {

      "Content-Type":
      "application/json",

      "Authorization":
      "Bearer $token",

    };
  }

  static Future<http.Response>
    post(

  String url, {
  Object? body,
}) async {

  return await http.post(

    Uri.parse(url),

    headers:
        await getHeaders(),

    body: body,
  );
}
}