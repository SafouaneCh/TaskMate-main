import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:taskmate/core/constants/constants.dart';
import 'package:taskmate/models/task_model.dart';

class TaskRemoteRepository {
  Future<TaskModel> createTask({
    required String name,
    required String description,
    required String date, // <-- changed
    required String time, // <-- changed
    required String priority,
    required String contact,
    required String token,
  }) async {
    try {
      final res = await http.post(Uri.parse("${Constants.backendUri}/tasks"),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'name': name,
            'description': description,
            'date': date, // <-- changed
            'time': time, // <-- changed
            'priority': priority,
            'contact': contact,
          }));

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return TaskModel.fromJson(jsonDecode(res.body));
    } catch (e) {
      rethrow;
    }
  }
}
