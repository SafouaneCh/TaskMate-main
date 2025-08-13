import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_model.dart';
import 'dart:convert'; // Added for jsonEncode and jsonDecode
import 'package:http/http.dart' as http; // Added for http.post
import 'onesignal_service.dart'; // Added for OneSignalService

class ReminderService {
  // Temporarily hardcoded - replace with dotenv when fixed
  static String get _supabaseUrl => 'https://zipxfbleyssjmevkicrm.supabase.co';
  static String get _supabaseAnonKey =>
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppcHhmYmxleXNzam1ldmtpY3JtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NDY2OTgsImV4cCI6MjA3MDIyMjY5OH0.AisljHcyHbZujvPdwCtRKKpJ3LBaBUTnYsswZjn3G34';

  // Original dotenv approach (commented out temporarily):
  // static String get _supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  // static String get _supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> scheduleTaskReminder(TaskModel task) async {
    print('ReminderService.scheduleTaskReminder called for task: ${task.name}');

    if (!task.hasReminder || task.reminderAt == null) {
      print('Task has no reminder or reminderAt is null');
      return;
    }

    try {
      // Schedule push notification via Supabase Edge Function
      await _schedulePushReminder(task);

      print(
          'Push notification scheduled for task: ${task.name} at ${task.reminderAt}');
    } catch (e) {
      print('Error scheduling push notification: $e');
    }
  }

  static Future<void> _schedulePushReminder(TaskModel task) async {
    try {
      // Validate Supabase environment variables
      if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
        print('Error: Supabase environment variables not configured');
        return;
      }

      // Get the real OneSignal player ID from the device
      final playerId = await OneSignalService.getPlayerId();
      if (playerId == null || playerId.isEmpty) {
        print('Error: Could not get OneSignal player ID or it is empty');
        print('Player ID received: "$playerId"');
        return;
      }

      print('Got OneSignal player ID: $playerId');

      // Calculate reminder time based on reminderType
      final scheduledDate =
          calculateReminderTime(task.dueAt, task.reminderType ?? '1hour');

      // Prepare request body
      final requestBody = {
        'taskId': task.id,
        'userId': task.userId,
        'title': 'Task Reminder: ${task.name}',
        'message': 'Your task "${task.name}" is due soon!',
        'scheduledAt': scheduledDate.toIso8601String(),
        'priority': task.priority,
        'reminderType': task.reminderType ?? '1hour',
        'playerId': playerId, // Send the real player ID
      };

      print('Sending request body: ${jsonEncode(requestBody)}');

      // Call Supabase Edge Function to schedule notification
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/schedule_task_reminder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(
            'Push notification scheduled successfully: ${result['notificationId']}');
      } else {
        print(
            'Error scheduling push notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error scheduling push notification: $e');
    }
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    try {
      // Validate environment variables
      if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
        throw Exception('Supabase environment variables not configured');
      }

      // Cancel push notification via Supabase Edge Function
      final supabase = Supabase.instance.client;
      await supabase.functions.invoke('cancel-notification', body: {
        'taskId': taskId,
      });

      print('Push notification cancelled for task: $taskId');
    } catch (e) {
      print('Error cancelling push notification: $e');
      rethrow; // Re-throw to handle in calling code
    }
  }

  static Future<void> updateTaskReminder(TaskModel task) async {
    // Cancel existing reminder and schedule new one
    await cancelTaskReminder(task.id);
    await scheduleTaskReminder(task);
  }

  // Helper method to calculate reminder time based on due date
  static DateTime calculateReminderTime(DateTime dueDate, String reminderType) {
    // For testing: always send notification immediately
    return DateTime.now().add(Duration(seconds: 5)); // 5 seconds from now

    // Original logic (commented out for testing):
    /*
    switch (reminderType) {
      case '15min':
        return dueDate.subtract(const Duration(minutes: 15));
      case '1hour':
        return dueDate.subtract(const Duration(hours: 1));
      case '1day':
        return dueDate.subtract(const Duration(days: 1));
      default:
        return dueDate.subtract(const Duration(hours: 1));
    }
    */
  }

  // Helper method to create a task with automatic reminder calculation
  static TaskModel createTaskWithReminder({
    required String id,
    required String userId, // Changed from uid to userId
    required String name,
    required String description,
    required DateTime dueAt,
    required String priority,
    required String contact,
    required String status,
    required String reminderType,
  }) {
    final reminderAt = calculateReminderTime(dueAt, reminderType);

    return TaskModel(
      id: id,
      userId: userId, // Changed from uid to userId
      name: name,
      description: description,
      dueAt: dueAt,
      priority: priority,
      contact: contact,
      status: status,
      hasReminder: true,
      reminderAt: reminderAt,
      reminderType: reminderType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
