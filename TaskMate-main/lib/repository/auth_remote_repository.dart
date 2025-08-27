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
        print('No token found, user needs to login');
        return null;
      }

      print('Validating token...');
      // we make the http POST request
      final res = await http.post(
        Uri.parse(
          '${Constants.backendUri}/auth/tokenIsValid',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      ).timeout(Duration(seconds: 15));

      print('Token validation response status: ${res.statusCode}');
      print('Token validation response body: ${res.body}');

      if (res.statusCode != 200) {
        print('Token validation failed with status: ${res.statusCode}');
        return null;
      }

      final tokenValid = jsonDecode(res.body);
      if (tokenValid != true) {
        print('Token validation returned false');
        return null;
      }

      print('Token is valid, fetching user data...');
      final userResponse = await http.get(
        Uri.parse(
          '${Constants.backendUri}/auth',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      ).timeout(Duration(seconds: 15));

      print('User data response status: ${userResponse.statusCode}');
      print('User data response body: ${userResponse.body}');

      if (userResponse.statusCode != 200) {
        print('User data fetch failed with status: ${userResponse.statusCode}');
        return null;
      }

      final userData = jsonDecode(userResponse.body);
      if (userData == false) {
        print('User data response is false');
        return null;
      }

      print('Successfully parsed user data');
      return UserModel.fromJson(userData);
    } catch (e) {
      print('Error in getUserData: $e');
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
