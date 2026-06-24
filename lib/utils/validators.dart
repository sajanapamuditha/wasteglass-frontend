// lib/utils/validators.dart

class Validators {
  static String? validateKg(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0)    return 'Cannot be negative';
    if (n > 9999) return 'Value too high';
    return null;
  }

  static String? validateCondition(String? value) {
    if (value == null || value.isEmpty) return 'Please select a condition';
    return null;
  }
}
