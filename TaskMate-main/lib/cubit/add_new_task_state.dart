part of 'add_new_task_cubit.dart';

sealed class AddNewTaskState {
  const AddNewTaskState();
}

final class AddNewTakInitial extends AddNewTaskState {}

final class AddNewTakLoading extends AddNewTaskState {}

final class AddNewTakError extends AddNewTaskState {
  final String error;
  AddNewTakError(this.error);
}

final class AddNewTakSucess extends AddNewTaskState {
  final TaskModel taskModel;
  const AddNewTakSucess(this.taskModel);
}
