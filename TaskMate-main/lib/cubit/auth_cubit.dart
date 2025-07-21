import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/models/user_model.dart';
import 'package:taskmate/repository/auth_remote_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();

  void signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      emit(AuthLoading());

      final userModel = await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
