// fraction_input_handler.dart - 国际化修改版（解决整数变分数显示问题）

import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'fraction_models.dart';
import 'fraction_operations.dart';

class FractionInputHandler {
  // 输入状态
  String _integerInput = "";
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

  // 【新增】纯数值计算相关状态
  double? firstNumericOperand;    // 第一个数值操作数
  double? secondNumericOperand;   // 第二个数值操作数
  double? numericResult;          // 数值计算结果
  bool isPureNumericCalculation = false;  // 标记是否为纯数值计算

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

  // 访问器
  String get integerInput => _integerInput;
  set integerInput(String value) {
    _integerInput = value;
  }

  // 检查当前输入是否为小数
  bool get isCurrentInputDecimal => _integerInput.isNotEmpty && _integerInput.contains('.');

  // 【新增】检查是否为纯小数输入
  bool isPureDecimalInput() {
    return _integerInput.isNotEmpty &&
        _integerInput.contains('.') &&
        numeratorInput == "0" &&
        denominatorInput == "1" &&
        !hasInputDenominator;
  }

  // 【新增】检查是否为纯整数输入
  bool isPureIntegerInput() {
    return _integerInput.isNotEmpty &&
        !_integerInput.contains('.') &&
        numeratorInput == "0" &&
        denominatorInput == "1" &&
        !hasInputDenominator;
  }

  // 【新增】检查是否有分数部分输入
  bool hasAnyFractionInput() {
    return numeratorInput != "0" || hasInputDenominator || denominatorInput != "1";
  }

  // 【新增】检查当前是否为纯数值输入（整数或小数，无分数部分）
  bool isPureNumberInput() {
    return (isPureDecimalInput() || isPureIntegerInput()) && !hasAnyFractionInput();
  }

  // 获取当前输入的小数值
  double getCurrentDecimalValue() {
    if (_integerInput.isNotEmpty && _integerInput.contains('.')) {
      try {
        return double.parse(_integerInput);
      } catch (e) {
        return 0.0;
      }
    }
    return currentFraction.toDecimal();
  }

