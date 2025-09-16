// fraction_operations.dart - 修复手写分数格式的完整版

import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'fraction_models.dart';

class FractionOperations {
  // ================== 基础运算方法 ==================

  // 约分
  static void simplifyFraction(Fraction fraction) {
    if (fraction.numerator == 0) return;
    int gcd = gcdCalculate(fraction.numerator.abs(), fraction.denominator.abs());
    fraction.numerator ~/= gcd;
    fraction.denominator ~/= gcd;
  }

  // 约分 - 返回详细步骤（仅限需要历史的运算使用）
  static CalculationDetails simplifyFractionWithDetails(Fraction fraction) {
    List<String> steps = [];

    if (fraction.numerator == 0) {
      steps.add("fraction_numerator_zero_no_simplify".tr());
      return CalculationDetails(result: fraction, detailedSteps: steps.join('\n'));
    }

    int originalNum = fraction.numerator;
    int originalDen = fraction.denominator;
    int gcd = gcdCalculate(originalNum.abs(), originalDen.abs());

    if (gcd == 1) {
      steps.add("fraction_step_find_gcd".tr());
      steps.add("fraction_gcd_calculation".tr(namedArgs: {
        'num': originalNum.toString(),
        'den': originalDen.toString(),
        'gcd': gcd.toString()
      }));
      steps.add("fraction_gcd_one_already_simplified".tr());
      steps.add("fraction_result_colon".tr(namedArgs: {'result': fraction.toString()}));
    } else {
      steps.add("fraction_step_find_gcd".tr());
      steps.add("fraction_gcd_calculation".tr(namedArgs: {
        'num': originalNum.toString(),
        'den': originalDen.toString(),
        'gcd': gcd.toString()
      }));
      steps.add("fraction_step_simplify".tr());
      steps.add("fraction_numerator_divide".tr(namedArgs: {
        'num': originalNum.toString(),
        'gcd': gcd.toString(),
        'result': (originalNum ~/ gcd).toString()
      }));
      steps.add("fraction_denominator_divide".tr(namedArgs: {
        'den': originalDen.toString(),
        'gcd': gcd.toString(),
        'result': (originalDen ~/ gcd).toString()
      }));

      fraction.numerator ~/= gcd;
      fraction.denominator ~/= gcd;

      steps.add("fraction_result_colon".tr(namedArgs: {'result': fraction.toString()}));
    }

    return CalculationDetails(result: fraction, detailedSteps: steps.join('\n'));
  }

  // 转换（带分数与假分数互转）
  static ConversionResult convertFraction(Fraction fraction) {
    ConversionResult result = ConversionResult();

    // 检查是否为带分数且分数部分是假分数
    bool isMixedWithImproperFraction = fraction.integerPart != 0 &&
        fraction.numerator > fraction.denominator;

    if (isMixedWithImproperFraction) {
      // 特殊情况：带分数中的分数部分是假分数
      // 给出两个结果：1) 正常带分数 2) 假分数

      // 1. 转换为正常带分数
      int additionalInteger = fraction.numerator ~/ fraction.denominator;
      int remainingNumerator = fraction.numerator % fraction.denominator;

      Fraction normalMixed = Fraction(
        integerPart: fraction.integerPart + additionalInteger,
        numerator: remainingNumerator,
        denominator: fraction.denominator,
      );

      // 2. 转换为假分数
      int totalNumerator = fraction.integerPart * fraction.denominator + fraction.numerator;
      Fraction improperFraction = Fraction(
        integerPart: 0,
        numerator: totalNumerator,
        denominator: fraction.denominator,
      );

      // 保存两个结果用于显示
      result.isDualResult = true;
      result.firstResult = normalMixed;
      result.secondResult = improperFraction;
      result.mainResult = normalMixed; // 主显示为正常带分数

    } else if (fraction.integerPart != 0 && fraction.numerator != 0) {
      // 带分数转假分数
      int newNumerator = fraction.integerPart * fraction.denominator + fraction.numerator;
      result.mainResult = Fraction(
        integerPart: 0,
        numerator: newNumerator,
        denominator: fraction.denominator,
      );
      result.isDualResult = false;

    } else if (fraction.numerator > fraction.denominator) {
      // 假分数转带分数
      result.mainResult = Fraction(
        integerPart: fraction.numerator ~/ fraction.denominator,
        numerator: fraction.numerator % fraction.denominator,
        denominator: fraction.denominator,
      );
      result.isDualResult = false;
    } else {
      result.mainResult = Fraction.copy(fraction);
      result.isDualResult = false;
    }

    return result;
  }

