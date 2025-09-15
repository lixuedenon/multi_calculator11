// fraction_input_handler.dart - 完整版（添加百分比功能）

import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'fraction_models.dart';
import 'fraction_operations.dart';

class FractionInputHandler {
  // 输入状态
  String integerInput = "";
  String numeratorInput = "0";
  String denominatorInput = "1";
  bool hasInputDenominator = false;

  // 当前分数
  Fraction currentFraction = Fraction();

  // 计算状态
  CalculatorState currentState = CalculatorState.normal;
  bool waitingForSecondOperand = false;
  String? pendingBinaryOperation;
  Fraction? firstOperand;
  Fraction? secondOperand;
  Fraction? calculationResult;
  Fraction? originalValue;
  String? lastOperation;
  bool isUnaryResult = false;

  // 纯数值计算相关状态
  double? firstNumericOperand;
  double? secondNumericOperand;
  double? numericResult;
  bool isPureNumericCalculation = false;

  // 特殊运算的参数
  Fraction? baseNumber;
  Fraction? parameter;

  // 通分专用数据
  Fraction? originalFirstOperand;
  Fraction? originalSecondOperand;
  Fraction? firstCommonResult;
  Fraction? secondCommonResult;

  // 双转换结果
  bool dualConversionResult = false;
  Fraction? firstConversionResult;
  Fraction? secondConversionResult;

  // 检查当前输入是否为小数
  bool get isCurrentInputDecimal => integerInput.isNotEmpty && integerInput.contains('.');

  // 检查是否为纯小数输入
  bool isPureDecimalInput() {
    return integerInput.isNotEmpty &&
        integerInput.contains('.') &&
        numeratorInput == "0" &&
        denominatorInput == "1" &&
        !hasInputDenominator;
  }

  // 检查是否为纯整数输入
  bool isPureIntegerInput() {
    return integerInput.isNotEmpty &&
        !integerInput.contains('.') &&
        numeratorInput == "0" &&
        denominatorInput == "1" &&
        !hasInputDenominator;
  }

  // 检查是否有分数部分输入
  bool hasAnyFractionInput() {
    return numeratorInput != "0" || hasInputDenominator || denominatorInput != "1";
  }

  // 检查当前是否为纯数值输入（整数或小数，无分数部分）
  bool isPureNumberInput() {
    return (isPureDecimalInput() || isPureIntegerInput()) && !hasAnyFractionInput();
  }

  // 获取当前输入的小数值
  double getCurrentDecimalValue() {
    if (integerInput.isNotEmpty && integerInput.contains('.')) {
      try {
        return double.parse(integerInput);
      } catch (e) {
        return 0.0;
      }
    }
    return currentFraction.toDecimal();
  }

