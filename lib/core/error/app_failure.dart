import 'package:equatable/equatable.dart';

enum FailureType {
  network,
  timeout,
  unauthorized,
  notFound,
  server,
  parsing,
  unknown,
}

class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message, {this.type = FailureType.unknown});

  final String message;
  final FailureType type;

  @override
  List<Object?> get props => [message, type];
}