  // 转换 - 返回详细步骤（仅限需要历史的运算使用）
  static ConversionResultWithDetails convertFractionWithDetails(Fraction fraction) {
    ConversionResultWithDetails result = ConversionResultWithDetails();
    List<String> steps = [];

    // 检查是否为带分数且分数部分是假分数
    bool isMixedWithImproperFraction = fraction.integerPart != 0 &&
        fraction.numerator > fraction.denominator;

    if (isMixedWithImproperFraction) {
      steps.add("fraction_step_identify_mixed_improper".tr());
      steps.add("fraction_mixed_improper_description".tr(namedArgs: {
        'fraction': fraction.toString(),
        'num': fraction.numerator.toString(),
        'den': fraction.denominator.toString()
      }));
      steps.add("fraction_step_two_conversion_methods".tr());

      // 1. 转换为正常带分数
      int additionalInteger = fraction.numerator ~/ fraction.denominator;
      int remainingNumerator = fraction.numerator % fraction.denominator;
      steps.add("fraction_method_normal_mixed".tr());
      steps.add("fraction_division_remainder".tr(namedArgs: {
        'num': fraction.numerator.toString(),
        'den': fraction.denominator.toString(),
        'quotient': additionalInteger.toString(),
        'remainder': remainingNumerator.toString()
      }));
      steps.add("fraction_integer_addition".tr(namedArgs: {
        'int1': fraction.integerPart.toString(),
        'int2': additionalInteger.toString(),
        'sum': (fraction.integerPart + additionalInteger).toString()
      }));

      Fraction normalMixed = Fraction(
        integerPart: fraction.integerPart + additionalInteger,
        numerator: remainingNumerator,
        denominator: fraction.denominator,
      );

      // 2. 转换为假分数
      int totalNumerator = fraction.integerPart * fraction.denominator + fraction.numerator;
      steps.add("fraction_method_improper".tr());
      steps.add("fraction_improper_calculation".tr(namedArgs: {
        'int': fraction.integerPart.toString(),
        'den': fraction.denominator.toString(),
        'num': fraction.numerator.toString(),
        'result': totalNumerator.toString()
      }));

      Fraction improperFraction = Fraction(
        integerPart: 0,
        numerator: totalNumerator,
        denominator: fraction.denominator,
      );

      result.isDualResult = true;
      result.firstResult = normalMixed;
      result.secondResult = improperFraction;
      result.mainResult = normalMixed;

      steps.add("fraction_result1_colon".tr(namedArgs: {'result': normalMixed.toString()}));
      steps.add("fraction_result2_colon".tr(namedArgs: {'result': improperFraction.toString()}));
      steps.add("fraction_dual_result".tr(namedArgs: {
        'result1': normalMixed.toString(),
        'result2': improperFraction.toString()
      }));

    } else if (fraction.integerPart != 0 && fraction.numerator != 0) {
      // 带分数转假分数
      steps.add("fraction_step_mixed_to_improper".tr());
      steps.add("fraction_mixed_to_improper_calc".tr(namedArgs: {
        'int': fraction.integerPart.toString(),
        'den': fraction.denominator.toString(),
        'num': fraction.numerator.toString()
      }));
      int newNumerator = fraction.integerPart * fraction.denominator + fraction.numerator;
      steps.add("fraction_mixed_to_improper_result".tr(namedArgs: {
        'product': (fraction.integerPart * fraction.denominator).toString(),
        'num': fraction.numerator.toString(),
        'total': newNumerator.toString(),
        'den': fraction.denominator.toString()
      }));

      result.mainResult = Fraction(
        integerPart: 0,
        numerator: newNumerator,
        denominator: fraction.denominator,
      );
      steps.add("fraction_result_colon".tr(namedArgs: {'result': result.mainResult!.toString()}));
      result.isDualResult = false;

    } else if (fraction.numerator > fraction.denominator) {
      // 假分数转带分数
      steps.add("fraction_step_improper_to_mixed".tr());
      steps.add("fraction_division_expression".tr(namedArgs: {
        'num': fraction.numerator.toString(),
        'den': fraction.denominator.toString()
      }));
      int intPart = fraction.numerator ~/ fraction.denominator;
      int remNum = fraction.numerator % fraction.denominator;
      steps.add("fraction_division_result".tr(namedArgs: {
        'quotient': intPart.toString(),
        'remainder': remNum.toString()
      }));

      result.mainResult = Fraction(
        integerPart: intPart,
        numerator: remNum,
        denominator: fraction.denominator,
      );
      steps.add("fraction_result_colon".tr(namedArgs: {'result': result.mainResult!.toString()}));
      result.isDualResult = false;
    } else {
      steps.add("fraction_already_proper_form".tr());
      result.mainResult = Fraction.copy(fraction);
      result.isDualResult = false;
    }

    result.detailedSteps = steps.join('\n');
    return result;
  }

  // 倒数
  static Fraction reciprocal(Fraction fraction) {
    if (fraction.numerator == 0 && fraction.integerPart == 0) {
      throw Exception("error_no_reciprocal".tr());
    }
    int numerator = fraction.integerPart * fraction.denominator + fraction.numerator;
    if (numerator == 0) throw Exception("error_no_reciprocal".tr());

    Fraction result = Fraction(
      integerPart: 0,
      numerator: fraction.denominator,
      denominator: numerator.abs(),
    );
    if (numerator < 0) {
      result.numerator = -result.numerator;
    }
    return result;
  }

