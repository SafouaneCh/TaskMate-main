import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_remote_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());
  final taskRemoteRepository = TaskRemoteRepository();

  Future<void> fetchTasks({required String token, DateTime? date}) async {
    try {
      emit(TasksLoading());
      final tasks =
          await taskRemoteRepository.getTasks(token: token, date: date);
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
    DateTime? filterDate,
  }) async {
    try {
      await taskRemoteRepository.updateTask(
        taskId: taskId,
        name: name,
        description: description,
        date: date,
        time: time,
        priority: priority,
        contact: contact,
        token: token,
      );
      // Refresh tasks after update with the filter date
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
      await taskRemoteRepository.deleteTask(
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
