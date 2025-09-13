// fraction_models.dart - 分数计算器数据模型

// 计算器状态枚举
enum CalculatorState {
  normal,          // 正常输入状态
  waitingForSecond, // 等待第二个操作数（二元运算）
  waitingForBase,   // 等待对数底数
  waitingForPower,  // 等待指数
  waitingForRoot,   // 等待根数
}

// 分数数据类
class Fraction {
  int integerPart;
  int numerator;
  int denominator;

  Fraction({
    this.integerPart = 0,
    this.numerator = 0,
    this.denominator = 1,
  });

  // 复制构造函数
  Fraction.copy(Fraction other)
      : integerPart = other.integerPart,
        numerator = other.numerator,
        denominator = other.denominator;

  @override
  String toString() {
    if (integerPart == 0 && numerator == 0) return "0";

    String result = "";
    if (integerPart != 0) result += integerPart.toString();
    if (numerator != 0) {
      if (integerPart != 0) result += " ";
      result += "$numerator/$denominator";
    }
    return result;
  }

  // 转换为小数
  double toDecimal() {
    double result = integerPart.abs().toDouble() + numerator.abs() / denominator;

    // 处理负数情况
    if (integerPart < 0 || numerator < 0) {
      result = -result;
    }

    return result;
  }

  // 检查是否为整数
  bool isInteger() {
    return numerator == 0;
  }

  // 检查是否为零
  bool isZero() {
    return integerPart == 0 && numerator == 0;
  }
}

// 计算结果类
class CalculatorResult {
  final bool success;
  final String? errorMessage;

  CalculatorResult({required this.success, this.errorMessage});

  // 成功结果工厂方法
  factory CalculatorResult.success() => CalculatorResult(success: true);

  // 错误结果工厂方法
  factory CalculatorResult.error(String message) =>
      CalculatorResult(success: false, errorMessage: message);
}

// 计算步骤类（用于历史记录）
class CalculationStep {
  final String operation;
  final String input;
  final String result;
  final String? detailProcess; // 详细计算过程
  final DateTime timestamp;

  CalculationStep({
    required this.operation,
    required this.input,
    required this.result,
    this.detailProcess,
    required this.timestamp,
  });
}

// 计算详情类（新增）
class CalculationDetails {
  final Fraction result;
  final String detailedSteps;

  CalculationDetails({
    required this.result,
    required this.detailedSteps,
  });
}

// 转换结果（带详细步骤）
class ConversionResultWithDetails {
  Fraction? mainResult;
  Fraction? firstResult;
  Fraction? secondResult;
  bool isDualResult = false;
  String detailedSteps = "";
}

// 通分结果（带详细步骤）
class CommonDenominatorResultWithDetails {
  Fraction? originalFirst;
  Fraction? originalSecond;
  Fraction? firstResult;
  Fraction? secondResult;
  String detailedSteps = "";
}

// ================== 运算结果类 ==================

// 转换结果
class ConversionResult {
  Fraction? mainResult;
  Fraction? firstResult;
  Fraction? secondResult;
  bool isDualResult = false;
}

// 对数运算结果
class LogarithmResult {
  Fraction? parameter;
  Fraction? calculationResult;
  Fraction? originalValue;
  String? displayFormat;
  String? calculationDetail;
}

// 幂运算结果
class PowerResult {
  Fraction? parameter;
  Fraction? calculationResult;
  Fraction? originalValue;
  String? displayFormat;
  String? calculationDetail;
}

// 根运算结果
class RootResult {
  Fraction? parameter;
  Fraction? calculationResult;
  Fraction? originalValue;
  String? displayFormat;
  String? calculationDetail;
}

// 通分结果
class CommonDenominatorResult {
  Fraction? originalFirst;
  Fraction? originalSecond;
  Fraction? firstResult;
  Fraction? secondResult;
}