  // 倒数 - 返回详细步骤（仅限需要历史的运算使用）
  static CalculationDetails reciprocalWithDetails(Fraction fraction) {
    List<String> steps = [];

    if (fraction.numerator == 0 && fraction.integerPart == 0) {
      throw Exception("error_no_reciprocal".tr());
    }

    steps.add("fraction_step_calculate_reciprocal".tr());

    if (fraction.integerPart != 0) {
      steps.add("fraction_first_convert_to_improper".tr());
      int numerator = fraction.integerPart * fraction.denominator + fraction.numerator;
      steps.add("fraction_multiply_add_calculation".tr(namedArgs: {
        'int': fraction.integerPart.toString(),
        'den': fraction.denominator.toString(),
        'num': fraction.numerator.toString(),
        'result': numerator.toString()
      }));
      steps.add("fraction_get_improper".tr(namedArgs: {
        'num': numerator.toString(),
        'den': fraction.denominator.toString()
      }));
      steps.add("fraction_step_find_reciprocal".tr());
      steps.add("fraction_reciprocal_explanation".tr(namedArgs: {
        'num': numerator.toString(),
        'den': fraction.denominator.toString(),
        'rec_num': fraction.denominator.toString(),
        'rec_den': numerator.toString()
      }));

      if (numerator == 0) throw Exception("error_no_reciprocal".tr());

      Fraction result = Fraction(
        integerPart: 0,
        numerator: fraction.denominator,
        denominator: numerator.abs(),
      );
      if (numerator < 0) {
        result.numerator = -result.numerator;
        steps.add("fraction_negative_reciprocal".tr());
      }

      // 检查是否可以约分
      int gcd = gcdCalculate(result.numerator.abs(), result.denominator);
      if (gcd > 1) {
        steps.add("fraction_step_simplify_reciprocal".tr());
        steps.add("fraction_gcd_calculation".tr(namedArgs: {
          'num': result.numerator.abs().toString(),
          'den': result.denominator.toString(),
          'gcd': gcd.toString()
        }));
        result.numerator ~/= gcd;
        result.denominator ~/= gcd;
        steps.add("fraction_after_simplify".tr(namedArgs: {'result': result.toString()}));
      }

      return CalculationDetails(result: result, detailedSteps: steps.join('\n'));
    } else {
      steps.add("fraction_simple_reciprocal".tr(namedArgs: {
        'num': fraction.numerator.toString(),
        'den': fraction.denominator.toString(),
        'rec_num': fraction.denominator.toString(),
        'rec_den': fraction.numerator.toString()
      }));

      Fraction result = Fraction(
        integerPart: 0,
        numerator: fraction.denominator,
        denominator: fraction.numerator.abs(),
      );
      if (fraction.numerator < 0) {
        result.numerator = -result.numerator;
        steps.add("fraction_negative_reciprocal".tr());
      }

      // 检查是否可以约分
      int gcd = gcdCalculate(result.numerator.abs(), result.denominator);
      if (gcd > 1) {
        steps.add("fraction_step_simplify_reciprocal".tr());
        steps.add("fraction_gcd_calculation".tr(namedArgs: {
          'num': result.numerator.abs().toString(),
          'den': result.denominator.toString(),
          'gcd': gcd.toString()
        }));
        result.numerator ~/= gcd;
        result.denominator ~/= gcd;
        steps.add("fraction_after_simplify".tr(namedArgs: {'result': result.toString()}));
      }

      return CalculationDetails(result: result, detailedSteps: steps.join('\n'));
    }
  }

  // 简化运算方法（不需要历史的运算使用）
  static Fraction square(Fraction fraction) {
    return multiplyFractions(fraction, fraction);
  }

  static Fraction cube(Fraction fraction) {
    Fraction squared = multiplyFractions(fraction, fraction);
    return multiplyFractions(squared, fraction);
  }

  static Fraction squareRoot(Fraction fraction) {
    double decimal = fraction.toDecimal();
    if (decimal < 0) throw Exception("error_negative_sqrt".tr());
    double result = math.sqrt(decimal).toDouble();
    return doubleToFraction(result);
  }

  static Fraction cubeRoot(Fraction fraction) {
    double decimal = fraction.toDecimal();
    double result = math.pow(decimal, 1.0/3.0).toDouble();
    return doubleToFraction(result);
  }

  static Fraction naturalLogarithm(Fraction fraction) {
    double decimal = fraction.toDecimal();
    if (decimal <= 0) throw Exception("error_log_argument".tr());
    double result = math.log(decimal).toDouble();
    return doubleToFraction(result);
  }

  // ================== 特殊运算方法（简化版本，不需要历史） ==================

