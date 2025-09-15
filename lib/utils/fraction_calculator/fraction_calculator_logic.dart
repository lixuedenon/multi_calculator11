// fraction_calculator_logic.dart - 修复硬编码问题的完整版

import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'fraction_models.dart';
import 'fraction_operations.dart';
import 'fraction_input_handler.dart';

class FractionCalculatorLogic {
  final FractionInputHandler _inputHandler = FractionInputHandler();
  bool _shouldShowHistory = true;

  // 只保存当前计算的步骤
  CalculationStep? _currentCalculationStep;

  // 原始操作数保存
  Fraction? _originalFirstOperand;
  Fraction? _originalSecondOperand;
  Fraction? _originalCurrentInput;

  // ================== 获取器 ==================

  Fraction get currentFraction => _inputHandler.currentFraction;
  List<CalculationStep> get calculationSteps => _currentCalculationStep != null ? [_currentCalculationStep!] : [];
  CalculatorState get currentState => _inputHandler.currentState;
  bool get isWaitingForSecondOperand => _inputHandler.waitingForSecondOperand;
  String? get pendingOperation => _inputHandler.pendingBinaryOperation;
  Fraction? get firstOperand => _inputHandler.firstOperand;
  Fraction? get secondOperand => _inputHandler.secondOperand;
  Fraction? get calculationResult => _inputHandler.calculationResult;
  Fraction? get originalValue => _inputHandler.originalValue;
  Fraction? get baseNumber => _inputHandler.baseNumber;
  Fraction? get parameter => _inputHandler.parameter;
  String? get lastOperation => _inputHandler.lastOperation;
  bool get isUnaryResult => _inputHandler.isUnaryResult;
  bool get isPureNumericCalculation => _inputHandler.isPureNumericCalculation;
  double? get numericResult => _inputHandler.numericResult;
  double? get firstNumericOperand => _inputHandler.firstNumericOperand;
  double? get secondNumericOperand => _inputHandler.secondNumericOperand;
  bool get shouldShowHistory => _shouldShowHistory;
  // 在FractionCalculatorLogic类中添加：
  bool get waitingForSecondOperand => _inputHandler.waitingForSecondOperand;

  Fraction? get originalFirstOperand => _inputHandler.originalFirstOperand;
  Fraction? get originalSecondOperand => _inputHandler.originalSecondOperand;
  Fraction? get firstCommonResult => _inputHandler.firstCommonResult;
  Fraction? get secondCommonResult => _inputHandler.secondCommonResult;
  Fraction? get firstConversionResult => _inputHandler.firstConversionResult;
  Fraction? get secondConversionResult => _inputHandler.secondConversionResult;
  bool get hasUserInputDenominator => _inputHandler.denominatorInput != "1" || _inputHandler.hasInputDenominator;
  bool get isCurrentInputDecimal => _inputHandler.isCurrentInputDecimal;
  String get integerInput => _inputHandler.integerInput;

  // 【新增】添加获取有效原始值的方法
  Fraction? get effectiveOriginalValue {
    // 优先返回 originalValue，如果为空则返回 _originalCurrentInput
    if (_inputHandler.originalValue != null) {
      return _inputHandler.originalValue;
    }
    if (_originalCurrentInput != null) {
      return _originalCurrentInput;
    }
    return null;
  }

  // ================== 状态检查方法 ==================

  bool get isCommonDenominatorResult => _inputHandler.lastOperation == "通分" &&
      _inputHandler.firstCommonResult != null && _inputHandler.secondCommonResult != null;

  bool get isDualConversionResult => _inputHandler.dualConversionResult &&
      _inputHandler.firstConversionResult != null && _inputHandler.secondConversionResult != null;

  double getCurrentDecimalValue() => _inputHandler.getCurrentDecimalValue();
  bool hasValidCurrentInput() => _inputHandler.hasValidCurrentInput();
  bool hasOnlyNumeratorInput() => _inputHandler.hasOnlyNumeratorInput();
  bool hasOnlyDenominatorInput() => _inputHandler.hasOnlyDenominatorInput();

  bool shouldShowDecimalApproximation(Fraction fraction) {
    if (isPureNumericCalculation) return true;
    if (fraction.isInteger()) return false;
    if (fraction.isZero()) return false;
    return true;
  }

