import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final ApiService _api;

  AuthService([ApiService? api]) : _api = api ?? ApiService();

  Future<UserModel> login(String email, String password) async {
    final res = await _api.post('/auth/login', {'email': email, 'password': password});

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Erro ao autenticar';
      try {
        final body = json.decode(res.body);
        if (body is Map && body['status'] != null && body['status']['message'] != null) {
          message = body['status']['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }

    final body = json.decode(res.body);
    // Backend uses wrapped response: { data: { accessToken, user }, status: { ... } }
    final data = body['data'] ?? body;
    final token = data['accessToken'] as String?;
    final user = data['user'] as Map<String, dynamic>?;

    if (token == null || user == null) throw Exception('Resposta de login inválida');

    await _api.setToken(token);

    // Map backend user to local UserModel
    final roleRaw = user['role']?.toString() ?? '';
    final role = _mapRole(roleRaw);

    final userModel = UserModel(
      id: user['id'] ?? user['uuid'] ?? 'unknown',
      name: user['fullName'] ?? user['name'] ?? '',
      email: user['email'] ?? '',
      registration: null,
      institution: user['institutionId'] ?? user['institution'] ?? null,
      role: role,
      avatarUrl: user['profilePhotoUrl'] ?? null,
    );

    return userModel;
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String accessCode,
    String? phoneNumber,
  }) async {
    final res = await _api.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
      'accessCode': accessCode,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Erro ao cadastrar';
      try {
        final body = json.decode(res.body);
        if (body is Map && body['status'] != null && body['status']['message'] != null) {
          message = body['status']['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  UserRole _mapRole(String backendRole) {
    final r = backendRole.toLowerCase();
    if (r.contains('customer')) return UserRole.client;
    if (r.contains('seller')) return UserRole.vendor;
    if (r.contains('vendor')) return UserRole.vendor;
    return UserRole.client;
  }
}
