import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_remote_repository.dart';
import 'package:taskmate/core/services/reminder_service.dart';

part 'add_new_task_state.dart';

class AddNewTaskCubit extends Cubit<AddNewTaskState> {
  final TaskRemoteRepository _taskRepository = TaskRemoteRepository();

  AddNewTaskCubit() : super(AddNewTakInitial());

  Future<void> createNewTask({
    required String name,
    required String description,
    required String date,
    required String time,
    required String priority,
    required List<Contact> contacts, // Changed from contact to contacts
    required String token,
    String status = 'pending',
    String reminderType = '1hour', // Add reminder type parameter
    List<String> reminderTypes = const ['1hour'], // Support multiple reminders
  }) async {
    try {
      emit(AddNewTakLoading());

      // Convert contacts list to contact string
      final contactString = contacts.map((c) => c.displayName).join(", ");

      final taskModel = await _taskRepository.createTask(
        name: name,
        description: description,
        date: date,
        time: time,
        priority: priority,
        contact: contactString, // Convert to string for backend
        token: token,
        status: status,
      );

      // Schedule reminders for new tasks
      if (reminderTypes.isNotEmpty) {
        if (reminderTypes.length == 1) {
          // Single reminder
          final taskWithReminder = taskModel.copyWith(
            hasReminder: true,
            reminderAt: taskModel.dueAt,
            reminderType: reminderTypes.first,
          );
          await ReminderService.scheduleTaskReminder(taskWithReminder);
          print('✅ Single reminder scheduled for task: ${taskModel.name}');
        } else {
          // Multiple reminders
          final taskWithReminder = taskModel.copyWith(
            hasReminder: true,
            reminderAt: taskModel.dueAt,
            reminderType: reminderTypes.first, // Keep first as primary
          );
          await ReminderService.scheduleMultipleReminders(
              taskWithReminder, reminderTypes);
          print('✅ Multiple reminders scheduled for task: ${taskModel.name}');
        }
      }

      emit(AddNewTakSucess(taskModel));
    } catch (e) {
      emit(AddNewTakError(e.toString()));
    }
  }
}