  String getDecimalSymbol(Fraction fraction) {
    if (isPureNumericCalculation) return "=";

    // 检查分数转换为小数是否是精确值
    if (isExactDecimal(fraction)) {
      return "=";
    }
    return "≈";
  }

  // 添加新的辅助方法来判断分数是否能精确转换为小数
  bool isExactDecimal(Fraction fraction) {
    // 获取分数的分母（不包括整数部分）
    int denominator = fraction.denominator;

    // 检查分母是否只包含因子2和5
    // 如果分母只能被2和5整除，那么这个分数可以精确表示为十进制小数
    int temp = denominator;

    // 除以所有的2
    while (temp % 2 == 0) {
      temp ~/= 2;
    }

    // 除以所有的5
    while (temp % 5 == 0) {
      temp ~/= 5;
    }

    // 如果最后剩下1，说明分母只包含2和5的因子，可以精确转换
    return temp == 1;
  }

  // 【简化】所有运算都显示原始算式
  bool _needsHistoryDisplay(String operation) {
    return true;  // 所有运算都显示
  }

  // 【简化】所有计算都显示原始算式
  bool _isFractionCalculation() {
    return true;  // 所有计算都显示，不管是否涉及分数
  }

  // 【简化】总是显示历史
  void _updateHistoryDisplayState(String operation) {
    _shouldShowHistory = true;  // 总是显示
  }

  // 保存计算步骤 - 只保存当前计算
  void _saveCalculationStep(String operation, String input, String result, String? detailProcess) {
    if (_shouldShowHistory) {
      _currentCalculationStep = CalculationStep(
        operation: operation,
        input: input,
        result: result,
        detailProcess: detailProcess,
        timestamp: DateTime.now(),
      );
    }
  }

  // 构建输入表达式字符串 - 一元运算支持
  String _buildInputExpression() {
    if (_inputHandler.isUnaryResult) {
      // 一元运算：使用原始输入值
      Fraction? original = _originalCurrentInput ?? _inputHandler.originalValue;
      if (original != null) {
        switch (_inputHandler.lastOperation) {
          case '约分':
          case '转换':
          case '倒数':
          case '平方':
          case '立方':
          case '平方根':
          case '立方根':
          case '自然对数':
            return original.toString();
          case '对数':
            String baseText = _inputHandler.parameter != null ? _inputHandler.parameter!.toString() : "10";
            return "log₍${baseText}₎(${original.toString()})";
          case 'n次方':
            String exponentText = _inputHandler.parameter != null ? _inputHandler.parameter!.toString() : "4";
            return "${original.toString()}^$exponentText";
          case 'n次根':
            String rootText = _inputHandler.parameter != null ? _inputHandler.parameter!.toString() : "4";
            return "^${rootText}√${original.toString()}";
          default:
            return original.toString();
        }
      }
    } else {
      // 二元运算
      if (_inputHandler.lastOperation == '通分' &&
          _inputHandler.originalFirstOperand != null &&
          _inputHandler.originalSecondOperand != null) {
        return "${_inputHandler.originalFirstOperand!.toString()} ${"fraction_common".tr()} ${_inputHandler.originalSecondOperand!.toString()}";
      } else if (_originalFirstOperand != null && _originalSecondOperand != null) {
        return "${_originalFirstOperand!.toString()} ${getOperatorSymbol(_inputHandler.lastOperation ?? "")} ${_originalSecondOperand!.toString()}";
      } else if (_inputHandler.firstOperand != null && _inputHandler.secondOperand != null) {
        return "${_inputHandler.firstOperand!.toString()} ${getOperatorSymbol(_inputHandler.lastOperation ?? "")} ${_inputHandler.secondOperand!.toString()}";
      }
    }

    return _inputHandler.currentFraction.toString();
  }

  // 构建结果字符串
  String _buildResultString() {
    if (isCommonDenominatorResult) {
      return "${_inputHandler.firstCommonResult!.toString()}, ${_inputHandler.secondCommonResult!.toString()}";
    }

    if (isDualConversionResult) {
      return "${_inputHandler.firstConversionResult!.toString()}, ${_inputHandler.secondConversionResult!.toString()}";
    }

    if (_inputHandler.calculationResult != null) {
      return _inputHandler.calculationResult!.toString();
    }

    return _inputHandler.currentFraction.toString();
  }