  // 对数运算（简化版本）
  static LogarithmResult performLogarithm(Fraction baseNumber, Fraction? currentFraction, bool isCurrentInputDecimal, double currentDecimalValue) {
    LogarithmResult result = LogarithmResult();

    Fraction base;
    double baseValue;

    if (isCurrentInputDecimal) {
      baseValue = currentDecimalValue;
      base = doubleToFraction(currentDecimalValue);
    } else if (currentFraction != null && (currentFraction.integerPart != 0 || currentFraction.numerator != 0)) {
      base = Fraction.copy(currentFraction);
      baseValue = base.toDecimal();
    } else {
      base = Fraction(integerPart: 10, numerator: 0, denominator: 1);
      baseValue = 10.0;
    }

    double argumentValue = baseNumber.toDecimal();

    if (baseValue <= 0 || baseValue == 1) {
      throw Exception("error_log_base".tr());
    }

    if (argumentValue <= 0) {
      throw Exception("error_log_argument".tr());
    }

    double logResult;
    if (baseValue == 10) {
      logResult = (math.log(argumentValue) / math.ln10).toDouble();
    } else {
      double lnArg = math.log(argumentValue).toDouble();
      double lnBase = math.log(baseValue).toDouble();
      logResult = (lnArg / lnBase).toDouble();
    }

    result.parameter = base;
    result.calculationResult = doubleToFraction(logResult);
    result.originalValue = baseNumber;

    return result;
  }

  // 幂运算（简化版本）
  static PowerResult performPower(Fraction baseNumber, Fraction? currentFraction, bool isCurrentInputDecimal, double currentDecimalValue) {
    PowerResult result = PowerResult();

    Fraction exponent;
    double exponentValue;

    if (isCurrentInputDecimal) {
      exponentValue = currentDecimalValue;
      exponent = doubleToFraction(currentDecimalValue);
    } else if (currentFraction != null && (currentFraction.integerPart != 0 || currentFraction.numerator != 0)) {
      exponent = Fraction.copy(currentFraction);
      exponentValue = exponent.toDecimal();
    } else {
      exponent = Fraction(integerPart: 4, numerator: 0, denominator: 1);
      exponentValue = 4.0;
    }

    double baseValue = baseNumber.toDecimal();

    if (baseValue == 0 && exponentValue <= 0) {
      throw Exception("error_zero_power".tr());
    }

    double powerResult = math.pow(baseValue, exponentValue).toDouble();

    result.parameter = exponent;
    result.calculationResult = doubleToFraction(powerResult);
    result.originalValue = baseNumber;

    return result;
  }

  // 根运算（简化版本）
  static RootResult performRoot(Fraction baseNumber, Fraction? currentFraction, bool isCurrentInputDecimal, double currentDecimalValue) {
    RootResult result = RootResult();

    Fraction rootIndex;
    double rootValue;

    if (isCurrentInputDecimal) {
      rootValue = currentDecimalValue;
      rootIndex = doubleToFraction(currentDecimalValue);
    } else if (currentFraction != null && (currentFraction.integerPart != 0 || currentFraction.numerator != 0)) {
      rootIndex = Fraction.copy(currentFraction);
      rootValue = rootIndex.toDecimal();
    } else {
      rootIndex = Fraction(integerPart: 4, numerator: 0, denominator: 1);
      rootValue = 4.0;
    }

    double radicandValue = baseNumber.toDecimal();

    if (rootValue == 0) {
      throw Exception("error_root_zero".tr());
    }

    if (radicandValue < 0 && rootValue % 2 == 0) {
      throw Exception("error_even_root_negative".tr());
    }

    double rootResult;
    if (radicandValue < 0) {
      rootResult = (-math.pow(-radicandValue, 1.0 / rootValue)).toDouble();
    } else {
      rootResult = math.pow(radicandValue, 1.0 / rootValue).toDouble();
    }

    if (rootResult.isInfinite || rootResult.isNaN) {
      throw Exception("error_invalid_result".tr());
    }

    result.parameter = rootIndex;
    result.calculationResult = doubleToFraction(rootResult);
    result.originalValue = baseNumber;

    return result;
  }

  // ================== 二元运算方法 ==================

  // 通分操作
  static CommonDenominatorResult performCommonDenominator(Fraction a, Fraction b) {
    CommonDenominatorResult result = CommonDenominatorResult();

    // 保存原始操作数
    result.originalFirst = Fraction.copy(a);
    result.originalSecond = Fraction.copy(b);

    // 直接对分数部分进行通分，保持整数部分不变
    int lcmValue = lcm(a.denominator, b.denominator);

    // 计算通分后的分数部分分子
    int newNum1 = a.numerator * (lcmValue ~/ a.denominator);
    int newNum2 = b.numerator * (lcmValue ~/ b.denominator);

    // 保持带分数格式，只改变分数部分
    result.firstResult = Fraction(
      integerPart: a.integerPart,  // 保持原整数部分
      numerator: newNum1,          // 通分后的分子
      denominator: lcmValue,       // 公分母
    );

    result.secondResult = Fraction(
      integerPart: b.integerPart,  // 保持原整数部分
      numerator: newNum2,          // 通分后的分子
      denominator: lcmValue,       // 公分母
    );

    return result;
  }

