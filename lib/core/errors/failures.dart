class Failure {
  Failure(this.message);

  final String message;
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class PermissionFailure extends Failure {
  PermissionFailure(super.message);
}
