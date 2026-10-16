import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
import '../domain/auth_use_cases.dart';
import '../domain/user.dart';

enum AuthStatus { checking, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.checking, this.user, this.message});

  final AuthStatus status;
  final User? user;
  final String? message;

  @override
  List<Object?> get props => [status, user, message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._useCases) : super(const AuthState());

  final AuthUseCases _useCases;

  Future<void> restoreSession() async {
    final hasSession = await _useCases.hasSession();
    if (!hasSession) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      final user = await _useCases.restoreSession();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppFailure catch (failure) {
      await _useCases.logout();
      emit(AuthState(status: AuthStatus.failure, message: failure.message));
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const AuthState(status: AuthStatus.checking));
    try {
      final user = await _useCases.login(
        username: username.trim(),
        password: password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppFailure catch (failure) {
      final message = failure.message.toLowerCase().contains('invalid')
          ? 'Invalid username or password.'
          : failure.message;
      emit(AuthState(status: AuthStatus.failure, message: message));
    }
  }

  Future<void> logout({String? message}) async {
    await _useCases.logout();
    emit(AuthState(status: AuthStatus.unauthenticated, message: message));
  }
}
