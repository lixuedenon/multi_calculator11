// ============================================================================
// lib/utils/right_triangle_calculator.dart
// ============================================================================

import 'dart:math' as math;

class TriangleResult {
  final double? a;
  final double? b;
  final double? c;
  final double? angleA;
  final double? angleB;
  final double? area;
  final double? perimeter;

  const TriangleResult({
    this.a,
    this.b,
    this.c,
    this.angleA,
    this.angleB,
    this.area,
    this.perimeter,
  });

  TriangleResult copyWith({
    double? a,
    double? b,
    double? c,
    double? angleA,
    double? angleB,
    double? area,
    double? perimeter,
  }) {
    return TriangleResult(
      a: a ?? this.a,
      b: b ?? this.b,
      c: c ?? this.c,
      angleA: angleA ?? this.angleA,
      angleB: angleB ?? this.angleB,
      area: area ?? this.area,
      perimeter: perimeter ?? this.perimeter,
    );
  }
}

class RightTriangleCalculator {
  static String formatNumber(double? num) {
    if (num == null) return '';
    if (num == num.roundToDouble()) {
      return num.round().toString();
    }
    return num.toStringAsFixed(2);
  }

  static bool checkSufficientConditions({
    String? a,
    String? b,
    String? c,
    String? angleA,
    String? angleB,
    String? area,
  }) {
    final edges = [a, b, c].where((x) => x != null && x.isNotEmpty && double.tryParse(x) != null && double.parse(x) > 0).length;
    final angles = [angleA, angleB].where((x) => x != null && x.isNotEmpty && double.tryParse(x) != null && double.parse(x) > 0 && double.parse(x) < 90).length;
    final hasArea = area != null && area.isNotEmpty && double.tryParse(area) != null && double.parse(area) > 0;

    // 两条边
    if (edges >= 2) return true;
    // 一边 + 一角
    if (edges >= 1 && angles >= 1) return true;
    // 面积 + 一边
    if (hasArea && edges >= 1) return true;

    return false;
  }