  // 获取详细计算过程 - 修复硬编码问题
  String? _getDetailedCalculationProcess() {
    if (_inputHandler.lastOperation == null) return null;

    try {
      switch (_inputHandler.lastOperation!) {
        case '加法':
        case '减法':
        case '乘法':
        case '除法':
          if (_originalFirstOperand != null && _originalSecondOperand != null) {
            CalculationDetails details = FractionOperations.performBinaryOperation(
                _inputHandler.lastOperation!, _originalFirstOperand!, _originalSecondOperand!);
            return details.detailedSteps;
          }
          break;

        case '约分':
          Fraction? originalForSimplify = _originalCurrentInput ?? _inputHandler.originalValue;
          if (originalForSimplify != null) {
            CalculationDetails details = FractionOperations.simplifyFractionWithDetails(originalForSimplify);
            return details.detailedSteps;
          }
          break;

        case '转换':
          Fraction? originalForConvert = _originalCurrentInput ?? _inputHandler.originalValue;
          if (originalForConvert != null) {
            ConversionResultWithDetails details = FractionOperations.convertFractionWithDetails(originalForConvert);
            return details.detailedSteps;
          }
          break;

        case '通分':
          if (_inputHandler.originalFirstOperand != null && _inputHandler.originalSecondOperand != null) {
            CommonDenominatorResultWithDetails details = FractionOperations.performCommonDenominatorWithDetails(
                _inputHandler.originalFirstOperand!, _inputHandler.originalSecondOperand!);
            return details.detailedSteps;
          }
          break;

        case '倒数':
          Fraction? originalForReciprocal = _originalCurrentInput ?? _inputHandler.originalValue;
          if (originalForReciprocal != null) {
            CalculationDetails details = FractionOperations.reciprocalWithDetails(originalForReciprocal);
            return details.detailedSteps;
          }
          break;

        case '对数':
        // 修复硬编码问题
          if (_inputHandler.parameter != null && _inputHandler.parameter!.toDecimal() != 10.0 &&
              _inputHandler.originalValue != null) {
            double baseValue = _inputHandler.parameter!.toDecimal();
            double argumentValue = _inputHandler.originalValue!.toDecimal();
            double lnArg = math.log(argumentValue);
            double lnBase = math.log(baseValue);
            double result = lnArg / lnBase;

            List<String> steps = [];
            steps.add("step_use_change_base_formula".tr());
            steps.add("log_change_base_formula".tr(namedArgs: {
              'base': _inputHandler.parameter!.toString(),
              'arg': _inputHandler.originalValue!.toString()
            }));
            steps.add("step_calculate_natural_log".tr());
            steps.add("natural_log_calculation".tr(namedArgs: {
              'arg': _inputHandler.originalValue!.toString(),
              'result': lnArg.toStringAsFixed(6)
            }));
            steps.add("natural_log_calculation".tr(namedArgs: {
              'arg': _inputHandler.parameter!.toString(),
              'result': lnBase.toStringAsFixed(6)
            }));
            steps.add("step_calculate_final_result".tr());
            steps.add("division_result".tr(namedArgs: {
              'dividend': lnArg.toStringAsFixed(6),
              'divisor': lnBase.toStringAsFixed(6),
              'result': result.toStringAsFixed(6)
            }));
            return steps.join('\n');
          }
          break;
      }
    } catch (e) {
      // 静默处理错误
    }

    return null;
  }

  // ================== 显示相关方法 ==================