  // 通分操作 - 返回详细步骤（仅限需要历史的运算使用）
  static CommonDenominatorResultWithDetails performCommonDenominatorWithDetails(Fraction a, Fraction b) {
    CommonDenominatorResultWithDetails result = CommonDenominatorResultWithDetails();
    List<String> stepsList = [];

    // 保存原始操作数
    result.originalFirst = Fraction.copy(a);
    result.originalSecond = Fraction.copy(b);

    // 判断是否有带分数
    bool hasIntegerPart = a.integerPart != 0 || b.integerPart != 0;

    if (hasIntegerPart) {
      stepsList.add("fraction_step_identify_mixed".tr());
      if (a.integerPart != 0) {
        stepsList.add("fraction_first_is_mixed".tr(namedArgs: {'fraction': a.toString()}));
      }
      if (b.integerPart != 0) {
        stepsList.add("fraction_second_is_mixed".tr(namedArgs: {'fraction': b.toString()}));
      }
      stepsList.add("fraction_common_keep_integer".tr());
    } else {
      stepsList.add("fraction_step_identify_fraction_type".tr());
      stepsList.add("fraction_both_proper_improper".tr());
    }

    stepsList.add("fraction_step_find_lcm".tr());
    int lcmValue = lcm(a.denominator, b.denominator);
    stepsList.add("fraction_lcm_calculation".tr(namedArgs: {
      'den1': a.denominator.toString(),
      'den2': b.denominator.toString(),
      'lcm': lcmValue.toString()
    }));

    // 计算各分母需要乘的倍数
    stepsList.add("fraction_step_calculate_multipliers".tr());
    int multiplier1 = lcmValue ~/ a.denominator;
    int multiplier2 = lcmValue ~/ b.denominator;
    stepsList.add("fraction_multiplier1".tr(namedArgs: {
      'lcm': lcmValue.toString(),
      'den': a.denominator.toString(),
      'mult': multiplier1.toString()
    }));
    stepsList.add("fraction_multiplier2".tr(namedArgs: {
      'lcm': lcmValue.toString(),
      'den': b.denominator.toString(),
      'mult': multiplier2.toString()
    }));

    stepsList.add("fraction_step_common_denominator".tr());

    // 计算通分后的分数部分分子
    int newNum1 = a.numerator * multiplier1;
    int newNum2 = b.numerator * multiplier2;

    // 显示通分过程 - 修复：统一使用 FRACTION 标记
    if (a.integerPart != 0) {
      stepsList.add("fraction_mixed_common_part".tr(namedArgs: {'fraction': a.toString()}));
      stepsList.add("${a.numerator}/${a.denominator} = [FRACTION:${a.numerator}×${multiplier1}:${a.denominator}×${multiplier1}] = ${newNum1}/${lcmValue}");
      stepsList.add("fraction_so_mixed_result".tr(namedArgs: {
        'fraction': a.toString(),
        'int': a.integerPart.toString(),
        'num': newNum1.toString(),
        'den': lcmValue.toString()
      }));
    } else {
      stepsList.add("${a.numerator}/${a.denominator} = [FRACTION:${a.numerator}×${multiplier1}:${a.denominator}×${multiplier1}] = ${newNum1}/${lcmValue}");
    }

    if (b.integerPart != 0) {
      stepsList.add("fraction_mixed_common_part".tr(namedArgs: {'fraction': b.toString()}));
      stepsList.add("${b.numerator}/${b.denominator} = [FRACTION:${b.numerator}×${multiplier2}:${b.denominator}×${multiplier2}] = ${newNum2}/${lcmValue}");
      stepsList.add("fraction_so_mixed_result".tr(namedArgs: {
        'fraction': b.toString(),
        'int': b.integerPart.toString(),
        'num': newNum2.toString(),
        'den': lcmValue.toString()
      }));
    } else {
      stepsList.add("${b.numerator}/${b.denominator} = [FRACTION:${b.numerator}×${multiplier2}:${b.denominator}×${multiplier2}] = ${newNum2}/${lcmValue}");
    }

    // 保持带分数格式，只改变分数部分
    result.firstResult = Fraction(
      integerPart: a.integerPart,  // 保持原整数部分
      numerator: newNum1,          // 通分后的分子
      denominator: lcmValue,       // 公分母
    );

    result.secondResult = Fraction(
      integerPart: b.integerPart,  // 保持原整数部分
      numerator: newNum2,          // 通分后的分子
      denominator: lcmValue,       // 公分母
    );

    stepsList.add("fraction_result_colon".tr(namedArgs: {
      'result': "${result.firstResult!.toString()}, ${result.secondResult!.toString()}"
    }));
    result.detailedSteps = stepsList.join('\n');

    return result;
  }

