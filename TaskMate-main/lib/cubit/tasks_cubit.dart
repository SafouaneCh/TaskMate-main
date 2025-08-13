import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_remote_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TaskRemoteRepository _taskRepository = TaskRemoteRepository();

  TasksCubit() : super(TasksInitial());

  // Keep the old method name for compatibility
  Future<void> fetchTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) async {
    try {
      emit(TasksLoading());

      final tasks = await _taskRepository.getTasks(
        token: token,
        date: date,
      );

      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  // Add refresh method for compatibility
  void refreshTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) {
    fetchTasks(token: token, userId: userId, date: date);
  }

  // Keep the new method name as well
  Future<void> getTasks({
    required String token,
    required String userId,
    DateTime? date,
  }) async {
    await fetchTasks(token: token, userId: userId, date: date);
  }

  Future<void> updateTask({
    required String taskId,
    required String name,
    required String description,
    required String date,
    required String time,
    required String priority,
    required String contact,
    required String token,
    String? status,
  }) async {
    try {
      emit(TasksLoading());

      final updatedTask = await _taskRepository.updateTask(
        taskId: taskId,
        name: name,
        description: description,
        date: date,
        time: time,
        priority: priority,
        contact: contact,
        token: token,
        status: status,
      );

      // Refresh tasks list
      await fetchTasks(token: token, userId: '', date: null);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String status,
    required String token,
  }) async {
    try {
      emit(TasksLoading());

      await _taskRepository.updateTaskStatus(
        taskId: taskId,
        status: status,
        token: token,
      );

      // Refresh tasks list
      await fetchTasks(token: token, userId: '', date: null);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> deleteTask({
    required String taskId,
    required String token,
  }) async {
    try {
      emit(TasksLoading());

      await _taskRepository.deleteTask(
        taskId: taskId,
        token: token,
      );

      // Refresh tasks list
      await fetchTasks(token: token, userId: '', date: null);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
