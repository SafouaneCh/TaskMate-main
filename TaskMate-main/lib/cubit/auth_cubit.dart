import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/core/services/sp_service.dart';
import 'package:taskmate/models/user_model.dart';
import 'package:taskmate/core/services/onesignal_service.dart';
import 'package:taskmate/repository/auth_remote_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authRemoteRepository = AuthRemoteRepository();
  final spService = SpService();

  void getUserData() async {
    try {
      emit(AuthLoading());

      // Add a timeout to prevent infinite loading
      final userModel = await authRemoteRepository
          .getUserData()
          .timeout(Duration(seconds: 10));

      if (userModel != null) {
        // Ensure OneSignal subscription is linked to this user
        try {
          await OneSignalService.setExternalUserId(userModel.id);
        } catch (e) {
          print('Error linking OneSignal external user ID on boot: $e');
        }
        emit(AuthLoggedIn(userModel));
      } else {
        // If no user data found, go to login
        emit(AuthInitial());
      }
    } catch (e) {
      print('Error getting user data: $e');
      // If there's an error (network issue, etc.), go to login screen
      emit(AuthInitial());
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

      // Link OneSignal subscription to this user
      try {
        await OneSignalService.setExternalUserId(userModel.id);
      } catch (e) {
        print('Error linking OneSignal external user ID on login: $e');
      }

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void logout() async {
    try {
      // Logout from OneSignal and mark device inactive
      try {
        await OneSignalService.logout();
      } catch (e) {
        print('Error logging out from OneSignal: $e');
      }
      // Clear the stored token
      await spService.removeToken();
      // Emit initial state to go back to login
      emit(AuthInitial());
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, still emit initial state
      emit(AuthInitial());
    }
  }

  String getCurrentUserName() {
    if (state is AuthLoggedIn) {
      return (state as AuthLoggedIn).user.name;
    }
    return 'User';
  }
}