  // 二元运算执行 - 返回详细计算步骤（仅限需要历史的运算使用）
  static CalculationDetails performBinaryOperation(String operation, Fraction first, Fraction second) {
    List<String> stepsList = [];

    // 转换为假分数
    Fraction firstImproper = convertToImproper(first);
    Fraction secondImproper = convertToImproper(second);

    // 步骤1：转换为假分数（如果需要）
    if (first.integerPart != 0 || second.integerPart != 0) {
      stepsList.add("fraction_step_convert_to_improper".tr());
      if (first.integerPart != 0) {
        int num1 = first.integerPart * first.denominator + first.numerator;
        stepsList.add("fraction_mixed_to_improper_show".tr(namedArgs: {
          'fraction': first.toString(),        // 改：second -> first
          'int': first.integerPart.toString(), // 改：second -> first
          'den': first.denominator.toString(), // 改：second -> first
          'num': first.numerator.toString(),   // 改：second -> first
          'result': num1.toString()            // 改：num2 -> num1
        }));
      }
      if (second.integerPart != 0) {         // 添加：处理第二个分数
        int num2 = second.integerPart * second.denominator + second.numerator;
        stepsList.add("fraction_mixed_to_improper_show".tr(namedArgs: {
          'fraction': second.toString(),
          'int': second.integerPart.toString(),
          'den': second.denominator.toString(),
          'num': second.numerator.toString(),
          'result': num2.toString()
        }));
      }
    }

    Fraction result;

    switch (operation) {
      case '加法':
        result = performAddition(firstImproper, secondImproper, stepsList);
        break;
      case '减法':
        result = performSubtraction(firstImproper, secondImproper, stepsList);
        break;
      case '乘法':
        result = performMultiplication(firstImproper, secondImproper, stepsList);
        break;
      case '除法':
        List<String> divisionSteps = [];
        result = performDivision(firstImproper, secondImproper, divisionSteps);
        stepsList.addAll(divisionSteps);
        break;
      default:
        throw Exception("fraction_unimplemented_binary_operation".tr(namedArgs: {'operation': operation}));
    }

    return CalculationDetails(
      result: result,
      detailedSteps: stepsList.join('\n'),
    );
  }

  // 转换为假分数
  static Fraction convertToImproper(Fraction fraction) {
    if (fraction.integerPart == 0) return Fraction.copy(fraction);

    int numerator = fraction.integerPart * fraction.denominator + fraction.numerator;
    return Fraction(
      integerPart: 0,
      numerator: numerator,
      denominator: fraction.denominator,
    );
  }

  // 执行加法运算
  static Fraction performAddition(Fraction first, Fraction second, List<String> stepsList) {
    print("=== performAddition 调试 ===");
    print("first: ${first.integerPart} ${first.numerator}/${first.denominator}");
    print("second: ${second.integerPart} ${second.numerator}/${second.denominator}");
    stepsList.add("fraction_step_addition".tr());

    if (first.denominator == second.denominator) {
      // 同分母直接相加
      stepsList.add("fraction_same_denominator_add".tr());
      stepsList.add("fraction_add_numerators".tr(namedArgs: {
        'num1': first.numerator.toString(),
        'num2': second.numerator.toString(),
        'sum': (first.numerator + second.numerator).toString()
      }));

      Fraction result = Fraction(
              integerPart: 0,
              numerator: first.numerator + second.numerator,
              denominator: first.denominator,
            );

            print("加法计算结果：${result.integerPart} ${result.numerator}/${result.denominator}");

            addSimplificationSteps(result, stepsList);

            print("约分后结果：${result.integerPart} ${result.numerator}/${result.denominator}");

            return result;
    } else {
      // 不同分母需要通分
      stepsList.add("fraction_different_denominators_need_common".tr());
      int lcmValue = lcm(first.denominator, second.denominator);
      stepsList.add("fraction_lcm_result".tr(namedArgs: {
        'den1': first.denominator.toString(),
        'den2': second.denominator.toString(),
        'lcm': lcmValue.toString()
      }));

      int newNum1 = first.numerator * (lcmValue ~/ first.denominator);
      int newNum2 = second.numerator * (lcmValue ~/ second.denominator);

      stepsList.add("[FRACTION:${first.numerator}:${first.denominator}] = [FRACTION:${first.numerator} × ${lcmValue ~/ first.denominator}:${lcmValue}] = [FRACTION:${newNum1}:${lcmValue}]");
      stepsList.add("[FRACTION:${second.numerator}:${second.denominator}] = [FRACTION:${second.numerator} × ${lcmValue ~/ second.denominator}:${lcmValue}] = [FRACTION:${newNum2}:${lcmValue}]");
      stepsList.add("fraction_add_after_common".tr(namedArgs: {
        'num1': newNum1.toString(),
        'num2': newNum2.toString(),
        'sum': (newNum1 + newNum2).toString()
      }));

      Fraction result = Fraction(
        integerPart: 0,
        numerator: newNum1 + newNum2,
        denominator: lcmValue,
      );

      addSimplificationSteps(result, stepsList);
      return result;
    }
  }

