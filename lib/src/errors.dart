class CascadeCliException implements Exception {
  CascadeCliException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CascadeApiException implements Exception {
  CascadeApiException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}