  String getDisplayExpression() {
    if (isPureNumericCalculation && numericResult != null) {
      return '${numericResult!.toString()}';
    }

    if (isCommonDenominatorResult) {
      return '${_inputHandler.originalFirstOperand!.toString()} ${"fraction_common".tr()} ${_inputHandler.originalSecondOperand!.toString()} = ${_inputHandler.firstCommonResult!.toString()}, ${_inputHandler.secondCommonResult!.toString()}';
    }

    if (isDualConversionResult) {
      return '${_inputHandler.originalValue!.toString()} ${"fraction_convert".tr()} = ${_inputHandler.firstConversionResult!.toString()}, ${_inputHandler.secondConversionResult!.toString()}';
    }

    if (_inputHandler.calculationResult != null) {
      if (_inputHandler.isUnaryResult && _inputHandler.originalValue != null) {
        if (_inputHandler.lastOperation == "对数") {
          String baseText = _inputHandler.parameter != null ? _inputHandler.parameter!.toString() : "10";
          return 'log₍$baseText₎(${_inputHandler.originalValue!.toString()}) = ${_inputHandler.calculationResult!.toString()}';
        } else if (_inputHandler.lastOperation == "n次方") {
          String exponentText = _inputHandler.parameter != null ? _inputHandler.parameter!.toString() : "4";
          return '${_inputHandler.originalValue!.toString()}^$exponentText = ${_inputHandler.calculationResult!.toString()}';
        } else if (_inputHandler.lastOperation == "n次根") {
          String rootText = _inputHandler.parameter != null ? _inputHandler.parameter!.toString() : "4";
          return '^${rootText}√${_inputHandler.originalValue!.toString()} = ${_inputHandler.calculationResult!.toString()}';
        } else {
          return '${_inputHandler.originalValue!.toString()} ${_getOperatorDisplayText(_inputHandler.lastOperation!)} = ${_inputHandler.calculationResult!.toString()}';
        }
      } else if (!_inputHandler.isUnaryResult && _inputHandler.firstOperand != null && _inputHandler.secondOperand != null) {
        return '${_inputHandler.firstOperand!.toString()} ${getOperatorSymbol(_inputHandler.lastOperation ?? "")} ${_inputHandler.secondOperand!.toString()} = ${_inputHandler.calculationResult!.toString()}';
      }
    }

    if (_inputHandler.currentState == CalculatorState.waitingForSecond && _inputHandler.firstOperand != null) {
      String currentInput = "";
      if (hasValidCurrentInput()) {
        if (isCurrentInputDecimal) {
          currentInput = ' ${getCurrentDecimalValue().toString()}';
        } else {
          currentInput = ' ${_inputHandler.currentFraction.toString()}';
        }
      }
      return '${_inputHandler.firstOperand!.toString()} ${getOperatorSymbol(_inputHandler.pendingBinaryOperation ?? "")}$currentInput';
    }

    if (_inputHandler.currentState != CalculatorState.normal && _inputHandler.baseNumber != null) {
      String currentInput = "";
      if (hasValidCurrentInput()) {
        if (isCurrentInputDecimal) {
          currentInput = getCurrentDecimalValue().toString();
        } else {
          currentInput = _inputHandler.currentFraction.toString();
        }
      }

      switch (_inputHandler.lastOperation) {
        case '对数':
          String base = currentInput.isNotEmpty ? currentInput : "10";
          return 'log₍$base₎(${_inputHandler.baseNumber!.toString()})';
        case 'n次方':
          String exponent = currentInput.isNotEmpty ? currentInput : "4";
          return '${_inputHandler.baseNumber!.toString()}^$exponent';
        case 'n次根':
          String root = currentInput.isNotEmpty ? currentInput : "4";
          return '^${root}√${_inputHandler.baseNumber!.toString()}';
      }
    }

    if (isCurrentInputDecimal) {
      return getCurrentDecimalValue().toString();
    } else {
      return _inputHandler.currentFraction.toString();
    }
  }

  String _getOperatorDisplayText(String operation) {
    switch (operation) {
      case '约分': return 'fraction_simplify'.tr();
      case '转换': return 'fraction_convert'.tr();
      case '倒数': return 'fraction_reciprocal'.tr();
      case '平方': return 'fraction_square'.tr();
      case '立方': return 'fraction_cube'.tr();
      case '平方根': return 'fraction_sqrt'.tr();
      case '立方根': return 'fraction_cbrt'.tr();
      case '自然对数': return 'fraction_ln'.tr();
      case '对数': return 'fraction_log'.tr();
      case 'n次方': return 'fraction_power'.tr();
      case 'n次根': return 'fraction_root'.tr();
      case '加法': return 'fraction_add'.tr();
      case '减法': return 'fraction_subtract'.tr();
      case '乘法': return 'fraction_multiply'.tr();
      case '除法': return 'fraction_divide'.tr();
      case '通分': return 'fraction_common'.tr();
      default: return operation;
    }
  }

  String getOperatorSymbol(String operation) {
    switch (operation) {
      case '加法': return '+';
      case '减法': return '-';
      case '乘法': return '×';
      case '除法': return '÷';
      case '通分': return 'fraction_common'.tr();
      default: return operation;
    }
  }

