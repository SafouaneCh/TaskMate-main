import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:taskmate/core/constants/constants.dart';
import 'package:taskmate/core/services/sp_service.dart';
import 'package:taskmate/models/user_model.dart';

class AuthRemoteRepository {
  final SpService spService = SpService();

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // we make the http POST request
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/signup',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(jsonDecode(res.body));
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> login({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // we make the http POST request
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/login',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromJson(jsonDecode(res.body));
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await spService.getToken();
      print('Loaded token in getUserData: ${token ?? 'null'}');
      if (token == null) {
        throw 'No token found! Please login first.';
      }
      // we make the http POST request
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/TokenIsValid',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse(
          '${Constants.backendUri}/auth',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (userResponse.statusCode != 200 ||
          jsonDecode(userResponse.body) == false) {
        return null;
      }

      return UserModel.fromJson(jsonDecode(userResponse.body));
    } catch (e) {
      return null;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw 'No token found! Please login first.';
      }

      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/change-password',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (res.statusCode != 200) {
        final errorData = jsonDecode(res.body);
        throw errorData['error'] ?? 'Failed to change password';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
