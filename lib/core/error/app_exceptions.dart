abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException({required super.message, this.statusCode, super.code});
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code});
}

class UnknownException extends AppException {
  const UnknownException({super.message = 'An unexpected error occurred', super.code});
}
