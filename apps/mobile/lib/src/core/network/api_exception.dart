class ApiException implements Exception {
  final String code;
  final String message;
  final int? status;
  final Object? details;

  const ApiException({required this.code, required this.message, this.status, this.details});

  @override
  String toString() => 'ApiException($status, $code): $message';
}

