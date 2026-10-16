import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/app_failure.dart';
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
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    final hasSession = await _repository.hasSession();
    if (!hasSession) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      final user = await _repository.getCurrentUser();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AppFailure catch (failure) {
      await _repository.logout();
      emit(AuthState(status: AuthStatus.failure, message: failure.message));
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const AuthState(status: AuthStatus.checking));
    try {
      final user = await _repository.login(
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
    await _repository.logout();
    emit(AuthState(status: AuthStatus.unauthenticated, message: message));
  }
}
