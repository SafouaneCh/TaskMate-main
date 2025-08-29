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
    print(
        '🔔 ReminderService.scheduleTaskReminder called for task: ${task.name}');
    print(
        '📋 Task details: ID=${task.id}, Due=${task.dueAt}, HasReminder=${task.hasReminder}');

    if (!task.hasReminder || task.reminderAt == null) {
      print('❌ Task has no reminder or reminderAt is null');
      return;
    }

    try {
      // Schedule push notification via Supabase Edge Function
      await _schedulePushReminder(task);

      print(
          '✅ Push notification scheduled for task: ${task.name} at ${task.reminderAt}');
    } catch (e) {
      print('❌ Error scheduling push notification: $e');
    }
  }

  // New method to schedule multiple reminders for a task
  static Future<void> scheduleMultipleReminders(
      TaskModel task, List<String> reminderTypes) async {
    print(
        '🔔 ReminderService.scheduleMultipleReminders called for task: ${task.name}');
    print(
        '📋 Task details: ID=${task.id}, Due=${task.dueAt}, ReminderTypes=$reminderTypes');

    if (reminderTypes.isEmpty) {
      print('❌ No reminder types specified');
      return;
    }

    try {
      // Cancel any existing reminders first
      await cancelTaskReminder(task.id);
      print('🔄 Cancelled existing reminders for task: ${task.id}');

      // Schedule each reminder type
      for (String reminderType in reminderTypes) {
        await _schedulePushReminder(task, reminderType);
        print('✅ Scheduled $reminderType reminder for task: ${task.name}');
      }

      print(
          '🎉 All ${reminderTypes.length} reminders scheduled successfully for task: ${task.name}');
    } catch (e) {
      print('❌ Error scheduling multiple reminders: $e');
    }
  }

  static Future<void> _schedulePushReminder(TaskModel task,
      [String? customReminderType]) async {
    try {
      // Validate Supabase environment variables
      if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
        print('❌ Error: Supabase environment variables not configured');
        return;
      }

      // Get the real OneSignal player ID from the device
      final playerId = await OneSignalService.getPlayerId();
      if (playerId == null || playerId.isEmpty) {
        print('❌ Error: Could not get OneSignal player ID or it is empty');
        print('Player ID received: "$playerId"');
        return;
      }

      print('✅ Got OneSignal player ID: $playerId');

      // Use custom reminder type if provided, otherwise use task's reminder type
      final reminderType = customReminderType ?? task.reminderType ?? '1hour';

      // Calculate reminder time based on reminderType
      final scheduledDate = calculateReminderTime(task.dueAt, reminderType);

      // Add detailed timing information
      final now = DateTime.now();
      final timeUntilReminder = scheduledDate.difference(now);
      final timeUntilDue = task.dueAt.difference(now);

      print(
          '📅 Reminder calculation: Due=${task.dueAt}, Type=$reminderType, Scheduled=$scheduledDate');
      print(
          '⏰ Timing: Reminder in ${timeUntilReminder.inMinutes} minutes, Task due in ${timeUntilDue.inHours} hours');

      // Prepare request body
      final requestBody = {
        'taskId': task.id,
        'userId': task.userId,
        'title': 'Task Reminder: ${task.name}',
        'message': 'Your task "${task.name}" is due soon!',
        'scheduledAt': scheduledDate.toIso8601String(),
        'priority': task.priority,
        'reminderType': reminderType,
        'playerId': playerId, // Send the real player ID
      };

      print('📤 Sending request body: ${jsonEncode(requestBody)}');

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
            '✅ Push notification scheduled successfully: ${result['notificationId']}');
        print('📱 OneSignal notification ID: ${result['notificationId']}');
      } else {
        print(
            '❌ Error scheduling push notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error scheduling push notification: $e');
    }
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    print('🚫 ReminderService.cancelTaskReminder called for task: $taskId');

    try {
      // Validate environment variables
      if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
        print('❌ Error: Supabase environment variables not configured');
        return;
      }

      // Cancel push notification via Supabase Edge Function
      final supabase = Supabase.instance.client;
      final result =
          await supabase.functions.invoke('cancel-notification', body: {
        'taskId': taskId,
      });

      print('✅ Push notification cancelled for task: $taskId');
      print('📋 Cancellation result: ${result.data}');
    } catch (e) {
      print('❌ Error cancelling push notification: $e');
      // Don't rethrow - cancellation failure shouldn't break the app
    }
  }

  // Method to cancel multiple task reminders
  static Future<void> cancelMultipleTaskReminders(List<String> taskIds) async {
    print(
        '🚫 ReminderService.cancelMultipleTaskReminders called for ${taskIds.length} tasks');
    print('📋 Task IDs: $taskIds');

    try {
      for (String taskId in taskIds) {
        await cancelTaskReminder(taskId);
      }
      print('✅ All ${taskIds.length} task reminders cancelled successfully');
    } catch (e) {
      print('❌ Error cancelling multiple task reminders: $e');
    }
  }

  // Method to cancel all reminders for a user
  static Future<void> cancelAllUserReminders(String userId) async {
    print('🚫 ReminderService.cancelAllUserReminders called for user: $userId');

    try {
      // This would require a backend endpoint to get all scheduled notifications for a user
      // For now, we'll log the request
      print('📋 Request to cancel all reminders for user: $userId');
      print(
          '⚠️ Note: This requires backend implementation to get user\'s scheduled notifications');

      // TODO: Implement when backend supports getting user's scheduled notifications
      // final supabase = Supabase.instance.client;
      // final result = await supabase.functions.invoke('cancel-all-user-notifications', body: {
      //   'userId': userId,
      // });
    } catch (e) {
      print('❌ Error cancelling all user reminders: $e');
    }
  }

  static Future<void> updateTaskReminder(TaskModel task) async {
    print(
        '🔄 ReminderService.updateTaskReminder called for task: ${task.name}');
    print(
        '📋 Task details: ID=${task.id}, Due=${task.dueAt}, ReminderType=${task.reminderType}');

    try {
      // Cancel existing reminder and schedule new one
      await cancelTaskReminder(task.id);
      print('✅ Cancelled existing reminder for task: ${task.id}');

      // Schedule new reminder
      await scheduleTaskReminder(task);
      print('✅ New reminder scheduled for updated task: ${task.name}');
    } catch (e) {
      print('❌ Error updating task reminder: $e');
    }
  }

  // Enhanced method for handling task updates with multiple reminder types
  static Future<void> updateTaskReminders(
      TaskModel task, List<String> newReminderTypes) async {
    print(
        '🔄 ReminderService.updateTaskReminders called for task: ${task.name}');
    print(
        '📋 Task details: ID=${task.id}, Due=${task.dueAt}, NewReminderTypes=$newReminderTypes');

    try {
      // Cancel all existing reminders first
      await cancelTaskReminder(task.id);
      print('✅ Cancelled all existing reminders for task: ${task.id}');

      // Schedule new reminders
      await scheduleMultipleReminders(task, newReminderTypes);
      print('✅ All new reminders scheduled for updated task: ${task.name}');
    } catch (e) {
      print('❌ Error updating task reminders: $e');
    }
  }

  // Enhanced method for handling task updates with due date changes
  static Future<void> updateTaskReminderWithNewDueDate(
      TaskModel task, DateTime newDueDate) async {
    print(
        '🔄 ReminderService.updateTaskReminderWithNewDueDate called for task: ${task.name}');
    print(
        '📋 Task details: ID=${task.id}, OldDue=${task.dueAt}, NewDue=$newDueDate');

    try {
      // Cancel existing reminder
      await cancelTaskReminder(task.id);
      print('✅ Cancelled existing reminder for task: ${task.id}');

      // Create updated task model with new due date
      final updatedTask = task.copyWith(dueAt: newDueDate);

      // Schedule new reminder with updated due date
      await scheduleTaskReminder(updatedTask);
      print(
          '✅ New reminder scheduled for task with updated due date: ${task.name}');
    } catch (e) {
      print('❌ Error updating task reminder with new due date: $e');
    }
  }

  // Helper method to calculate reminder time based on due date
  static DateTime calculateReminderTime(DateTime dueDate, String reminderType) {
    // Calculate the intended reminder time
    DateTime intendedReminderTime;
    switch (reminderType) {
      case '15min':
        intendedReminderTime = dueDate.subtract(const Duration(minutes: 15));
        break;
      case '30min':
        intendedReminderTime = dueDate.subtract(const Duration(minutes: 30));
        break;
      case '1hour':
        intendedReminderTime = dueDate.subtract(const Duration(hours: 1));
        break;
      case '2hours':
        intendedReminderTime = dueDate.subtract(const Duration(hours: 2));
        break;
      case '3hours':
        intendedReminderTime = dueDate.subtract(const Duration(hours: 3));
        break;
      case '1day':
        intendedReminderTime = dueDate.subtract(const Duration(days: 1));
        break;
      default:
        intendedReminderTime = dueDate
            .subtract(const Duration(hours: 1)); // Default: 1 hour before
    }

    // Handle edge cases for tasks due very soon
    final now = DateTime.now();
    final timeUntilDue = dueDate.difference(now);

    // IMPROVED: Only send immediately for tasks due very soon (within 15 minutes)
    if (timeUntilDue.inMinutes < 15) {
      print(
          '⚠️ Task due very soon (${timeUntilDue.inMinutes} minutes). Scheduling reminder immediately.');
      return now.add(const Duration(seconds: 10)); // 10 seconds from now
    }

    // FIXED: For future tasks, if the calculated reminder time is in the past,
    // schedule it for a reasonable future time instead of the past
    if (intendedReminderTime.isBefore(now)) {
      print(
          '⚠️ Calculated reminder time ($intendedReminderTime) is in the past for future task. Rescheduling for reasonable time.');

      // Calculate a reasonable reminder time: minimum 30 minutes from now
      final reasonableReminderTime = now.add(const Duration(minutes: 30));

      // But don't schedule it after the task is due
      if (reasonableReminderTime.isAfter(dueDate)) {
        // If even 30 minutes from now would be after the task is due,
        // schedule it for 15 minutes before the task
        final lastMinuteReminder =
            dueDate.subtract(const Duration(minutes: 15));
        print(
            '✅ Rescheduled reminder to 15 minutes before due: $lastMinuteReminder');
        return lastMinuteReminder;
      }

      print(
          '✅ Rescheduled reminder to reasonable time: $reasonableReminderTime');
      return reasonableReminderTime;
    }

    // Calculate time until reminder for logging
    final timeUntilReminder = intendedReminderTime.difference(now);
    print(
        '✅ Reminder scheduled for: $intendedReminderTime (${timeUntilReminder.inMinutes} minutes from now)');
    return intendedReminderTime;
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
