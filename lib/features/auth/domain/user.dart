import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.image,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String image;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone, image];
}

abstract interface class AuthRepository {
  Future<User> login({required String username, required String password});
  Future<User> getCurrentUser();
  Future<bool> hasSession();
  Future<void> logout();
}
