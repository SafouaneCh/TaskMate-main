part of 'tasks_cubit.dart';

sealed class TasksState {
  const TasksState();
}

final class TasksInitial extends TasksState {}

final class TasksLoading extends TasksState {}

final class TasksLoaded extends TasksState {
  final List<TaskModel> tasks;
  const TasksLoaded(this.tasks);
}

final class TasksError extends TasksState {
  final String error;
  TasksError(this.error);
}