  // 获取当前输入的数值（用于纯数值计算）
  double getCurrentNumericValue() {
    if (integerInput.isNotEmpty) {
      try {
        return double.parse(integerInput);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // 检查是否有有效的当前输入
  bool hasValidCurrentInput() {
    if (integerInput.isNotEmpty && integerInput.contains('.')) {
      try {
        double value = double.parse(integerInput);
        return value != 0.0;
      } catch (e) {
        return false;
      }
    }

    if (integerInput.isNotEmpty && integerInput != "0") {
      return true;
    }

    return numeratorInput != "0" ||
        hasInputDenominator ||
        currentFraction.integerPart != 0 ||
        currentFraction.numerator != 0;
  }

  // 更新当前分数显示
  void updateCurrentFraction() {
    try {
      if (integerInput.isNotEmpty && integerInput.contains('.')) {
        int numerator = int.parse(numeratorInput);
        int denominator = int.parse(denominatorInput);

        currentFraction = Fraction(
          integerPart: 0,
          numerator: numerator,
          denominator: denominator,
        );
        return;
      }

      int integerPart = 0;
      if (integerInput.isNotEmpty) {
        integerPart = int.parse(integerInput);
      }

      int numerator = int.parse(numeratorInput);
      int denominator = int.parse(denominatorInput);

      currentFraction = Fraction(
        integerPart: integerPart,
        numerator: numerator,
        denominator: denominator,
      );
    } catch (e) {
      print("updateCurrentFraction error: $e");
    }
  }

  // 智能格式转换的结果更新
  void updateInputsFromFraction() {
    Fraction fraction = calculationResult!;

    // 规则1：结果为0
    if (fraction.integerPart == 0 && fraction.numerator == 0) {
      integerInput = "";
      numeratorInput = "0";
      denominatorInput = "1";
      return;
    }

    // 先进行约分
    Fraction simplified = Fraction.copy(fraction);
    FractionOperations.simplifyFraction(simplified);

    // 处理分子等于分母的情况
    if (simplified.numerator != 0 && simplified.numerator.abs() == simplified.denominator) {
      if (simplified.numerator > 0) {
        simplified = Fraction(
          integerPart: simplified.integerPart + 1,
          numerator: 0,
          denominator: simplified.denominator
        );
      } else {
        simplified = Fraction(
          integerPart: simplified.integerPart - 1,
          numerator: 0,
          denominator: simplified.denominator
        );
      }
    }

    // 规则2：结果为整数
    if (simplified.numerator == 0) {
      integerInput = simplified.integerPart.toString();
      numeratorInput = "0";
      denominatorInput = "1";
      return;
    }

    // 规则3：假分数转带分数（分子绝对值≥分母）
    if (simplified.integerPart == 0 && simplified.numerator.abs() >= simplified.denominator) {
      int absNum = simplified.numerator.abs();
      int intPart = absNum ~/ simplified.denominator;
      int remNum = absNum % simplified.denominator;

      if (simplified.numerator < 0) {
        intPart = -intPart;
      }

      integerInput = intPart.toString();
      numeratorInput = remNum.toString();
      denominatorInput = simplified.denominator.toString();
      return;
    }

    // 规则4：其他情况保持格式
    if (simplified.integerPart != 0) {
      integerInput = simplified.integerPart.toString();
      numeratorInput = simplified.numerator.abs().toString();
    } else {
      integerInput = "";
      numeratorInput = simplified.numerator.toString();
    }

    denominatorInput = simplified.denominator.toString();
  }

  // 处理整数部分输入
  CalculatorResult handleIntegerInput(String input) {
    try {
      if (calculationResult != null && input != 'C' && input != '⌫' && input != '%') {
        clearAllForNewCalculation();
      }

      switch (input) {
        case 'C':
          integerInput = "";
          break;
        case 'D↔F':
          return handleOperator('分数小数转换');
        case '.':
          if (!integerInput.contains('.')) {
            if (integerInput.isEmpty) {
              integerInput = "0.";
            } else {
              integerInput += input;
            }
          }
          break;
        case '⌫':
          if (integerInput.isNotEmpty) {
            integerInput = integerInput.substring(0, integerInput.length - 1);
          }
          break;
        default:
          if (integerInput == "0") {
            integerInput = input;
          } else {
            integerInput += input;
          }
          break;
      }

      updateCurrentFraction();
      return CalculatorResult.success();
    } catch (e) {
      return CalculatorResult.error("error_invalid_result".tr());
    }
  }

  // 处理分子输入
  CalculatorResult handleNumeratorInput(String input) {
    try {
      if (calculationResult != null) {
        clearAllForNewCalculation();
      }

      if (input == '⌫') {
        if (numeratorInput.length > 1) {
          numeratorInput = numeratorInput.substring(0, numeratorInput.length - 1);
        } else {
          numeratorInput = "0";
        }
      } else {
        if (numeratorInput == "0") {
          numeratorInput = input;
        } else {
          numeratorInput += input;
        }
      }

      updateCurrentFraction();
      return CalculatorResult.success();
    } catch (e) {
      return CalculatorResult.error("error_invalid_result".tr());
    }
  }

  // 处理分母输入
  CalculatorResult handleDenominatorInput(String input) {
    try {
      if (calculationResult != null) {
        clearAllForNewCalculation();
      }

      if (input == '⌫') {
        if (denominatorInput.length > 1) {
          denominatorInput = denominatorInput.substring(0, denominatorInput.length - 1);
        } else {
          denominatorInput = "1";
          hasInputDenominator = false;
        }
      } else {
        if (!hasInputDenominator && denominatorInput == "1") {
          denominatorInput = input;
          hasInputDenominator = true;
        } else {
          denominatorInput += input;
        }
      }

      updateCurrentFraction();
      return CalculatorResult.success();
    } catch (e) {
      return CalculatorResult.error("error_invalid_result".tr());
    }
  }

  // 清除分子
  CalculatorResult handleNumeratorClear() {
    numeratorInput = "0";
    updateCurrentFraction();
    return CalculatorResult.success();
  }

  // 清除分母
  CalculatorResult handleDenominatorClear() {
    denominatorInput = "1";
    hasInputDenominator = false;
    updateCurrentFraction();
    return CalculatorResult.success();
  }
  // 处理运算符
    CalculatorResult handleOperator(String operator) {
      try {
        if (calculationResult != null && !waitingForSecondOperand && currentState == CalculatorState.normal) {
          bool isShowingResult = !hasValidCurrentInput() || (calculationResult != null && isFractionEqual(currentFraction, calculationResult!));

          if (isShowingResult) {
            currentFraction = Fraction.copy(calculationResult!);
            updateInputsFromFraction();
            clearPreviousCalculationState();
          }
        }

        if (!hasValidCurrentInput()) {
          return CalculatorResult.error("error_input_first".tr());
        }

        if (hasInputDenominator && denominatorInput == "0") {
          return CalculatorResult.error("error_denominator_zero".tr());
        }

        // 根据运算类型处理
        if (isImmediateUnaryOperation(operator)) {
          return performImmediateUnaryOperation(operator);
        } else if (isSpecialUnaryOperation(operator)) {
          return prepareSpecialUnaryOperation(operator);
        } else if (isBinaryOperation(operator)) {
          return prepareBinaryOperation(operator);
        }

        return CalculatorResult.error("error_invalid_result".tr());
      } catch (e) {
        return CalculatorResult.error("error_invalid_result".tr());
      }
    }

    // 判断运算类型的方法
    bool isImmediateUnaryOperation(String operator) {
      return ['约分', '转换', '倒数', '平方', '立方', '平方根', '立方根', '自然对数', '分数小数转换'].contains(operator);
    }

    bool isSpecialUnaryOperation(String operator) {
      return ['对数', 'n次方', 'n次根'].contains(operator);
    }

    bool isBinaryOperation(String operator) {
      return ['加法', '减法', '乘法', '除法', '通分'].contains(operator);
    }

    // 准备二元运算
    CalculatorResult prepareBinaryOperation(String operator) {
      if (!waitingForSecondOperand) {
        bool currentIsPureNumber = isPureNumberInput();
        isPureNumericCalculation = currentIsPureNumber;

        if (currentIsPureNumber) {
          double currentValue = getCurrentNumericValue();
          firstNumericOperand = currentValue;
          firstOperand = FractionOperations.doubleToFraction(currentValue);
        } else {
          isPureNumericCalculation = false;
          if (isCurrentInputDecimal) {
            double decimalValue = getCurrentDecimalValue();
            firstOperand = FractionOperations.doubleToFraction(decimalValue);
          } else {
            Fraction fraction = Fraction.copy(currentFraction);
            firstOperand = fraction;
          }
          firstNumericOperand = null;
        }

        pendingBinaryOperation = operator;
        waitingForSecondOperand = true;
        currentState = CalculatorState.waitingForSecond;

        // 保存完数值后再清空输入
        integerInput = "";
        numeratorInput = "0";
        denominatorInput = "1";
        hasInputDenominator = false;
        currentFraction = Fraction();
      }

      return CalculatorResult.success();
    }

    // 执行立即一元运算
    CalculatorResult performImmediateUnaryOperation(String operator) {
      bool isPureNumber = isPureNumberInput();

      if (isPureNumber) {
        double numericValue = getCurrentNumericValue();

        try {
          double resultValue;
          switch (operator) {
            case '平方':
              resultValue = numericValue * numericValue;
              break;
            case '立方':
              resultValue = numericValue * numericValue * numericValue;
              break;
            case '平方根':
              if (numericValue < 0) throw Exception("error_negative_sqrt".tr());
              resultValue = math.sqrt(numericValue);
              break;
            case '立方根':
              resultValue = math.pow(numericValue, 1.0/3.0).toDouble();
              break;
            case '自然对数':
              if (numericValue <= 0) throw Exception("error_log_argument".tr());
              resultValue = math.log(numericValue);
              break;
            case '倒数':
              if (numericValue == 0) throw Exception("error_no_reciprocal".tr());
              resultValue = 1.0 / numericValue;
              break;

            default:
              return performFractionUnaryOperation(operator);
          }

          isPureNumericCalculation = true;
          numericResult = resultValue;
          calculationResult = FractionOperations.doubleToFraction(resultValue);
          currentFraction = calculationResult!;
          lastOperation = operator;
          isUnaryResult = true;

          originalValue = FractionOperations.doubleToFraction(numericValue);

          updateInputsFromFraction();
          currentState = CalculatorState.normal;
          waitingForSecondOperand = false;
          pendingBinaryOperation = null;
          firstOperand = null;
          secondOperand = null;

          return CalculatorResult.success();
        } catch (e) {
          return CalculatorResult.error("error_invalid_result".tr());
        }
      } else {
        return performFractionUnaryOperation(operator);
      }
    }

    // 分数一元运算
    CalculatorResult performFractionUnaryOperation(String operator) {
      if (isCurrentInputDecimal) {
        double decimalValue = getCurrentDecimalValue();
        originalValue = FractionOperations.doubleToFraction(decimalValue);
      } else {
        Fraction fraction = Fraction.copy(currentFraction);
        originalValue = fraction;
      }

      try {
        switch (operator) {
          case '约分':
            CalculationDetails details = FractionOperations.simplifyFractionWithDetails(originalValue!);
            currentFraction = details.result;
            break;
          case '转换':
            ConversionResultWithDetails convDetails = FractionOperations.convertFractionWithDetails(originalValue!);
            currentFraction = convDetails.mainResult!;
            dualConversionResult = convDetails.isDualResult;
            if (convDetails.isDualResult) {
              firstConversionResult = convDetails.firstResult;
              secondConversionResult = convDetails.secondResult;
            }
            break;
          case '倒数':
            CalculationDetails recipDetails = FractionOperations.reciprocalWithDetails(originalValue!);
            currentFraction = recipDetails.result;
            break;
          case '平方':
            currentFraction = FractionOperations.square(originalValue!);
            break;
          case '立方':
            currentFraction = FractionOperations.cube(originalValue!);
            break;
          case '平方根':
            currentFraction = FractionOperations.squareRoot(originalValue!);
            break;
          case '立方根':
            currentFraction = FractionOperations.cubeRoot(originalValue!);
            break;
          case '自然对数':
            currentFraction = FractionOperations.naturalLogarithm(originalValue!);
            break;
          case '分数小数转换':
            // 智能转换：分数→小数 或 小数→分数
            if (isCurrentInputDecimal) {
              // 小数转分数
              double decimalValue = originalValue!.toDecimal();
              currentFraction = FractionOperations.doubleToFraction(decimalValue);
            } else {
              // 分数转小数（显示为特殊标记，在显示层处理）
              double decimalValue = originalValue!.toDecimal();
              currentFraction = FractionOperations.doubleToFraction(decimalValue);
              // 设置特殊标记表示这是分数转小数的结果
            }
            break;
          default:
            return CalculatorResult.error("error_invalid_result".tr());
        }

        calculationResult = Fraction.copy(currentFraction);
        lastOperation = operator;
        isUnaryResult = true;

        updateInputsFromFraction();
        currentState = CalculatorState.normal;
        waitingForSecondOperand = false;
        pendingBinaryOperation = null;
        firstOperand = null;
        secondOperand = null;

        return CalculatorResult.success();
      } catch (e) {
        return CalculatorResult.error(e.toString());
      }
    }

    // 处理计算
    CalculatorResult handleCalculate() {
      try {
        if (calculationResult != null && currentState == CalculatorState.normal && !waitingForSecondOperand) {
          currentFraction = Fraction.copy(calculationResult!);
          resetForNewCalculation();
          return CalculatorResult.success();
        }

        switch (currentState) {
          case CalculatorState.normal:
            updateCurrentFraction();
            return CalculatorResult.success();
          case CalculatorState.waitingForSecond:
            if (waitingForSecondOperand && (firstOperand != null || firstNumericOperand != null) && pendingBinaryOperation != null) {
              return performBinaryOperation();
            }
            break;
          case CalculatorState.waitingForBase:
            return performLogarithm();
          case CalculatorState.waitingForPower:
            return performPower();
          case CalculatorState.waitingForRoot:
            return performRoot();
        }

        return CalculatorResult.success();
      } catch (e) {
        return CalculatorResult.error("error_invalid_result".tr());
      }
    }
  // 执行二元运算
    CalculatorResult performBinaryOperation() {
      if (pendingBinaryOperation == null) {
        return CalculatorResult.error("error_invalid_result".tr());
      }

      if (firstNumericOperand == null && firstOperand == null) {
        return CalculatorResult.error("error_input_first".tr());
      }

      if (!hasValidCurrentInput()) {
        return CalculatorResult.error("error_input_second".tr());
      }

      String operation = pendingBinaryOperation!;
      bool firstIsPureNumber = firstNumericOperand != null;
      bool secondIsPureNumber = isPureNumberInput();
      bool bothArePureNumbers = firstIsPureNumber && secondIsPureNumber;

      try {
        if (bothArePureNumbers && operation != '通分') {
          isPureNumericCalculation = true;
          return performPureNumericBinaryOperation(operation);
        } else {
          isPureNumericCalculation = false;
          return performFractionBinaryOperation(operation);
        }
      } catch (e) {
        return CalculatorResult.error("error_invalid_result".tr());
      }
    }

    // 纯数值二元运算
    CalculatorResult performPureNumericBinaryOperation(String operation) {
      if (firstNumericOperand == null) {
        return CalculatorResult.error("error_input_first".tr());
      }

      double firstValue = firstNumericOperand!;
      double secondValue = getCurrentNumericValue();

      double resultValue;

      switch (operation) {
        case '加法':
          resultValue = firstValue + secondValue;
          break;
        case '减法':
          resultValue = firstValue - secondValue;
          break;
        case '乘法':
          resultValue = firstValue * secondValue;
          break;
        case '除法':
          if (secondValue == 0) throw Exception("error_divider_zero".tr());
          resultValue = firstValue / secondValue;
          break;
        default:
          throw Exception("error_invalid_result".tr());
      }

      isPureNumericCalculation = true;
      numericResult = resultValue;
      calculationResult = FractionOperations.doubleToFraction(resultValue);
      currentFraction = calculationResult!;
      lastOperation = operation;
      isUnaryResult = false;

      firstOperand = FractionOperations.doubleToFraction(firstValue);
      secondOperand = FractionOperations.doubleToFraction(secondValue);

      updateInputsFromFraction();

      waitingForSecondOperand = false;
      pendingBinaryOperation = null;
      currentState = CalculatorState.normal;
      firstNumericOperand = null;

      return CalculatorResult.success();
    }

    // 分数二元运算
    CalculatorResult performFractionBinaryOperation(String operation) {
      if (isCurrentInputDecimal) {
        double decimalValue = getCurrentDecimalValue();
        secondOperand = FractionOperations.doubleToFraction(decimalValue);
      } else {
        secondOperand = Fraction.copy(currentFraction);
      }

      if (firstNumericOperand != null) {
        firstOperand = FractionOperations.doubleToFraction(firstNumericOperand!);
      }

      if (firstOperand == null) {
        return CalculatorResult.error("error_input_first".tr());
      }

      if (secondOperand == null) {
        return CalculatorResult.error("error_input_second".tr());
      }

      if (operation == '通分') {
        CommonDenominatorResultWithDetails result = FractionOperations.performCommonDenominatorWithDetails(firstOperand!, secondOperand!);

        originalFirstOperand = result.originalFirst;
        originalSecondOperand = result.originalSecond;
        firstCommonResult = result.firstResult;
        secondCommonResult = result.secondResult;

        calculationResult = result.firstResult;
        if (result.firstResult != null) {
          currentFraction = result.firstResult!;
        }
        lastOperation = "通分";
        isUnaryResult = false;
        updateInputsFromFraction();

        waitingForSecondOperand = false;
        pendingBinaryOperation = null;
        currentState = CalculatorState.normal;
        firstNumericOperand = null;

        return CalculatorResult.success();
      }

      CalculationDetails details = FractionOperations.performBinaryOperation(operation, firstOperand!, secondOperand!);

      calculationResult = details.result;
      currentFraction = details.result;
      lastOperation = operation;
      isUnaryResult = false;

      updateInputsFromFraction();

      waitingForSecondOperand = false;
      currentState = CalculatorState.normal;
      pendingBinaryOperation = null;
      firstNumericOperand = null;

      return CalculatorResult.success();
    }

    // 准备特殊一元运算
    CalculatorResult prepareSpecialUnaryOperation(String operator) {
      if (isCurrentInputDecimal) {
        double decimalValue = getCurrentDecimalValue();
        baseNumber = FractionOperations.doubleToFraction(decimalValue);
      } else {
        Fraction fraction = Fraction.copy(currentFraction);
        baseNumber = fraction;
      }

      lastOperation = operator;

      switch (operator) {
        case '对数':
          currentState = CalculatorState.waitingForBase;
          break;
        case 'n次方':
          currentState = CalculatorState.waitingForPower;
          break;
        case 'n次根':
          currentState = CalculatorState.waitingForRoot;
          break;
      }

      integerInput = "";
      numeratorInput = "0";
      denominatorInput = "1";
      hasInputDenominator = false;
      currentFraction = Fraction();

      return CalculatorResult.success();
    }

    // 特殊运算方法
    CalculatorResult performLogarithm() {
      if (baseNumber == null) return CalculatorResult.error("error_log_argument".tr());

      try {
        Fraction? currentParam = null;
        if (hasValidCurrentInput()) {
          currentParam = Fraction.copy(currentFraction);
        }

        LogarithmResult result = FractionOperations.performLogarithm(
          baseNumber!, currentParam,
          isCurrentInputDecimal, getCurrentDecimalValue(),
        );

        parameter = result.parameter;
        calculationResult = result.calculationResult;
        currentFraction = calculationResult!;
        originalValue = baseNumber;
        isUnaryResult = true;

        updateInputsFromFraction();
        currentState = CalculatorState.normal;
        waitingForSecondOperand = false;
        pendingBinaryOperation = null;
        firstOperand = null;
        secondOperand = null;

        return CalculatorResult.success();
      } catch (e) {
        return CalculatorResult.error("error_log_argument".tr());
      }
    }

    CalculatorResult performPower() {
      if (baseNumber == null) return CalculatorResult.error("error_input_first".tr());

      try {
        Fraction? currentParam = null;
        if (hasValidCurrentInput()) {
          currentParam = Fraction.copy(currentFraction);
        }

        PowerResult result = FractionOperations.performPower(
          baseNumber!, currentParam,
          isCurrentInputDecimal, getCurrentDecimalValue(),
        );

        parameter = result.parameter;
        calculationResult = result.calculationResult;
        currentFraction = calculationResult!;
        originalValue = baseNumber;
        isUnaryResult = true;

        updateInputsFromFraction();
        currentState = CalculatorState.normal;
        waitingForSecondOperand = false;
        pendingBinaryOperation = null;
        firstOperand = null;
        secondOperand = null;

        return CalculatorResult.success();
      } catch (e) {
        return CalculatorResult.error("error_zero_power".tr());
      }
    }

    CalculatorResult performRoot() {
      if (baseNumber == null) return CalculatorResult.error("error_input_first".tr());

      try {
        Fraction? currentParam = null;
        if (hasValidCurrentInput()) {
          currentParam = Fraction.copy(currentFraction);
        }

        RootResult result = FractionOperations.performRoot(
          baseNumber!, currentParam,
          isCurrentInputDecimal, getCurrentDecimalValue(),
        );

        parameter = result.parameter;
        calculationResult = result.calculationResult;
        currentFraction = calculationResult!;
        originalValue = baseNumber;
        isUnaryResult = true;

        updateInputsFromFraction();
        currentState = CalculatorState.normal;
        waitingForSecondOperand = false;
        pendingBinaryOperation = null;
        firstOperand = null;
        secondOperand = null;

        return CalculatorResult.success();
      } catch (e) {
        return CalculatorResult.error("error_root_zero".tr());
      }
    }

    // 清除所有
    CalculatorResult handleClearAll() {
      integerInput = "";
      numeratorInput = "0";
      denominatorInput = "1";
      hasInputDenominator = false;
      currentFraction = Fraction();

      waitingForSecondOperand = false;
      pendingBinaryOperation = null;
      firstOperand = null;
      secondOperand = null;
      calculationResult = null;
      originalValue = null;
      baseNumber = null;
      parameter = null;
      lastOperation = null;
      isUnaryResult = false;
      currentState = CalculatorState.normal;

      firstNumericOperand = null;
      secondNumericOperand = null;
      numericResult = null;
      isPureNumericCalculation = false;

      originalFirstOperand = null;
      originalSecondOperand = null;
      firstCommonResult = null;
      secondCommonResult = null;
      dualConversionResult = false;
      firstConversionResult = null;
      secondConversionResult = null;

      return CalculatorResult.success();
    }

    // 辅助方法
    void clearAllForNewCalculation() {
      integerInput = "";
      numeratorInput = "0";
      denominatorInput = "1";
      hasInputDenominator = false;
      currentFraction = Fraction();

      waitingForSecondOperand = false;
      pendingBinaryOperation = null;
      firstOperand = null;
      secondOperand = null;
      calculationResult = null;
      originalValue = null;
      baseNumber = null;
      parameter = null;
      lastOperation = null;
      isUnaryResult = false;
      currentState = CalculatorState.normal;

      firstNumericOperand = null;
      secondNumericOperand = null;
      numericResult = null;
      isPureNumericCalculation = false;

          originalFirstOperand = null;
          originalSecondOperand = null;
          firstCommonResult = null;
          secondCommonResult = null;
          dualConversionResult = false;
          firstConversionResult = null;
          secondConversionResult = null;
        }

        void clearPreviousCalculationState() {
          calculationResult = null;
          originalValue = null;
          isUnaryResult = false;
          lastOperation = null;

          originalFirstOperand = null;
          originalSecondOperand = null;
          firstCommonResult = null;
          secondCommonResult = null;
          dualConversionResult = false;
          firstConversionResult = null;
          secondConversionResult = null;

          baseNumber = null;
          parameter = null;

          firstNumericOperand = null;
          secondNumericOperand = null;
          numericResult = null;
          isPureNumericCalculation = false;
        }

        void resetForNewCalculation() {
          calculationResult = null;
          originalValue = null;
          isUnaryResult = false;
          lastOperation = null;

          firstOperand = null;
          secondOperand = null;
          waitingForSecondOperand = false;
          pendingBinaryOperation = null;

          baseNumber = null;
          parameter = null;

          originalFirstOperand = null;
          originalSecondOperand = null;
          firstCommonResult = null;
          secondCommonResult = null;
          dualConversionResult = false;
          firstConversionResult = null;
          secondConversionResult = null;

          firstNumericOperand = null;
          secondNumericOperand = null;
          numericResult = null;
          isPureNumericCalculation = false;

          currentState = CalculatorState.normal;
        }

        String getOperatorSymbol(String operation) {
          switch (operation) {
            case '加法': return '+';
            case '减法': return '-';
            case '乘法': return '×';
            case '除法': return '÷';
            case '通分': return '通分';
            default: return operation;
          }
        }

        bool isFractionEqual(Fraction a, Fraction b) {
          return a.integerPart == b.integerPart &&
              a.numerator == b.numerator &&
              a.denominator == b.denominator;
        }

        bool hasOnlyNumeratorInput() {
          return numeratorInput != "0" && denominatorInput == "1" && !hasInputDenominator && integerInput.isEmpty;
        }

        bool hasOnlyDenominatorInput() {
          return numeratorInput == "0" && hasInputDenominator && integerInput.isEmpty;
        }
      }