  // 执行减法运算
  static Fraction performSubtraction(Fraction first, Fraction second, List<String> stepsList) {
    stepsList.add("fraction_step_subtraction".tr());

    if (first.denominator == second.denominator) {
      stepsList.add("fraction_same_denominator_subtract".tr());
      stepsList.add("fraction_subtract_numerators".tr(namedArgs: {
        'num1': first.numerator.toString(),
        'num2': second.numerator.toString(),
        'diff': (first.numerator - second.numerator).toString()
      }));

      Fraction result = Fraction(
        integerPart: 0,
        numerator: first.numerator - second.numerator,
        denominator: first.denominator,
      );

      addSimplificationSteps(result, stepsList);
      return result;
    } else {
      stepsList.add("fraction_different_denominators_need_common".tr());
      int lcmValue = lcm(first.denominator, second.denominator);
      stepsList.add("fraction_lcm_result".tr(namedArgs: {
        'den1': first.denominator.toString(),
        'den2': second.denominator.toString(),
        'lcm': lcmValue.toString()
      }));

      int newNum1 = first.numerator * (lcmValue ~/ first.denominator);
      int newNum2 = second.numerator * (lcmValue ~/ second.denominator);

      stepsList.add("[FRACTION:${first.numerator}:${first.denominator}] = [FRACTION:${first.numerator} × ${lcmValue ~/ first.denominator}:${lcmValue}] = [FRACTION:${newNum1}:${lcmValue}]");
      stepsList.add("[FRACTION:${second.numerator}:${second.denominator}] = [FRACTION:${second.numerator} × ${lcmValue ~/ second.denominator}:${lcmValue}] = [FRACTION:${newNum2}:${lcmValue}]");
      stepsList.add("fraction_subtract_after_common".tr(namedArgs: {
        'num1': newNum1.toString(),
        'num2': newNum2.toString(),
        'diff': (newNum1 - newNum2).toString()
      }));

      Fraction result = Fraction(
        integerPart: 0,
        numerator: newNum1 - newNum2,
        denominator: lcmValue,
      );

      addSimplificationSteps(result, stepsList);
      return result;
    }
  }

  // 执行乘法运算
  static Fraction performMultiplication(Fraction first, Fraction second, List<String> stepsList) {
    stepsList.add("fraction_step_multiplication".tr());
    stepsList.add("fraction_multiply_rule".tr());

    int newNumerator = first.numerator * second.numerator;
    int newDenominator = first.denominator * second.denominator;

    stepsList.add("[FRACTION:${first.numerator}×${second.numerator}:${first.denominator}×${second.denominator}] = [FRACTION:${newNumerator}:${newDenominator}]");

    Fraction result = Fraction(
      integerPart: 0,
      numerator: newNumerator,
      denominator: newDenominator,
    );

    addSimplificationSteps(result, stepsList);
    return result;
  }

  // 执行除法运算
  static Fraction performDivision(Fraction first, Fraction second, List<String> stepsList) {
    if (second.numerator == 0) throw Exception("error_divider_zero".tr());

    stepsList.add("fraction_step_division".tr());
    stepsList.add("fraction_division_to_multiplication".tr());

    stepsList.add("[FRACTION:${first.numerator}:${first.denominator}] ÷ [FRACTION:${second.numerator}:${second.denominator}] = [FRACTION:${first.numerator}:${first.denominator}] × [FRACTION:${second.denominator}:${second.numerator}]");

    int newNumerator = first.numerator * second.denominator;
    int newDenominator = first.denominator * second.numerator;

    stepsList.add("= [FRACTION:${newNumerator}:${newDenominator.abs()}]");

    Fraction result = Fraction(
      integerPart: 0,
      numerator: newNumerator,
      denominator: newDenominator.abs(),
    );

    // 处理负号
    if (newDenominator < 0) {
      result.numerator = -result.numerator;
    }

    addSimplificationSteps(result, stepsList);
    return result;
  }