  static TriangleResult? calculate({
    String? a,
    String? b,
    String? c,
    String? angleA,
    String? angleB,
    String? area,
  }) {
    try {
      // 转换为数字
      final numA = a != null && a.isNotEmpty ? double.tryParse(a) : null;
      final numB = b != null && b.isNotEmpty ? double.tryParse(b) : null;
      final numC = c != null && c.isNotEmpty ? double.tryParse(c) : null;
      final numAngleA = angleA != null && angleA.isNotEmpty ? double.tryParse(angleA) : null;
      final numAngleB = angleB != null && angleB.isNotEmpty ? double.tryParse(angleB) : null;
      final numArea = area != null && area.isNotEmpty ? double.tryParse(area) : null;

      var result = TriangleResult(
        a: numA,
        b: numB,
        c: numC,
        angleA: numAngleA,
        angleB: numAngleB,
        area: numArea,
      );

      // 情况1：两条直角边
      if (numA != null && numB != null && numC == null) {
        final c = math.sqrt(numA * numA + numB * numB);
        final angleA = math.atan(numA / numB) * 180 / math.pi;
        final angleB = 90 - angleA;
        final area = 0.5 * numA * numB;
        result = result.copyWith(c: c, angleA: angleA, angleB: angleB, area: area);
      }
      // 情况2：一条直角边 + 斜边
      else if (numA != null && numC != null && numB == null) {
        final b = math.sqrt(numC * numC - numA * numA);
        final angleA = math.asin(numA / numC) * 180 / math.pi;
        final angleB = 90 - angleA;
        final area = 0.5 * numA * b;
        result = result.copyWith(b: b, angleA: angleA, angleB: angleB, area: area);
      }
      else if (numB != null && numC != null && numA == null) {
        final a = math.sqrt(numC * numC - numB * numB);
        final angleA = math.atan(a / numB) * 180 / math.pi;
        final angleB = 90 - angleA;
        final area = 0.5 * a * numB;
        result = result.copyWith(a: a, angleA: angleA, angleB: angleB, area: area);
      }
      // 情况3：斜边 + 一锐角
      else if (numC != null && numAngleA != null && numAngleB == null) {
        final angleB = 90 - numAngleA;
        final a = numC * math.sin(numAngleA * math.pi / 180);
        final b = numC * math.cos(numAngleA * math.pi / 180);
        final area = 0.5 * a * b;
        result = result.copyWith(a: a, b: b, angleB: angleB, area: area);
      }
      else if (numC != null && numAngleB != null && numAngleA == null) {
        final angleA = 90 - numAngleB;
        final a = numC * math.sin(angleA * math.pi / 180);
        final b = numC * math.cos(angleA * math.pi / 180);
        final area = 0.5 * a * b;
        result = result.copyWith(a: a, b: b, angleA: angleA, area: area);
      }
      // 情况4：直角边 + 锐角
      else if (numA != null && numAngleA != null && numAngleB == null) {
        final angleB = 90 - numAngleA;
        final b = numA / math.tan(numAngleA * math.pi / 180);
        final c = numA / math.sin(numAngleA * math.pi / 180);
        final area = 0.5 * numA * b;
        result = result.copyWith(b: b, c: c, angleB: angleB, area: area);
      }
      else if (numA != null && numAngleB != null && numAngleA == null) {
        final angleA = 90 - numAngleB;
        final b = numA * math.tan(numAngleB * math.pi / 180);
        final c = numA / math.cos(numAngleB * math.pi / 180);
        final area = 0.5 * numA * b;
        result = result.copyWith(b: b, c: c, angleA: angleA, area: area);
      }
      else if (numB != null && numAngleA != null && numAngleB == null) {
        final angleB = 90 - numAngleA;
        final a = numB * math.tan(numAngleA * math.pi / 180);
        final c = numB / math.cos(numAngleA * math.pi / 180);
        final area = 0.5 * a * numB;
        result = result.copyWith(a: a, c: c, angleB: angleB, area: area);
      }
      else if (numB != null && numAngleB != null && numAngleA == null) {
        final angleA = 90 - numAngleB;
        final a = numB / math.tan(numAngleB * math.pi / 180);
        final c = numB / math.sin(numAngleB * math.pi / 180);
        final area = 0.5 * a * numB;
        result = result.copyWith(a: a, c: c, angleA: angleA, area: area);
      }
      // 情况5：面积 + 一条直角边
      else if (numArea != null && numA != null && numB == null && numC == null) {
        final b = 2 * numArea / numA;
        final c = math.sqrt(numA * numA + b * b);
        final angleA = math.atan(numA / b) * 180 / math.pi;
        final angleB = 90 - angleA;
        result = result.copyWith(b: b, c: c, angleA: angleA, angleB: angleB);
      }
      else if (numArea != null && numB != null && numA == null && numC == null) {
        final a = 2 * numArea / numB;
        final c = math.sqrt(a * a + numB * numB);
        final angleA = math.atan(a / numB) * 180 / math.pi;
        final angleB = 90 - angleA;
        result = result.copyWith(a: a, c: c, angleA: angleA, angleB: angleB);
      }
      // 情况6：面积 + 斜边
      else if (numArea != null && numC != null && numA == null && numB == null) {
        final s = numArea;
        final discriminant = numC * numC * numC * numC - 16 * s * s;
        if (discriminant >= 0) {
          final x2 = (numC * numC + math.sqrt(discriminant)) / 2;
          final a = math.sqrt(x2);
          final b = 2 * s / a;
          final angleA = math.atan(a / b) * 180 / math.pi;
          final angleB = 90 - angleA;
          result = result.copyWith(a: a, b: b, angleA: angleA, angleB: angleB);
        }
      }

      // 计算周长
      if (result.a != null && result.b != null && result.c != null) {
        final perimeter = result.a! + result.b! + result.c!;
        result = result.copyWith(perimeter: perimeter);
      }

      return result;
    } catch (e) {
      return null;
    }
  }
}