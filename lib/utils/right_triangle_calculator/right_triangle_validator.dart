// ============================================================================
// lib/utils/right_triangle_validator.dart (修正版 - 添加math导入)
// ============================================================================

import 'dart:math' as math;

class ValidationResult {
  final bool isValid;
  final String message;

  const ValidationResult({required this.isValid, this.message = ''});
}

class RightTriangleValidator {
  static ValidationResult validateEdge(String? value) {
    if (value == null || value.isEmpty) {
      return const ValidationResult(isValid: true);
    }

    final num = double.tryParse(value);
    if (num == null || num <= 0) {
      return const ValidationResult(
          isValid: false,
          message: 'Edge length must be positive'
      );
    }
    return const ValidationResult(isValid: true);
  }

  static ValidationResult validateAngle(String? value) {
    if (value == null || value.isEmpty) {
      return const ValidationResult(isValid: true);
    }

    final num = double.tryParse(value);
    if (num == null || num <= 0 || num >= 90) {
      return const ValidationResult(
          isValid: false,
          message: 'Acute angle must be between 0-90 degrees'
      );
    }
    return const ValidationResult(isValid: true);
  }

  static ValidationResult validateArea(String? value) {
    if (value == null || value.isEmpty) {
      return const ValidationResult(isValid: true);
    }

    final num = double.tryParse(value);
    if (num == null || num <= 0) {
      return const ValidationResult(
          isValid: false,
          message: 'Area must be positive'
      );
    }
    return const ValidationResult(isValid: true);
  }

  static ValidationResult validateTriangle(double? a, double? b, double? c) {
    if (c != null && a != null && b != null) {
      // 检查勾股定理
      const tolerance = 0.001;
      final expected = math.sqrt(a * a + b * b);
      if ((c - expected).abs() > tolerance) {
        return const ValidationResult(
            isValid: false,
            message: 'Does not satisfy Pythagorean theorem'
        );
      }
    }

    if (c != null && a != null && a >= c) {
      return const ValidationResult(
          isValid: false,
          message: 'Hypotenuse must be greater than direct edge'
      );
    }

    if (c != null && b != null && b >= c) {
      return const ValidationResult(
          isValid: false,
          message: 'Hypotenuse must be greater than direct edge'
      );
    }

    return const ValidationResult(isValid: true);
  }
}