  // 添加约分步骤
  static void addSimplificationSteps(Fraction fraction, List<String> stepsList) {
    if (fraction.numerator == 0) return;

    int originalNumerator = fraction.numerator;
    int originalDenominator = fraction.denominator;

    int gcd = gcdCalculate(fraction.numerator.abs(), fraction.denominator.abs());

    if (gcd > 1) {
      stepsList.add("fraction_step_final_simplify".tr());
      stepsList.add("fraction_gcd_final".tr(namedArgs: {
        'num': originalNumerator.toString(),
        'den': originalDenominator.toString(),
        'gcd': gcd.toString()
      }));

      fraction.numerator ~/= gcd;
      fraction.denominator ~/= gcd;

      stepsList.add("fraction_after_final_simplify".tr(namedArgs: {
        'num': fraction.numerator.toString(),
        'den': fraction.denominator.toString()
      }));
    }

    // 转换为带分数
    if (fraction.numerator.abs() >= fraction.denominator) {
      stepsList.add("fraction_step_convert_to_mixed".tr());

      int integerPart = fraction.numerator ~/ fraction.denominator;
      int remainingNumerator = fraction.numerator % fraction.denominator;

      stepsList.add("fraction_division_to_mixed".tr(namedArgs: {
        'num': fraction.numerator.toString(),
        'den': fraction.denominator.toString(),
        'quotient': integerPart.toString(),
        'remainder': remainingNumerator.toString()
      }));

      fraction.integerPart = integerPart;
      fraction.numerator = remainingNumerator;

      if (remainingNumerator == 0) {
        stepsList.add("fraction_final_result_integer".tr(namedArgs: {'result': fraction.integerPart.toString()}));
      } else {
        stepsList.add("fraction_final_result_mixed".tr(namedArgs: {'result': fraction.toString()}));
      }
    }
  }

  // ================== 辅助方法 ==================

  // 分数乘法
  static Fraction multiplyFractions(Fraction a, Fraction b) {
    // 转换为假分数
    int num1 = a.integerPart * a.denominator + a.numerator;
    int num2 = b.integerPart * b.denominator + b.numerator;

    // 处理负数情况
    if (a.integerPart < 0) {
      num1 = -(a.integerPart.abs() * a.denominator + a.numerator);
    }
    if (b.integerPart < 0) {
      num2 = -(b.integerPart.abs() * b.denominator + b.numerator);
    }
    if (a.numerator < 0) {
      num1 = -num1.abs();
    }
    if (b.numerator < 0) {
      num2 = -num2.abs();
    }

    int newNumerator = num1 * num2;
    int newDenominator = a.denominator * b.denominator;

    return simplifyAndConvert(newNumerator, newDenominator);
  }

  // 简化并转换
  static Fraction simplifyAndConvert(int numerator, int denominator) {
    if (denominator == 0) throw Exception("error_denominator_zero".tr());

    bool isNegative = (numerator < 0) ^ (denominator < 0);
    numerator = numerator.abs();
    denominator = denominator.abs();

    int gcd = gcdCalculate(numerator, denominator);
    numerator ~/= gcd;
    denominator ~/= gcd;

    int integerPart = numerator ~/ denominator;
    int remainingNumerator = numerator % denominator;

    if (isNegative) {
      if (integerPart != 0) {
        integerPart = -integerPart;
      } else if (remainingNumerator != 0) {
        remainingNumerator = -remainingNumerator;
      }
    }

    return Fraction(
      integerPart: integerPart,
      numerator: remainingNumerator,
      denominator: denominator,
    );
  }

  // 小数转分数
  static Fraction doubleToFraction(double value) {
    if (value.isInfinite || value.isNaN) {
      throw Exception("fraction_cannot_convert_to_fraction".tr());
    }

    if (value.abs() < 1e-15) {
      return Fraction(integerPart: 0, numerator: 0, denominator: 1);
    }

    int integerPart = value.truncate();
    double fractionalPart = value - integerPart;

    if (fractionalPart.abs() < 1e-15) {
      return Fraction(integerPart: integerPart, numerator: 0, denominator: 1);
    }

    // 使用逼近算法找到最简分数
    return approximateFraction(integerPart, fractionalPart);
  }

  // 分数逼近算法
  static Fraction approximateFraction(int integerPart, double fractionalPart) {
    double x = fractionalPart.abs();

    // 尝试常见分母
    List<int> commonDenominators = [2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 30, 32, 36, 40, 45, 48, 50, 60, 64, 72, 75, 80, 90, 96, 100];

    double bestError = double.infinity;
    int bestNumerator = 0;
    int bestDenominator = 1;

    for (int denominator in commonDenominators) {
      int numerator = (x * denominator).round();
      double error = (x - numerator / denominator).abs();

      if (error < bestError && error < 1e-10) {
        bestError = error;
        bestNumerator = numerator;
        bestDenominator = denominator;

        // 如果误差极小，直接使用
        if (error < 1e-15) break;
      }
    }

    // 如果没找到好的近似，使用较大分母
    if (bestError > 1e-10) {
      bestDenominator = 1000;
      bestNumerator = (x * bestDenominator).round();
    }

    // 处理负数
    if (fractionalPart < 0) {
      bestNumerator = -bestNumerator;
    }

    return simplifyAndConvert(
      integerPart * bestDenominator + bestNumerator,
      bestDenominator,
    );
  }

  // 最大公约数
  static int gcdCalculate(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  // 最小公倍数
  static int lcm(int a, int b) {
    return (a.abs() * b.abs()) ~/ gcdCalculate(a, b);
  }
}