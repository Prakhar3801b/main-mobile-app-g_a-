import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiClient {
  String? _token;

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': AppConfig.defaultEmail,
        'password': AppConfig.defaultPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to login');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _token = data['access_token'] as String;
  }

  Future<Map<String, dynamic>> submitComplaint(Map<String, dynamic> payload) async {
    if (_token == null) {
      await login();
    }

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/complaints/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync complaint');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchComplaints() async {
    if (_token == null) {
      await login();
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/complaints/'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load complaints');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }
}
