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

  Future<List<TaskModel>> getTasks({
    required String token,
    DateTime? date,
  }) async {
    try {
      String url = "${Constants.backendUri}/tasks";
      
      // Add date parameter if provided
      if (date != null) {
        final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        url += "?date=$dateString";
      }
      
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      final List<dynamic> tasksJson = jsonDecode(res.body);
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskModel> updateTask({
    required String taskId,
    required String name,
    required String description,
    required String date,
    required String time,
    required String priority,
    required String contact,
    required String token,
  }) async {
    try {
      final res = await http.put(
        Uri.parse("${Constants.backendUri}/tasks/$taskId"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'date': date,
          'time': time,
          'priority': priority,
          'contact': contact,
        }),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }

      return TaskModel.fromJson(jsonDecode(res.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask({
    required String taskId,
    required String token,
  }) async {
    try {
      final res = await http.delete(
        Uri.parse("${Constants.backendUri}/tasks/$taskId"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
