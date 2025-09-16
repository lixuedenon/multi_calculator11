// fraction_calculator_page.dart - 完整版（添加小数分数互换功能）

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/fraction_calculator/fraction_calculator_logic.dart';
import '../../utils/fraction_calculator/fraction_models.dart';
import 'fraction_input_components.dart';

class FractionCalculatorPage extends StatefulWidget {
  const FractionCalculatorPage({super.key});

  @override
  State<FractionCalculatorPage> createState() => _FractionCalculatorPageState();
}

class _FractionCalculatorPageState extends State<FractionCalculatorPage>
    with TickerProviderStateMixin {
  final FractionCalculatorLogic calculator = FractionCalculatorLogic();
  late final FractionInputComponents inputComponents;

  late AnimationController blinkController;
  late Animation<double> blinkAnimation;
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();

    inputComponents = FractionInputComponents(
      calculator: calculator,
      context: context,
      onStateChanged: () => debouncedSetState(),
    );

    blinkController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: blinkController,
      curve: Curves.easeInOut,
    ));
  }

  void debouncedSetState() {
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (mounted) setState(() {});
    });
  }

  void startBlinkAnimationIfNeeded() {
    if (calculator.currentState != CalculatorState.normal &&
        !blinkController.isAnimating) {
      blinkController.repeat(reverse: true);
    } else if (calculator.currentState == CalculatorState.normal &&
        blinkController.isAnimating) {
      blinkController.stop();
    }
  }

  Widget buildCalculationDisplay() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: buildMainDisplay(),
    );
  }

  Widget buildMainDisplay() {
    // 【调试】查看走哪个显示路径
      print("=== buildMainDisplay DEBUG ===");
      print("isPureNumericCalculation: ${calculator.isPureNumericCalculation}");
      print("numericResult: ${calculator.numericResult}");
      print("calculationResult: ${calculator.calculationResult}");
      print("lastOperation: ${calculator.lastOperation}");
      print("===================================");
    if (calculator.isPureNumericCalculation && calculator.numericResult != null) {
      print("进入: buildPureNumericResultDisplay");
      return buildPureNumericResultDisplay();
    }

    if (calculator.isCommonDenominatorResult) {
      return buildCommonDenominatorDisplay();
    }

    if (calculator.isDualConversionResult) {
      return buildDualConversionDisplay();
    }

    if (calculator.calculationResult != null) {
      return buildCalculationResultDisplay();
    }

    if (calculator.currentState == CalculatorState.waitingForSecond) {
      return buildWaitingForSecondDisplay();
    }

    if (calculator.currentState != CalculatorState.normal) {
      startBlinkAnimationIfNeeded();
      return buildSpecialStateDisplay();
    }

    return buildCurrentInputDisplay();
  }

  Widget buildPureNumericResultDisplay() {
        return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatNumericResult(calculator.numericResult!),
          style: const TextStyle(
              fontSize: 47,
              color: Colors.white,
              fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 4),
        if (calculator.calculationResult != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "= ",
                  style: TextStyle(fontSize: 20, color: Color(0xFF00FF88))
              ),
              buildMiniFractionDisplay(calculator.calculationResult!),
            ],
          ),
        ],
      ],
    );
  }

  String formatNumericResult(double value) {
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

      result = value.toStringAsFixed(7);
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }

    return result;
  }

  Widget buildCommonDenominatorDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildFractionDisplay(calculator.firstCommonResult!),
        const Text(", ", style: TextStyle(fontSize: 33, color: Colors.white)),
        buildFractionDisplay(calculator.secondCommonResult!),
      ],
    );
  }

  Widget buildDualConversionDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildFractionDisplay(calculator.firstConversionResult!),
        const Text(", ", style: TextStyle(fontSize: 33, color: Colors.white)),
        buildFractionDisplay(calculator.secondConversionResult!),
      ],
    );
  }

  Widget buildCalculationResultDisplay() {
    if (calculator.isFractionConversionResult && calculator.originalDecimalInput != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            calculator.originalDecimalInput!,
            style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            "=",
            style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          buildFractionDisplay(calculator.calculationResult!),
        ],
      );
    }

    if (calculator.isDecimalConversionResult && calculator.decimalConversionValue != null) {
      String symbol = calculator.isApproximateDecimal ? "≈" : "=";
      String decimalText = formatNumericResult(calculator.decimalConversionValue!);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildFractionDisplay(calculator.originalDecimalConversionInput!),
          const SizedBox(width: 8),
          Text(
            symbol,
            style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            decimalText,
            style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildFractionDisplay(calculator.calculationResult!),
        if (calculator.shouldShowDecimalApproximation(calculator.calculationResult!)) ...[
          const SizedBox(width: 6),
          Text(
            '${calculator.getDecimalSymbol(calculator.calculationResult!)}${calculator.calculationResult!.toDecimal().toStringAsFixed(3)}',
            style: const TextStyle(fontSize: 23, color: Color(0xFF00FF88)),
          ),
        ],
      ],
    );
  }

  Widget buildWaitingForSecondDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (calculator.firstOperand != null || calculator.firstNumericOperand != null) ...[
          if (calculator.isPureNumericCalculation && calculator.firstNumericOperand != null)
            Text(
              formatNumericResult(calculator.firstNumericOperand!),
              style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
            )
          else if (calculator.firstOperand != null)
            buildFractionDisplay(calculator.firstOperand!)
          else
            const Text("0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600))
        ] else ...[
          const Text("0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600))
        ],

        const SizedBox(width: 8),

        Text(
          calculator.getOperatorSymbol(calculator.pendingOperation ?? ""),
          style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w600),
        ),

        if (calculator.hasValidCurrentInput()) ...[
          const SizedBox(width: 8),
          if (calculator.isCurrentInputDecimal)
            Text(
              formatNumericResult(calculator.getCurrentDecimalValue()),
              style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
            )
          else
            buildFractionDisplay(calculator.currentFraction),
        ],
      ],
    );
  }
  Widget buildSpecialStateDisplay() {
      return buildSpecialOperatorDisplay(calculator.lastOperation);
    }

    Widget buildSpecialOperatorDisplay(String? operation) {
      if (operation == null) return buildCurrentInputDisplay();

      switch (operation) {
        case '对数':
          return buildLogarithmDisplay();
        case 'n次方':
          return buildPowerDisplay();
        case 'n次根':
          return buildRootDisplay();
        default:
          return buildCurrentInputDisplay();
      }
    }

    Widget buildLogarithmDisplay() {
      bool isUsingDefault = !calculator.hasValidCurrentInput();
      String baseText = calculator.hasValidCurrentInput()
          ? getFractionText(calculator.currentFraction)
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
              animation: blinkAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: blinkAnimation.value,
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
          if (calculator.baseNumber != null)
            buildFractionDisplay(calculator.baseNumber!)
          else
            const Text("1", style: TextStyle(fontSize: 33, color: Colors.white)),
          const Text(')', style: TextStyle(fontSize: 33, color: Colors.white)),
        ],
      );
    }

    Widget buildPowerDisplay() {
      bool isUsingDefault = !calculator.hasValidCurrentInput();
      String exponentText = calculator.hasValidCurrentInput()
          ? getFractionText(calculator.currentFraction)
          : "4";

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (calculator.baseNumber != null)
            buildFractionDisplay(calculator.baseNumber!)
          else
            const Text("1", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600)),
          Transform.translate(
            offset: const Offset(0, -8),
            child: isUsingDefault
                ? AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: blinkAnimation.value,
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

    Widget buildRootDisplay() {
      bool isUsingDefault = !calculator.hasValidCurrentInput();
      String rootText = calculator.hasValidCurrentInput()
          ? getFractionText(calculator.currentFraction)
          : "4";

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -8),
            child: isUsingDefault
                ? AnimatedBuilder(
              animation: blinkAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: blinkAnimation.value,
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
          if (calculator.baseNumber != null)
            buildFractionDisplay(calculator.baseNumber!)
          else
            const Text("1", style: TextStyle(fontSize: 33, color: Colors.white)),
        ],
      );
    }

  Widget buildCurrentInputDisplay() {
    if (calculator.isCurrentInputDecimal) {
      // 输入阶段显示原始字符串，不格式化
      String displayText = calculator.integerInput;
      return Text(
        displayText,
        style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600),
      );
    } else {
      return buildFractionDisplay(calculator.currentFraction);
    }
  }

    String getFractionText(Fraction fraction) {
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

    Widget buildFractionDisplay(Fraction fraction) {
      // 【新增】计算结果为0时直接显示0
      if (calculator.calculationResult != null &&
          calculator.calculationResult!.integerPart == 0 &&
          calculator.calculationResult!.numerator == 0) {
        return const Text("0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
      }

      final integerStr = fraction.integerPart.toString();
      final numeratorStr = fraction.numerator.toString();
      final denominatorStr = fraction.denominator.toString();

      bool onlyNumeratorInput = calculator.hasOnlyNumeratorInput();
      bool onlyDenominatorInput = calculator.hasOnlyDenominatorInput();

      // 特殊情况1：只输入分子
      if (onlyNumeratorInput && fraction.denominator == 1) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(numeratorStr, style: const TextStyle(fontSize: 33, color: Colors.white, fontWeight: FontWeight.w600)),
                Container(width: math.max(25, numeratorStr.length * 16.5), height: 1.5, color: Colors.white),
                const Text(" ", style: TextStyle(fontSize: 33, color: Colors.transparent, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        );
      }

      // 特殊情况2：只输入分母
      if (onlyDenominatorInput && fraction.numerator == 0) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(" ", style: TextStyle(fontSize: 33, color: Colors.transparent, fontWeight: FontWeight.w600)),
                Container(width: math.max(25, denominatorStr.length * 16.5), height: 1.5, color: Colors.white),
                Text(denominatorStr, style: const TextStyle(fontSize: 33, color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        );
      }

      // 特殊情况3：空输入或纯0状态
      if (fraction.integerPart == 0 && fraction.numerator == 0) {
        String integerText = calculator.integerInput;
        if (integerText.isEmpty) {
          return const Text("0", style: TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
        } else {
          return Text(integerText, style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
        }
      }

      // 特殊情况4：纯整数显示
      if (fraction.denominator == 1 && fraction.numerator == 0) {
        String displayText = calculator.integerInput.isNotEmpty ? calculator.integerInput : integerStr;
        return Text(displayText, style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600));
      }

      // 一般情况：完整分数显示
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 整数部分
          if (fraction.integerPart != 0) ...[
            Text(integerStr, style: const TextStyle(fontSize: 47, color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
          ],

          // 分数部分
          if (calculator.hasUserInputDenominator || fraction.numerator != 0) ...[
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
  Widget buildMiniOriginalExpression() {
      if (calculator.calculationResult != null) {
        if (calculator.isPureNumericCalculation && calculator.numericResult != null) {
          return buildPureNumericMiniExpression();
        }

        if (calculator.isCommonDenominatorResult &&
            calculator.originalFirstOperand != null &&
            calculator.originalSecondOperand != null) {
          return buildExpressionRow([
            buildMiniFractionDisplay(calculator.originalFirstOperand!),
            Text(" ${'fraction_common'.tr()} ", style: const TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(calculator.originalSecondOperand!),
          ]);
        }

        if (calculator.isDualConversionResult && calculator.effectiveOriginalValue != null) {
          return buildExpressionRow([
            buildMiniFractionDisplay(calculator.effectiveOriginalValue!),
            Text(" ${'fraction_convert'.tr()}", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
        }

        if (calculator.isUnaryResult && calculator.effectiveOriginalValue != null) {
          return buildUnaryOperationExpression();
        }

        if (!calculator.isUnaryResult &&
            calculator.firstOperand != null &&
            calculator.secondOperand != null &&
            calculator.lastOperation != null) {
          return buildBinaryOperationExpression();
        }
      }

      if (calculator.currentState == CalculatorState.waitingForSecond &&
          (calculator.firstOperand != null || calculator.firstNumericOperand != null) &&
          calculator.hasValidCurrentInput() &&
          calculator.pendingOperation != null) {
        return buildWaitingExpression();
      }

      return const SizedBox.shrink();
    }

    Widget buildPureNumericMiniExpression() {
      if (calculator.isUnaryResult && calculator.effectiveOriginalValue != null) {
        String originalText = formatNumericResult(calculator.effectiveOriginalValue!.toDecimal());
        String? operation = calculator.lastOperation;

        switch (operation) {
          case '平方根':
            return buildExpressionRow([
              const Text("√", style: TextStyle(fontSize: 14, color: Colors.white70)),
              Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ]);
          case '立方根':
            return buildExpressionRow([
              const Text("∛", style: TextStyle(fontSize: 14, color: Colors.white70)),
              Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ]);
          case '自然对数':
            return buildExpressionRow([
              const Text("ln", style: const TextStyle(fontSize: 14, color: Colors.white70)),
              Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ]);
          case '平方':
            return buildExpressionRow([
              Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              const Text("²", style: TextStyle(fontSize: 14, color: Colors.white70)),
            ]);
          case '立方':
            return buildExpressionRow([
              Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              const Text("³", style: TextStyle(fontSize: 14, color: Colors.white70)),
            ]);
          case '倒数':
            return buildExpressionRow([
              const Text("1/", style: TextStyle(fontSize: 14, color: Colors.white70)),
              Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ]);

          default:
            String operatorText = getOperatorDisplayText(operation ?? "");
            return buildExpressionRow([
              Text(originalText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              Text(" $operatorText", style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ]);
        }
      } else if (calculator.firstOperand != null && calculator.secondOperand != null) {
        String firstText = formatNumericResult(calculator.firstOperand!.toDecimal());
        String secondText = formatNumericResult(calculator.secondOperand!.toDecimal());
        String operatorSymbol = calculator.getOperatorSymbol(calculator.lastOperation ?? "");
        return buildExpressionRow([
          Text(firstText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          Text(" $operatorSymbol ", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          Text(secondText, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ]);
      }
      return const SizedBox.shrink();
    }

    Widget buildUnaryOperationExpression() {
      String? operation = calculator.lastOperation;
      Fraction? originalValue = calculator.effectiveOriginalValue;
      if (operation == null || originalValue == null) return const SizedBox.shrink();

      switch (operation) {
        case '对数':
          Widget baseWidget = calculator.parameter != null
              ? buildMiniFractionDisplay(calculator.parameter!)
              : const Text("10", style: TextStyle(fontSize: 10, color: Colors.white70));
          return buildExpressionRow([
            const Text("log", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Transform.translate(
              offset: const Offset(0, 4),
              child: baseWidget,
            ),
            const Text("(", style: TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
            const Text(")", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]);

        case 'n次方':
          Widget exponentWidget = calculator.parameter != null
              ? buildMiniFractionDisplay(calculator.parameter!)
              : const Text("4", style: TextStyle(fontSize: 10, color: Colors.white70));
          return buildExpressionRow([
            buildMiniFractionDisplay(originalValue),
            Transform.translate(
              offset: const Offset(0, -4),
              child: exponentWidget,
            ),
          ]);

        case 'n次根':
          Widget rootWidget = calculator.parameter != null
              ? buildMiniFractionDisplay(calculator.parameter!)
              : const Text("4", style: TextStyle(fontSize: 10, color: Colors.white70));
          return buildExpressionRow([
            Transform.translate(
              offset: const Offset(0, -4),
              child: rootWidget,
            ),
            const Text("√", style: TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
          ]);

        case '平方根':
          return buildExpressionRow([
            const Text("√", style: TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
          ]);

        case '立方根':
          return buildExpressionRow([
            const Text("∛", style: TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
          ]);

        case '自然对数':
          return buildExpressionRow([
            const Text("ln", style: TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
          ]);

        case '平方':
          return buildExpressionRow([
            buildMiniFractionDisplay(originalValue),
            const Text("²", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]);

        case '立方':
          return buildExpressionRow([
            buildMiniFractionDisplay(originalValue),
            const Text("³", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]);

        case '倒数':
          return buildExpressionRow([
            const Text("1/", style: TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
          ]);

        case '约分':
          return buildExpressionRow([
            Text("${'fraction_simplify'.tr()}(", style: const TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
            const Text(")", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]);

        case '转换':
          return buildExpressionRow([
            Text("${'fraction_convert'.tr()}(", style: const TextStyle(fontSize: 14, color: Colors.white70)),
            buildMiniFractionDisplay(originalValue),
            const Text(")", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ]);


        default:
          String operatorText = getOperatorDisplayText(operation);
          return buildExpressionRow([
            buildMiniFractionDisplay(originalValue),
            Text(" $operatorText", style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ]);
      }
    }

    Widget buildBinaryOperationExpression() {
      return buildExpressionRow([
        if (calculator.isPureNumericCalculation)
          Text(formatNumericResult(calculator.firstOperand!.toDecimal()),
              style: const TextStyle(fontSize: 14, color: Colors.white70))
        else
          buildMiniFractionDisplay(calculator.firstOperand!),
        Text(" ${calculator.getOperatorSymbol(calculator.lastOperation!)} ",
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
        if (calculator.isPureNumericCalculation)
          Text(formatNumericResult(calculator.secondOperand!.toDecimal()),
              style: const TextStyle(fontSize: 14, color: Colors.white70))
        else
          buildMiniFractionDisplay(calculator.secondOperand!),
      ]);
    }

    Widget buildWaitingExpression() {
      return buildExpressionRow([
        if (calculator.isPureNumericCalculation && calculator.firstNumericOperand != null)
          Text(formatNumericResult(calculator.firstNumericOperand!),
              style: const TextStyle(fontSize: 14, color: Colors.white70))
        else if (calculator.firstOperand != null)
          buildMiniFractionDisplay(calculator.firstOperand!)
        else
          const Text("0", style: TextStyle(fontSize: 14, color: Colors.white70)),
        Text(" ${calculator.getOperatorSymbol(calculator.pendingOperation!)} ",
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
        calculator.isCurrentInputDecimal
            ? Text(formatNumericResult(calculator.getCurrentDecimalValue()),
                style: const TextStyle(fontSize: 14, color: Colors.white70))
            : buildMiniFractionDisplay(calculator.currentFraction),
      ]);
    }

    Widget buildExpressionRow(List<Widget> widgets) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
      );
    }

    Widget buildMiniFractionDisplay(Fraction fraction) {
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

            String getOperatorDisplayText(String operation) {
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

            bool isComplexLogarithm() {
              if (calculator.lastOperation == '对数' &&
                  calculator.isUnaryResult &&
                  calculator.parameter != null) {
                double baseValue = calculator.parameter!.toDecimal();
                return (baseValue - 10.0).abs() > 0.0001;
              }
              return false;
            }

            @override
            void dispose() {
              debounceTimer?.cancel();
              blinkController.dispose();
              super.dispose();
            }

            @override
            Widget build(BuildContext context) {
              return Directionality(
                textDirection: ui.TextDirection.ltr,
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
                                    textDirection: ui.TextDirection.rtl,
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
                                          if (calculator.calculationResult != null)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: buildMiniOriginalExpression(),
                                                ),
                                                if (calculator.shouldShowHistory &&
                                                    !calculator.isPureNumericCalculation &&
                                                    (!calculator.isUnaryResult || isComplexLogarithm()))
                                                  GestureDetector(
                                                    onTap: () => inputComponents.showCalculationProcess(),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF00FF88).withValues(alpha: 0.2),
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
                                              child: buildCalculationDisplay(),
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
                                          child: inputComponents.buildIntegerKeyboard(),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          flex: 46,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2a2a2a),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 49,
                                                  child: inputComponents.buildNumeratorKeyboard(),
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
                                                  child: inputComponents.buildDenominatorKeyboard(),
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
                                    child: inputComponents.buildOperators(),
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