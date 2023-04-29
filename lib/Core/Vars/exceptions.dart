//Unauthorised for HTTP Code 401
class Unauthorised implements Exception {
  final String message;

  Unauthorised({this.message = "Recheck sig-in credentials"});

  @override
  String toString() {
    return 'Exception: $message';
  }
}

//Forbidden for HTTP Code 403
class Forbidden implements Exception {
  final String message;

  Forbidden({this.message = "Access denied"});

  @override
  String toString() {
    return 'Exception: $message';
  }
}