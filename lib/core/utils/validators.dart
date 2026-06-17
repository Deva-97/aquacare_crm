class Validators {
  const Validators._();

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? mobile(String? value, {bool required = true}) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }
    final String? empty = requiredField(value, 'Mobile number');
    if (empty != null) {
      return empty;
    }
    final String normalized = value!.trim();
    final RegExp regex = RegExp(r'^\d{10}$');
    if (!regex.hasMatch(normalized)) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }
}
