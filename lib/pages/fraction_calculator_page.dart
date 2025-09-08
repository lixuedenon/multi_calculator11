// fraction_calculator_page.dart - RTL修复完整版

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/fraction_calculator_logic.dart';
import '../utils/fraction_models.dart';
import 'fraction_input_components.dart';

class FractionCalculatorPage extends StatefulWidget {
  const FractionCalculatorPage({super.key});

  @override
  State<FractionCalculatorPage> createState() => _FractionCalculatorPageState();
}

class _FractionCalculatorPageState extends State<FractionCalculatorPage>
    with TickerProviderStateMixin {
  final FractionCalculatorLogic _calculator = FractionCalculatorLogic();
  late final FractionInputComponents _inputComponents;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _inputComponents = FractionInputComponents(
      calculator: _calculator,
      context: context,
      onStateChanged: () => _debouncedSetState(),
    );

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
  }

  void _debouncedSetState() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (mounted) setState(() {});
    });
  }

  void _startBlinkAnimationIfNeeded() {
    if (_calculator.currentState != CalculatorState.normal &&
        !_blinkController.isAnimating) {
      _blinkController.repeat(reverse: true);
    } else if (_calculator.currentState == CalculatorState.normal &&
        _blinkController.isAnimating) {
      _blinkController.stop();
    }
  }

  Widget _buildCalculationDisplay() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: _buildMainDisplay(),
    );
  }

  Widget _buildMainDisplay() {
    if (_calculator.isPureNumericCalculation && _calculator.numericResult != null) {
      return _buildPureNumericResultDisplay();
    }

    if (_calculator.isCommonDenominatorResult) {
      return _buildCommonDenominatorDisplay();
    }

    if (_calculator.isDualConversionResult) {
      return _buildDualConversionDisplay();
    }

    if (_calculator.calculationResult != null) {
      return _buildCalculationResultDisplay();
    }

    if (_calculator.currentState == CalculatorState.waitingForSecond) {
      return _buildWaitingForSecondDisplay();
    }

    if (_calculator.currentState != CalculatorState.normal) {
      _startBlinkAnimationIfNeeded();
      return _buildSpecialStateDisplay();
    }

    return _buildCurrentInputDisplay();
  }

  Widget _buildPureNumericResultDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatNumericResult(_calculator.numericResult!),
          style: const TextStyle(
              fontSize: 47,
              color: Colors.white,
              fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 4),
        if (_calculator.calculationResult != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "= ",
                  style: TextStyle(fontSize: 20, color: Color(0xFF00FF88))
              ),
              _buildMiniFractionDisplay(_calculator.calculationResult!),
            ],
          ),
        ],
      ],
    );
  }

  String _formatNumericResult(double value) {
    if (value.isNaN) return "NaN";
    if (value.isInfinite) return value.isNegative ? "-∞" : "∞";

    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.round().toString();
    }

    if (value.abs() >= 1e12 || (value.abs() < 1e-4 && value != 0)) {
      return value.toStringAsExponential(6);
    }

    String result = value.toString();

    if (result.contains('.') && result.length > 10) {
      int decimalPlaces = 6;
      if (value.abs() >= 1000) {
        decimalPlaces = 2;
      } else if (value.abs() >= 100) {
        decimalPlaces = 3;
      } else if (value.abs() >= 10) {
        decimalPlaces = 4;
      } else if (value.abs() >= 1) {
        decimalPlaces = 5;
      }

      result = value.toStringAsFixed(decimalPlaces);
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }

    return result;
  }

  Widget _buildCommonDenominatorDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFractionDisplay(_calculator.firstCommonResult!),
        const Text(", ", style: TextStyle(fontSize: 33, color: Colors.white)),
        _buildFractionDisplay(_calculator.secondCommonResult!),
      ],
    );
  }

  Widget _buildDualConversionDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFractionDisplay(_calculator.firstConversionResult!),
        const Text(", ", style: TextStyle(fontSize: 33, color: Colors.white)),
        _buildFractionDisplay(_calculator.secondConversionResult!),
      ],
    );
  }

  Widget _buildCalculationResultDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFractionDisplay(_calculator.calculationResult!),
        if (_calculator.shouldShowDecimalApproximation(_calculator.calculationResult!)) ...[
          const SizedBox(width: 6),
          Text(
            '${_calculator.getDecimalSymbol(_calculator.calculationResult!)}${_calculator.calculationResult!.toDecimal().toStringAsFixed(3)}',
            style: const TextStyle(fontSize: 23, color: Color(0xFF00FF88)),
          ),
        ],
      ],
    );
  }

  Widget _buildWaitingForSecondDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_calculator.firstOperand != null || _calculator.firstNumericOperand != null) ...[
          if (_calculator.isPureNumericCalculation && _calculator.firstNumericOperand != null)
            Text(
              _formatNumericResult(_calculator.firstNumericOperand!),
              style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
            )
          else if (_calculator.firstOperand != null)
            _buildFractionDisplay(_calculator.firstOperand!)
          else
            const Text("0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600))
        ] else ...[
          const Text("0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600))
        ],

        const SizedBox(width: 8),

        Text(
          _calculator.getOperatorSymbol(_calculator.pendingOperation ?? ""),
          style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w600),
        ),

        if (_calculator.hasValidCurrentInput()) ...[
          const SizedBox(width: 8),
          if (_calculator.isCurrentInputDecimal)
            Text(
              _formatNumericResult(_calculator.getCurrentDecimalValue()),
              style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
            )
          else
            _buildFractionDisplay(_calculator.currentFraction),
        ],
      ],
    );
  }

  Widget _buildSpecialStateDisplay() {
    return _buildSpecialOperatorDisplay(_calculator.lastOperation);
  }

  Widget _buildSpecialOperatorDisplay(String? operation) {
    if (operation == null) return _buildCurrentInputDisplay();

    switch (operation) {
      case '对数':
        return _buildLogarithmDisplay();
      case 'n次方':
        return _buildPowerDisplay();
      case 'n次根':
        return _buildRootDisplay();
      default:
        return _buildCurrentInputDisplay();
    }
  }

  Widget _buildLogarithmDisplay() {
    bool isUsingDefault = !_calculator.hasValidCurrentInput();
    String baseText = _calculator.hasValidCurrentInput()
        ? _getFractionText(_calculator.currentFraction)
        : "10";

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('log', style: TextStyle(fontSize: 33, color: Colors.white)),
        Transform.translate(
          offset: const Offset(0, 8),
          child: isUsingDefault
              ? AnimatedBuilder(
            animation: _blinkAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _blinkAnimation.value,
                child: Text(
                  baseText,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            },
          )
              : Text(
            baseText,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const Text('(', style: TextStyle(fontSize: 33, color: Colors.white)),
        if (_calculator.baseNumber != null)
          _buildFractionDisplay(_calculator.baseNumber!)
        else
          const Text("1", style: TextStyle(fontSize: 33, color: Colors.white)),
        const Text(')', style: TextStyle(fontSize: 33, color: Colors.white)),
      ],
    );
  }

  Widget _buildPowerDisplay() {
    bool isUsingDefault = !_calculator.hasValidCurrentInput();
    String exponentText = _calculator.hasValidCurrentInput()
        ? _getFractionText(_calculator.currentFraction)
        : "4";

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_calculator.baseNumber != null)
          _buildFractionDisplay(_calculator.baseNumber!)
        else
          const Text("1", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600)),
        Transform.translate(
          offset: const Offset(0, -8),
          child: isUsingDefault
              ? AnimatedBuilder(
            animation: _blinkAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _blinkAnimation.value,
                child: Text(
                  exponentText,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            },
          )
              : Text(
            exponentText,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRootDisplay() {
    bool isUsingDefault = !_calculator.hasValidCurrentInput();
    String rootText = _calculator.hasValidCurrentInput()
        ? _getFractionText(_calculator.currentFraction)
        : "4";

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, -8),
          child: isUsingDefault
              ? AnimatedBuilder(
            animation: _blinkAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _blinkAnimation.value,
                child: Text(
                  rootText,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            },
          )
              : Text(
            rootText,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const Text('√', style: TextStyle(fontSize: 33, color: Colors.white)),
        if (_calculator.baseNumber != null)
          _buildFractionDisplay(_calculator.baseNumber!)
        else
          const Text("1", style: TextStyle(fontSize: 33, color: Colors.white)),
      ],
    );
  }

  Widget _buildCurrentInputDisplay() {
    if (_calculator.isCurrentInputDecimal) {
      return Text(
        _formatNumericResult(_calculator.getCurrentDecimalValue()),
        style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
      );
    } else {
      return _buildFractionDisplay(_calculator.currentFraction);
    }
  }

  String _getFractionText(Fraction fraction) {
    if (fraction.integerPart == 0 && fraction.numerator == 0) return "0";
    if (fraction.denominator == 1 && fraction.numerator == 0) {
      return fraction.integerPart.toString();
    }

    String result = "";
    if (fraction.integerPart != 0) result += fraction.integerPart.toString();
    if (fraction.numerator != 0) {
      if (fraction.integerPart != 0) result += " ";
      result += "${fraction.numerator}/${fraction.denominator}";
    }
    return result;
  }

  Widget _buildFractionDisplay(Fraction fraction) {
    final integerStr = fraction.integerPart.toString();
    final numeratorStr = fraction.numerator.toString();
    final denominatorStr = fraction.denominator.toString();

    bool onlyNumeratorInput = _calculator.hasOnlyNumeratorInput();
    bool onlyDenominatorInput = _calculator.hasOnlyDenominatorInput();

    if (onlyNumeratorInput && fraction.denominator == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(numeratorStr, style: const TextStyle(fontSize: 33, color: Colors.white, fontWeight: FontWeight.w600)),
          Container(width: math.max(25, numeratorStr.length * 16.5), height: 1.5, color: Colors.white),
          const Text(" ", style: TextStyle(fontSize: 33, color: Colors.transparent, fontWeight: FontWeight.w600)),
        ],
      );
    }

    if (onlyDenominatorInput && fraction.numerator == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(" ", style: TextStyle(fontSize: 33, color: Colors.transparent, fontWeight: FontWeight.w600)),
          Container(width: math.max(25, denominatorStr.length * 16.5), height: 1.5, color: Colors.white),
          Text(denominatorStr, style: const TextStyle(fontSize: 33, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      );
    }

    if (fraction.integerPart == 0 && fraction.numerator == 0 && !_calculator.hasUserInputDenominator) {
      String integerText = _calculator.integerInput;
      if (integerText == "-") {
        return const Text("-", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
      } else if (integerText == "-0") {
        return const Text("-0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
      } else {
        return const Text("0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
      }
    }

    if (fraction.denominator == 1 && fraction.numerator == 0) {
      return Text(integerStr, style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (fraction.integerPart != 0) ...[
          Text(integerStr, style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
        ],
        if (_calculator.hasUserInputDenominator || fraction.numerator != 0) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(numeratorStr, style: const TextStyle(fontSize: 33, color: Colors.white, fontWeight: FontWeight.w600)),
              Container(
                width: math.max(25, math.max(numeratorStr.length * 16.5, denominatorStr.length * 16.5)),
                height: 1.5,
                color: Colors.white,
              ),
              Text(denominatorStr, style: const TextStyle(fontSize: 33, color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMiniOriginalExpression() {
    if (_calculator.calculationResult != null) {
      if (_calculator.isPureNumericCalculation && _calculator.numericResult != null) {
        return _buildPureNumericMiniExpression();
      }

      if (_calculator.isCommonDenominatorResult &&
          _calculator.originalFirstOperand != null &&
          _calculator.originalSecondOperand != null) {
        return _buildExpressionRow([
          _buildMiniFractionDisplay(_calculator.originalFirstOperand!),
          Text(" ${'fraction_common'.tr()} ", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(_calculator.originalSecondOperand!),
        ]);
      }

      if (_calculator.isDualConversionResult && _calculator.effectiveOriginalValue != null) {
        return _buildExpressionRow([
          _buildMiniFractionDisplay(_calculator.effectiveOriginalValue!),
          Text(" ${'fraction_convert'.tr()}", style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ]);
      }

      if (_calculator.isUnaryResult && _calculator.effectiveOriginalValue != null) {
        return _buildUnaryOperationExpression();
      }

      if (!_calculator.isUnaryResult &&
          _calculator.firstOperand != null &&
          _calculator.secondOperand != null &&
          _calculator.lastOperation != null) {
        return _buildBinaryOperationExpression();
      }
    }

    if (_calculator.currentState == CalculatorState.waitingForSecond &&
        (_calculator.firstOperand != null || _calculator.firstNumericOperand != null) &&
        _calculator.hasValidCurrentInput() &&
        _calculator.pendingOperation != null) {
      return _buildWaitingExpression();
    }

    return const SizedBox.shrink();
  }

  Widget _buildPureNumericMiniExpression() {
    if (_calculator.isUnaryResult && _calculator.effectiveOriginalValue != null) {
      String originalText = _formatNumericResult(_calculator.effectiveOriginalValue!.toDecimal());
      String? operation = _calculator.lastOperation;

      switch (operation) {
        case '平方根':
          return _buildExpressionRow([
            const Text("√", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
        case '立方根':
          return _buildExpressionRow([
            const Text("∛", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
        case '自然对数':
          return _buildExpressionRow([
            const Text("ln", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
        case '平方':
          return _buildExpressionRow([
            Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const Text("²", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
        case '立方':
          return _buildExpressionRow([
            Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const Text("³", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
        case '倒数':
          return _buildExpressionRow([
            const Text("1/", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
        default:
          String operatorText = _getOperatorDisplayText(operation ?? "");
          return _buildExpressionRow([
            Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            Text(" $operatorText", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
      }
    } else if (_calculator.firstOperand != null && _calculator.secondOperand != null) {
      String firstText = _formatNumericResult(_calculator.firstOperand!.toDecimal());
      String secondText = _formatNumericResult(_calculator.secondOperand!.toDecimal());
      String operatorSymbol = _calculator.getOperatorSymbol(_calculator.lastOperation ?? "");
      return _buildExpressionRow([
        Text(firstText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text(" $operatorSymbol ", style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text(secondText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ]);
    }
    return const SizedBox.shrink();
  }

  Widget _buildUnaryOperationExpression() {
    String? operation = _calculator.lastOperation;
    Fraction? originalValue = _calculator.effectiveOriginalValue;
    if (operation == null || originalValue == null) return const SizedBox.shrink();

    switch (operation) {
      case '对数':
        Widget baseWidget = _calculator.parameter != null
            ? _buildMiniFractionDisplay(_calculator.parameter!)
            : const Text("10", style: TextStyle(fontSize: 10, color: Colors.white70));
        return _buildExpressionRow([
          const Text("log", style: TextStyle(fontSize: 14, color: Colors.white70)),
          Transform.translate(
            offset: const Offset(0, 4),
            child: baseWidget,
          ),
          const Text("(", style: TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
          const Text(")", style: TextStyle(fontSize: 14, color: Colors.white70)),
        ]);

      case 'n次方':
        Widget exponentWidget = _calculator.parameter != null
            ? _buildMiniFractionDisplay(_calculator.parameter!)
            : const Text("4", style: TextStyle(fontSize: 10, color: Colors.white70));
        return _buildExpressionRow([
          _buildMiniFractionDisplay(originalValue),
          Transform.translate(
            offset: const Offset(0, -4),
            child: exponentWidget,
          ),
        ]);

      case 'n次根':
        Widget rootWidget = _calculator.parameter != null
            ? _buildMiniFractionDisplay(_calculator.parameter!)
            : const Text("4", style: TextStyle(fontSize: 10, color: Colors.white70));
        return _buildExpressionRow([
          Transform.translate(
            offset: const Offset(0, -4),
            child: rootWidget,
          ),
          const Text("√", style: TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
        ]);

      case '平方根':
        return _buildExpressionRow([
          const Text("√", style: TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
        ]);

      case '立方根':
        return _buildExpressionRow([
          const Text("∛", style: TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
        ]);

      case '自然对数':
        return _buildExpressionRow([
          const Text("ln", style: TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
        ]);

      case '平方':
        return _buildExpressionRow([
          _buildMiniFractionDisplay(originalValue),
          const Text("²", style: TextStyle(fontSize: 14, color: Colors.white70)),
        ]);

      case '立方':
        return _buildExpressionRow([
          _buildMiniFractionDisplay(originalValue),
          const Text("³", style: TextStyle(fontSize: 14, color: Colors.white70)),
        ]);

      case '倒数':
        return _buildExpressionRow([
          const Text("1/", style: TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
        ]);

      case '约分':
        return _buildExpressionRow([
          Text("${'fraction_simplify'.tr()}(", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
          const Text(")", style: TextStyle(fontSize: 14, color: Colors.white70)),
        ]);

      case '转换':
        return _buildExpressionRow([
          Text("${'fraction_convert'.tr()}(", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          _buildMiniFractionDisplay(originalValue),
          const Text(")", style: TextStyle(fontSize: 14, color: Colors.white70)),
        ]);

      default:
        String operatorText = _getOperatorDisplayText(operation);
        return _buildExpressionRow([
          _buildMiniFractionDisplay(originalValue),
          Text(" $operatorText", style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ]);
    }
  }

  Widget _buildBinaryOperationExpression() {
    return _buildExpressionRow([
      if (_calculator.isPureNumericCalculation)
        Text(_formatNumericResult(_calculator.firstOperand!.toDecimal()),
            style: const TextStyle(fontSize: 14, color: Colors.white70))
      else
        _buildMiniFractionDisplay(_calculator.firstOperand!),
      Text(" ${_calculator.getOperatorSymbol(_calculator.lastOperation!)} ",
          style: const TextStyle(fontSize: 14, color: Colors.white70)),
      if (_calculator.isPureNumericCalculation)
        Text(_formatNumericResult(_calculator.secondOperand!.toDecimal()),
            style: const TextStyle(fontSize: 14, color: Colors.white70))
      else
        _buildMiniFractionDisplay(_calculator.secondOperand!),
    ]);
  }

  Widget _buildWaitingExpression() {
    return _buildExpressionRow([
      if (_calculator.isPureNumericCalculation && _calculator.firstNumericOperand != null)
        Text(_formatNumericResult(_calculator.firstNumericOperand!),
            style: const TextStyle(fontSize: 14, color: Colors.white70))
      else if (_calculator.firstOperand != null)
        _buildMiniFractionDisplay(_calculator.firstOperand!)
      else
        const Text("0", style: TextStyle(fontSize: 14, color: Colors.white70)),
      Text(" ${_calculator.getOperatorSymbol(_calculator.pendingOperation!)} ",
          style: const TextStyle(fontSize: 14, color: Colors.white70)),
      _calculator.isCurrentInputDecimal
          ? Text(_formatNumericResult(_calculator.getCurrentDecimalValue()),
          style: const TextStyle(fontSize: 14, color: Colors.white70))
          : _buildMiniFractionDisplay(_calculator.currentFraction),
    ]);
  }

  Widget _buildExpressionRow(List<Widget> widgets) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      ),
    );
  }

  Widget _buildMiniFractionDisplay(Fraction fraction) {
    if (fraction.integerPart == 0 && fraction.numerator == 0) {
      return const Text("0", style: TextStyle(fontSize: 14, color: Colors.white70));
    }

    if (fraction.denominator == 1 && fraction.numerator == 0) {
      return Text(
        fraction.integerPart.toString(),
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (fraction.integerPart != 0) ...[
          Text(
            fraction.integerPart.toString(),
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(width: 2),
        ],
        if (fraction.numerator != 0) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fraction.numerator.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
              Container(
                width: math.max(8, math.max(
                  fraction.numerator.toString().length * 5.0,
                  fraction.denominator.toString().length * 5.0,
                )),
                height: 0.8,
                color: Colors.white70,
              ),
              Text(
                fraction.denominator.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getOperatorDisplayText(String operation) {
    try {
      switch (operation) {
        case '约分': return 'fraction_simplify'.tr();
        case '转换': return 'fraction_convert'.tr();
        case '倒数': return 'fraction_reciprocal'.tr();
        case '平方': return 'fraction_square'.tr();
        case '立方': return 'fraction_cube'.tr();
        case '平方根': return 'fraction_sqrt'.tr();
        case '立方根': return 'fraction_cbrt'.tr();
        case '自然对数': return 'fraction_ln'.tr();
        default: return operation;
      }
    } catch (e) {
      return operation;
    }
  }

  bool _isComplexLogarithm() {
    if (_calculator.lastOperation == '对数' &&
        _calculator.isUnaryResult &&
        _calculator.parameter != null) {
      double baseValue = _calculator.parameter!.toDecimal();
      return (baseValue - 10.0).abs() > 0.0001;
    }
    return false;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr, // 强制整个页面使用LTR布局
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2a2a2a), Color(0xFF1a1a1a), Color(0xFF0a0a0a)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 5),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF00FF88),
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl, // 只有标题文本使用RTL
                          child: Text(
                            'fraction_title'.tr().toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 23,
                          fit: FlexFit.tight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0a0a0a),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00FF88), width: 2),
                            ),
                            child: Column(
                              children: [
                                if (_calculator.calculationResult != null)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildMiniOriginalExpression(),
                                      ),
                                      if (_calculator.shouldShowHistory &&
                                          !_calculator.isPureNumericCalculation &&
                                          (!_calculator.isUnaryResult || _isComplexLogarithm()))
                                        GestureDetector(
                                          onTap: () => _inputComponents.showCalculationProcess(),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00FF88).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFF00FF88), width: 1),
                                            ),
                                            child: const Icon(Icons.history, color: Color(0xFF00FF88), size: 16),
                                          ),
                                        ),
                                    ],
                                  ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: _buildCalculationDisplay(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Expanded(
                          flex: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 38,
                                child: _inputComponents.buildIntegerKeyboard(),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 46,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2a2a2a),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 49,
                                        child: _inputComponents.buildNumeratorKeyboard(),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00FF88),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 49,
                                        child: _inputComponents.buildDenominatorKeyboard(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Expanded(
                          flex: 27,
                          child: _inputComponents.buildOperators(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}