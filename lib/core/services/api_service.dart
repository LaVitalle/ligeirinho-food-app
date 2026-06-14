import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _defaultBase =
      kIsWeb ? 'http://localhost:4000' : 'http://10.0.2.2:4000';
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ??
            const String.fromEnvironment('API_BASE_URL',
                defaultValue: _defaultBase),
        _client = client ?? http.Client();

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('api_token');
  }

  Future<void> setToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('api_token', token);
  }

  Map<String, String> _defaultHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse(baseUrl + path);

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    final res = await _client.post(
      _uri(path),
      headers: _defaultHeaders(token),
      body: json.encode(body),
    );
    return res;
  }

  Future<http.Response> get(String path) async {
    final token = await getToken();
    final res = await _client.get(_uri(path), headers: _defaultHeaders(token));
    return res;
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    final res = await _client.patch(
      _uri(path),
      headers: _defaultHeaders(token),
      body: json.encode(body),
    );
    return res;
  }

  Future<http.Response> delete(String path) async {
    final token = await getToken();
    final res = await _client.delete(_uri(path), headers: _defaultHeaders(token));
    return res;
  }
}
