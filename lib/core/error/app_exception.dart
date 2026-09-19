sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'You appear to be offline.']);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Something went wrong. Please retry.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Content not found.']);
}

class CacheMissException extends AppException {
  const CacheMissException([super.message = 'Nothing cached yet.']);
}
