enum ValidationStatus {
  valid,
  disabled,
  notRecognized,
}

class ValidationResult {
  const ValidationResult({
    required this.status,
    required this.serial,
  });

  final ValidationStatus status;
  final String serial;

  bool get isValid => status == ValidationStatus.valid;
  bool get isDisabled => status == ValidationStatus.disabled;
  bool get isNotRecognized => status == ValidationStatus.notRecognized;
}