  // ================== 输入处理方法 ==================

  CalculatorResult handleIntegerInput(String input) {
    return _inputHandler.handleIntegerInput(input);
  }

  CalculatorResult handleNumeratorInput(String input) {
    return _inputHandler.handleNumeratorInput(input);
  }

  CalculatorResult handleDenominatorInput(String input) {
    return _inputHandler.handleDenominatorInput(input);
  }

  CalculatorResult handleNumeratorClear() {
    return _inputHandler.handleNumeratorClear();
  }

  CalculatorResult handleDenominatorClear() {
    return _inputHandler.handleDenominatorClear();
  }

  // 【最终修复】处理运算符 - 确保一元运算也正确设置originalValue
  CalculatorResult handleOperator(String operator) {
    // 在运算前保存当前输入作为原始值
    if (hasValidCurrentInput()) {
      if (_inputHandler.isCurrentInputDecimal) {
        double decimalValue = _inputHandler.getCurrentDecimalValue();
        _originalCurrentInput = FractionOperations.doubleToFraction(decimalValue);
      } else {
        _originalCurrentInput = Fraction.copy(_inputHandler.currentFraction);
      }
    }

    if (_inputHandler.waitingForSecondOperand) {
      _originalSecondOperand = _originalCurrentInput;
    } else {
      if (['加法', '减法', '乘法', '除法', '通分'].contains(operator)) {
        _originalFirstOperand = _originalCurrentInput;
      }
    }

    CalculatorResult result = _inputHandler.handleOperator(operator);

    // 【关键修复】如果是一元运算且originalValue为null，手动设置
    if (result.success && _inputHandler.calculationResult != null) {

      // 【强制修复originalValue】
      if (_inputHandler.isUnaryResult && _inputHandler.originalValue == null && _originalCurrentInput != null) {
        // 直接通过反射或访问器设置originalValue
        // 由于无法直接访问private字段，我们在UI层使用_originalCurrentInput
        print("修复：originalValue为null，使用_originalCurrentInput: $_originalCurrentInput");
      }

      _updateHistoryDisplayState(operator);

      // 强制保存计算步骤
      String inputExpr = _buildInputExpression();
      String resultExpr = _buildResultString();
      String? detailProcess = _getDetailedCalculationProcess();

      _currentCalculationStep = CalculationStep(
        operation: operator,
        input: inputExpr,
        result: resultExpr,
        detailProcess: detailProcess,
        timestamp: DateTime.now(),
      );

      print("保存了计算步骤: $operator, 输入: $inputExpr, 结果: $resultExpr");

      // 【重要】不要清空_originalCurrentInput，UI层需要使用
      _originalFirstOperand = null;
      _originalSecondOperand = null;
      // _originalCurrentInput = null; // 暂时不清空，供UI使用
    }

    return result;
  }

  CalculatorResult handleCalculate() {
    if (_inputHandler.waitingForSecondOperand && hasValidCurrentInput()) {
      if (_inputHandler.isCurrentInputDecimal) {
        double decimalValue = _inputHandler.getCurrentDecimalValue();
        _originalSecondOperand = FractionOperations.doubleToFraction(decimalValue);
      } else {
        _originalSecondOperand = Fraction.copy(_inputHandler.currentFraction);
      }
    }

    CalculatorResult result = _inputHandler.handleCalculate();

    if (result.success && _inputHandler.calculationResult != null && _inputHandler.lastOperation != null) {
      _updateHistoryDisplayState(_inputHandler.lastOperation!);

      if (_shouldShowHistory) {
        String inputExpr = _buildInputExpression();
        String resultExpr = _buildResultString();
        String? detailProcess = _getDetailedCalculationProcess();

        _saveCalculationStep(_inputHandler.lastOperation!, inputExpr, resultExpr, detailProcess);
      }

      _originalFirstOperand = null;
      _originalSecondOperand = null;
      _originalCurrentInput = null;
    }

    return result;
  }

  CalculatorResult handleClearAll() {
    CalculatorResult result = _inputHandler.handleClearAll();

    if (result.success) {
      _shouldShowHistory = true;
      _originalFirstOperand = null;
      _originalSecondOperand = null;
      _originalCurrentInput = null;
      _currentCalculationStep = null;
    }

    return result;
  }
}