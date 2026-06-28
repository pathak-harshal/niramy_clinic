import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/firebase_auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService authService;

  AuthBloc(this.authService) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authService.signIn(email: event.email, password: event.password);
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authService.signUp(email: event.email, password: event.password);
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authService.signOut();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authService.resetPassword(email: event.email);
      emit(const PasswordResetSent());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
