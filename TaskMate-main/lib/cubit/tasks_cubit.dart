import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_hybrid_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());
  final taskHybridRepository = TaskHybridRepository();

  Future<void> fetchTasks({required String token, DateTime? date}) async {
    try {
      emit(TasksLoading());
      final tasks =
          await taskHybridRepository.getTasks(token: token, date: date);
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  void refreshTasks({required String token, DateTime? date}) {
    fetchTasks(token: token, date: date);
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
    DateTime? filterDate,
  }) async {
    try {
      await taskHybridRepository.updateTask(
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
      // Refresh tasks after update with the filter date
      fetchTasks(token: token, date: filterDate);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String status,
    required String token,
    DateTime? filterDate,
  }) async {
    try {
      await taskHybridRepository.updateTaskStatus(
        taskId: taskId,
        status: status,
        token: token,
      );
      // Refresh tasks after status update with the filter date
      fetchTasks(token: token, date: filterDate);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  Future<void> deleteTask({
    required String taskId,
    required String token,
    DateTime? date,
  }) async {
    try {
      await taskHybridRepository.deleteTask(
        taskId: taskId,
        token: token,
      );
      // Refresh tasks after delete with the same date
      fetchTasks(token: token, date: date);
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
