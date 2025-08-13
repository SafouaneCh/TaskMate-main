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

      // Always schedule reminder for new tasks (since backend doesn't have reminder fields yet)
      // Create a task model with reminder enabled
      final taskWithReminder = taskModel.copyWith(
        hasReminder: true,
        reminderAt: taskModel.dueAt,
        reminderType: '1hour',
      );

      await ReminderService.scheduleTaskReminder(taskWithReminder);

      emit(AddNewTakSucess(taskModel));
    } catch (e) {
      emit(AddNewTakError(e.toString()));
    }
  }
}
