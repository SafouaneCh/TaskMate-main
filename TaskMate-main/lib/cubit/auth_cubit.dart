import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/core/services/sp_service.dart';
import 'package:taskmate/models/user_model.dart';
import 'package:taskmate/repository/auth_local_repository.dart';
import 'package:taskmate/repository/auth_remote_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final authLocalRepository = AuthLocalRepository();
  final spService = SpService();

  void getUserData() async {
    try {
      emit(AuthLoading());

      final userModel = await authRemoteRepository.getUserData();

      if (userModel != null) {
        await authLocalRepository.insertUser(userModel);
        emit(AuthLoggedIn(userModel));
        return;
      }

      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      emit(AuthLoading());

      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final userModel = await authRemoteRepository.login(
        name: name,
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        await spService.setToken(userModel.token);
      }

      await authLocalRepository.insertUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
