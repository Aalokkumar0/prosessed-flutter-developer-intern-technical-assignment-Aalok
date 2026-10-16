import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/app_failure.dart';
import 'package:shopsphere/core/network/api_client.dart';

void main() {
  DioException responseError(int statusCode, {String? message}) => DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: statusCode,
      data: message == null ? null : {'message': message},
    ),
  );

  test('maps invalid credentials from a 400 response', () {
    final failure = mapNetworkError(
      responseError(400, message: 'Invalid credentials'),
    );
    expect(failure.message, 'Invalid credentials');
  });

  test('maps 401 to unauthorized failure', () {
    expect(mapNetworkError(responseError(401)).type, FailureType.unauthorized);
  });

  test('maps 404 to not-found failure', () {
    expect(mapNetworkError(responseError(404)).type, FailureType.notFound);
  });

  test('maps 500 to server failure', () {
    expect(mapNetworkError(responseError(500)).type, FailureType.server);
  });

  test('maps receive timeout to timeout failure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/slow'),
      type: DioExceptionType.receiveTimeout,
    );
    expect(mapNetworkError(error).type, FailureType.timeout);
  });

  test('maps connection errors to network failure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/offline'),
      type: DioExceptionType.connectionError,
    );
    expect(mapNetworkError(error).type, FailureType.network);
  });
}
