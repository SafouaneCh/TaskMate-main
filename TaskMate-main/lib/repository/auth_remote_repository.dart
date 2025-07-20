import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:taskmate/core/constants/constants.dart';

class AuthRemoteRepository {
  Future<void> signUp({
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

        // The header specify that the req body will be JSON
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
