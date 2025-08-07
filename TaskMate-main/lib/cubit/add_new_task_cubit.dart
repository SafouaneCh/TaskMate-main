import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:taskmate/models/task_model.dart';
import 'package:taskmate/repository/task_remote_repository.dart';

part 'add_new_task_state.dart';

class AddNewTaskCubit extends Cubit<AddNewTaskState> {
  AddNewTaskCubit() : super(AddNewTakInitial());

  final taskRemoteRepository = TaskRemoteRepository();

  Future<void> createNewTask({
    required String name,
    required String description,
    required String priority,
    required String status,
    required List<Contact> contacts,
    required String token,
    required String date,
    required String time,
  }) async {
    try {
      emit(AddNewTakLoading());
      final contactString = contacts.map((c) => c.displayName).join(",");
      final taskModel = await taskRemoteRepository.createTask(
          name: name,
          description: description,
          date: date,
          time: time,
          priority: priority,
          contact: contactString,
          status: status,
          token: token);

      emit(AddNewTakSucess(taskModel));
    } catch (e) {
      emit(AddNewTakError(e.toString()));
    }
  }
}