  // 【新增】获取当前输入的数值（用于纯数值计算）
  double getCurrentNumericValue() {
    if (_integerInput.isNotEmpty) {
      try {
        return double.parse(_integerInput);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // 检查是否有有效的当前输入
  bool hasValidCurrentInput() {
    if (_integerInput.isNotEmpty && _integerInput.contains('.')) {
      try {
        double value = double.parse(_integerInput);
        return value != 0.0;
      } catch (e) {
        return false;
      }
    }

    if (_integerInput.isNotEmpty && _integerInput != "-" && _integerInput != "0") {
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
      if (_integerInput.isNotEmpty && _integerInput.contains('.')) {
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
      if (_integerInput.isNotEmpty && _integerInput != "-") {
        integerPart = int.parse(_integerInput);
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

  // 处理整数部分输入
  CalculatorResult handleIntegerInput(String input) {
    try {
      if (calculationResult != null && input != '+/-' && input != 'C' && input != '⌫') {
        clearAllForNewCalculation();
      }

      switch (input) {
        case 'C':
          _integerInput = "";
          break;
        case '+/-':
          if (_integerInput.isEmpty) {
            _integerInput = "-";
          } else if (_integerInput == "-") {
            _integerInput = "";
          } else if (_integerInput == "0") {
            _integerInput = "-0";
          } else if (_integerInput == "-0") {
            _integerInput = "0";
          } else if (_integerInput.startsWith('-')) {
            _integerInput = _integerInput.substring(1);
          } else {
            _integerInput = '-$_integerInput';
          }
          break;
        case '.':
          if (!_integerInput.contains('.')) {
            if (_integerInput.isEmpty || _integerInput == "-") {
              _integerInput += "0.";
            } else {
              _integerInput += input;
            }
          }
          break;
        case '⌫':
          if (_integerInput.isNotEmpty) {
            _integerInput = _integerInput.substring(0, _integerInput.length - 1);
          }
          break;
        default:
          if (_integerInput == "-") {
            _integerInput = "-$input";
          } else if (_integerInput == "0") {
            _integerInput = input;
          } else if (_integerInput == "-0") {
            _integerInput = "-$input";
          } else {
            _integerInput += input;
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

  // 【修复】处理运算符 - 添加完整的空值检查
  CalculatorResult handleOperator(String operator) {
    try {
      if (calculationResult != null && !waitingForSecondOperand && currentState == CalculatorState.normal) {
        bool isShowingResult = !hasValidCurrentInput() || (calculationResult != null && _isFractionEqual(currentFraction, calculationResult!));

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
    return ['约分', '转换', '倒数', '平方', '立方', '平方根', '立方根', '自然对数'].contains(operator);
  }

  bool isSpecialUnaryOperation(String operator) {
    return ['对数', 'n次方', 'n次根'].contains(operator);
  }

  bool isBinaryOperation(String operator) {
    return ['加法', '减法', '乘法', '除法', '通分'].contains(operator);
  }

  // 执行立即一元运算 - 支持纯数值计算
  CalculatorResult performImmediateUnaryOperation(String operator) {
    bool isPureNumber = isPureNumberInput();

    if (isPureNumber) {
      // 【纯数值计算】直接使用数值运算
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
          // 对于约分、转换等操作，仍使用分数处理
            return performFractionUnaryOperation(operator);
        }

        // 【关键】设置纯数值计算结果
        isPureNumericCalculation = true;
        numericResult = resultValue;
        calculationResult = FractionOperations.doubleToFraction(resultValue);
        currentFraction = calculationResult!;
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
        return CalculatorResult.error("error_invalid_result".tr());
      }
    } else {
      // 分数计算：使用原有逻辑
      return performFractionUnaryOperation(operator);
    }
  }

  // 分数运算的原有逻辑
  CalculatorResult performFractionUnaryOperation(String operator) {
    if (isCurrentInputDecimal) {
      double decimalValue = getCurrentDecimalValue();
      originalValue = FractionOperations.doubleToFraction(decimalValue);
    } else {
      originalValue = Fraction.copy(currentFraction);
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

  // 【关键修复】准备二元运算 - 正确设置纯数值计算标志
  CalculatorResult prepareBinaryOperation(String operator) {
    if (!waitingForSecondOperand) {
      // 【关键修复】先判断并设置计算类型
      bool currentIsPureNumber = isPureNumberInput();
      isPureNumericCalculation = currentIsPureNumber; // 【重要】设置计算类型标志

      if (currentIsPureNumber) {
        // 【修复】在清空之前保存数值
        double currentValue = getCurrentNumericValue();
        firstNumericOperand = currentValue;
        firstOperand = FractionOperations.doubleToFraction(currentValue);
      } else {
        // 重置纯数值计算标志
        isPureNumericCalculation = false;
        if (isCurrentInputDecimal) {
          double decimalValue = getCurrentDecimalValue();
          firstOperand = FractionOperations.doubleToFraction(decimalValue);
        } else {
          firstOperand = Fraction.copy(currentFraction);
        }
        firstNumericOperand = null;
      }

      pendingBinaryOperation = operator;
      waitingForSecondOperand = true;
      currentState = CalculatorState.waitingForSecond;

      // 保存完数值后再清空输入
      _integerInput = "";
      numeratorInput = "0";
      denominatorInput = "1";
      hasInputDenominator = false;
      currentFraction = Fraction();
    }

    return CalculatorResult.success();
  }

  // 【关键修复】执行二元运算 - 添加完整的空值检查
  CalculatorResult performBinaryOperation() {
    // 【修复1】检查运算符
    if (pendingBinaryOperation == null) {
      return CalculatorResult.error("error_invalid_result".tr());
    }

    // 【修复2】检查第一个操作数
    if (firstNumericOperand == null && firstOperand == null) {
      return CalculatorResult.error("error_input_first".tr());
    }

    // 【修复3】检查第二个操作数输入
    if (!hasValidCurrentInput()) {
      return CalculatorResult.error("error_input_second".tr());
    }

    String operation = pendingBinaryOperation!; // 现在安全使用!

    // 【检测计算类型】基于第一操作数的类型和当前输入
    bool firstIsPureNumber = firstNumericOperand != null;
    bool secondIsPureNumber = isPureNumberInput();
    bool bothArePureNumbers = firstIsPureNumber && secondIsPureNumber;

    try {
      if (bothArePureNumbers && operation != '通分') {
        // 【纯数值计算】直接用double运算
        isPureNumericCalculation = true; // 确保标志正确
        return performPureNumericBinaryOperation(operation);
      } else {
        // 【分数计算】使用原有逻辑
        isPureNumericCalculation = false; // 重置标志
        return performFractionBinaryOperation(operation);
      }
    } catch (e) {
      return CalculatorResult.error("error_invalid_result".tr());
    }
  }

  // 【修复】纯数值二元运算 - 添加空值检查
  CalculatorResult performPureNumericBinaryOperation(String operation) {
    // 【修复】安全检查第一个数值操作数
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

    // 【关键】设置纯数值计算结果
    isPureNumericCalculation = true;
    numericResult = resultValue;
    calculationResult = FractionOperations.doubleToFraction(resultValue);
    currentFraction = calculationResult!;
    lastOperation = operation;
    isUnaryResult = false;

    // 记录操作数（用于显示）
    firstOperand = FractionOperations.doubleToFraction(firstValue);
    secondOperand = FractionOperations.doubleToFraction(secondValue);

    updateInputsFromFraction();

    // 重置状态
    waitingForSecondOperand = false;
    pendingBinaryOperation = null;
    currentState = CalculatorState.normal;
    firstNumericOperand = null;

    return CalculatorResult.success();
  }

  // 【修复】分数二元运算 - 添加空值检查
  CalculatorResult performFractionBinaryOperation(String operation) {
    // 处理第二个操作数
    if (isCurrentInputDecimal) {
      double decimalValue = getCurrentDecimalValue();
      secondOperand = FractionOperations.doubleToFraction(decimalValue);
    } else {
      secondOperand = Fraction.copy(currentFraction);
    }

    // 如果第一个操作数是数值，转换为分数
    if (firstNumericOperand != null) {
      firstOperand = FractionOperations.doubleToFraction(firstNumericOperand!);
    }

    // 【修复】确保操作数不为空
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

      // 重置状态
      waitingForSecondOperand = false;
      pendingBinaryOperation = null;
      currentState = CalculatorState.normal;
      firstNumericOperand = null;

      return CalculatorResult.success();
    }

    // 其他二元运算
    CalculationDetails details = FractionOperations.performBinaryOperation(operation, firstOperand!, secondOperand!);

    calculationResult = details.result;
    currentFraction = details.result;
    lastOperation = operation;
    isUnaryResult = false;

    updateInputsFromFraction();

    // 重置状态
    waitingForSecondOperand = false;
    currentState = CalculatorState.normal;
    pendingBinaryOperation = null;
    firstNumericOperand = null;

    return CalculatorResult.success();
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

  // 特殊运算方法（保持原有逻辑）
  CalculatorResult performLogarithm() {
    if (baseNumber == null) return CalculatorResult.error("error_log_argument".tr());

    try {
      LogarithmResult result = FractionOperations.performLogarithm(
        baseNumber!, hasValidCurrentInput() ? currentFraction : null,
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
      PowerResult result = FractionOperations.performPower(
        baseNumber!, hasValidCurrentInput() ? currentFraction : null,
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
      RootResult result = FractionOperations.performRoot(
        baseNumber!, hasValidCurrentInput() ? currentFraction : null,
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

  // 准备特殊一元运算
  CalculatorResult prepareSpecialUnaryOperation(String operator) {
    if (isCurrentInputDecimal) {
      double decimalValue = getCurrentDecimalValue();
      baseNumber = FractionOperations.doubleToFraction(decimalValue);
    } else {
      baseNumber = Fraction.copy(currentFraction);
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

    _integerInput = "";
    numeratorInput = "0";
    denominatorInput = "1";
    hasInputDenominator = false;
    currentFraction = Fraction();

    return CalculatorResult.success();
  }

  // 清除所有 - 重置所有状态
  CalculatorResult handleClearAll() {
    _integerInput = "";
    numeratorInput = "0";
    denominatorInput = "1";
    hasInputDenominator = false;
    currentFraction = Fraction();

    // 重置所有状态
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

    // 【新增】重置纯数值计算状态
    firstNumericOperand = null;
    secondNumericOperand = null;
    numericResult = null;
    isPureNumericCalculation = false;

    // 重置通分专用数据
    originalFirstOperand = null;
    originalSecondOperand = null;
    firstCommonResult = null;
    secondCommonResult = null;

    // 重置双转换数据
    dualConversionResult = false;
    firstConversionResult = null;
    secondConversionResult = null;

    return CalculatorResult.success();
  }

  // 辅助方法
  void updateInputsFromFraction() {
    _integerInput = currentFraction.integerPart == 0 ? "" : currentFraction.integerPart.toString();
    numeratorInput = currentFraction.numerator.toString();
    denominatorInput = currentFraction.denominator.toString();
  }

  void clearAllForNewCalculation() {
    _integerInput = "";
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

    // 重置纯数值计算状态
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

    // 清除纯数值计算状态
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

    // 重置纯数值计算状态
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

  bool _isFractionEqual(Fraction a, Fraction b) {
    return a.integerPart == b.integerPart &&
        a.numerator == b.numerator &&
        a.denominator == b.denominator;
  }

  bool hasOnlyNumeratorInput() {
    return numeratorInput != "0" && denominatorInput == "1" && !hasInputDenominator && _integerInput.isEmpty;
  }

  bool hasOnlyDenominatorInput() {
    return numeratorInput == "0" && hasInputDenominator && _integerInput.isEmpty;
  }
}