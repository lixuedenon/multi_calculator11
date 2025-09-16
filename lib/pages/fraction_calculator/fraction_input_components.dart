// fraction_input_components.dart - RTL修复完整版（添加简单负号功能）

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/fraction_calculator/fraction_calculator_logic.dart';
import '../../utils/fraction_calculator/fraction_models.dart';
import 'fraction_calculation_process_page.dart';

// 动画按钮组件（RTL修复版）
class AnimatedPressButton extends StatefulWidget {
  final String text;
  final double? width;
  final double height;
  final Color color;
  final VoidCallback onPressed;
  final double fontSize;
  final Widget? customChild;
  final ui.TextDirection? textDirection; // 新增参数

  const AnimatedPressButton({
    super.key,
    required this.text,
    this.width,
    required this.height,
    required this.color,
    required this.onPressed,
    required this.fontSize,
    this.customChild,
    this.textDirection, // 新增参数
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _controller.forward();
    _performHapticFeedback();
  }

  void _performHapticFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 10));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      try {
        await HapticFeedback.vibrate();
      } catch (e2) {
        print('触感反馈失败: $e, $e2');
      }
    }
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.color,
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: Center(
                child: widget.customChild ??
                    (widget.textDirection != null
                        ? Directionality(
                      textDirection: widget.textDirection!,
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 输入组件和交互处理类
class FractionInputComponents {
  final FractionCalculatorLogic calculator;
  final BuildContext context;
  final VoidCallback onStateChanged;

  FractionInputComponents({
    required this.calculator,
    required this.context,
    required this.onStateChanged,
  });

  // ================== 按钮构建方法 ==================

  Widget buildNumberButton(String text, Color color, VoidCallback onPressed) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonHeight = constraints.maxHeight;
        return AnimatedPressButton(
          text: text,
          width: null,
          height: buttonHeight,
          color: color,
          onPressed: onPressed,
          fontSize: buttonHeight * 0.6,
          textDirection: null, // 数字按钮保持LTR
        );
      },
    );
  }

  Widget buildOperatorButton(String text, Color color, VoidCallback onPressed, {bool isTranslatable = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonHeight = constraints.maxHeight;
        return AnimatedPressButton(
          text: text,
          width: null,
          height: buttonHeight,
          color: color,
          onPressed: onPressed,
          fontSize: buttonHeight * 0.64,
          textDirection: isTranslatable ? ui.TextDirection.rtl : null, // 可翻译文本使用RTL
        );
      },
    );
  }

  // ================== 键盘构建方法 ==================

  Widget buildIntegerKeyboard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('C', const Color(0xFF994433), () => handleIntegerInput('C'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('⌫', const Color(0xFF994433), () => handleIntegerInput('⌫'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('1', const Color(0xFF4a4a4a), () => handleIntegerInput('1'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('2', const Color(0xFF4a4a4a), () => handleIntegerInput('2'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('3', const Color(0xFF4a4a4a), () => handleIntegerInput('3'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('4', const Color(0xFF4a4a4a), () => handleIntegerInput('4'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('5', const Color(0xFF4a4a4a), () => handleIntegerInput('5'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('6', const Color(0xFF4a4a4a), () => handleIntegerInput('6'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('7', const Color(0xFF4a4a4a), () => handleIntegerInput('7'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('8', const Color(0xFF4a4a4a), () => handleIntegerInput('8'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('9', const Color(0xFF4a4a4a), () => handleIntegerInput('9'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('0', const Color(0xFF4a4a4a), () => handleIntegerInput('0'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // 【修改】恢复+/-按钮，与小数点按钮并排
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double buttonHeight = constraints.maxHeight;
                      return AnimatedPressButton(
                        text: 'D↔F',
                        width: null,
                        height: buttonHeight,
                        color: const Color(0xFF444444),
                        onPressed: () => handleIntegerInput('D↔F'),
                        fontSize: buttonHeight * 0.32,  // 缩小字体
                      );
                    },
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('.', const Color(0xFF444444), () => handleIntegerInput('.'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumeratorKeyboard() {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('1', const Color(0xFF4a4a4a), () => handleNumeratorInput('1'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('2', const Color(0xFF4a4a4a), () => handleNumeratorInput('2'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('3', const Color(0xFF4a4a4a), () => handleNumeratorInput('3'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('4', const Color(0xFF4a4a4a), () => handleNumeratorInput('4'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('5', const Color(0xFF4a4a4a), () => handleNumeratorInput('5'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('6', const Color(0xFF4a4a4a), () => handleNumeratorInput('6'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('7', const Color(0xFF4a4a4a), () => handleNumeratorInput('7'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('8', const Color(0xFF4a4a4a), () => handleNumeratorInput('8'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('9', const Color(0xFF4a4a4a), () => handleNumeratorInput('9'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('0', const Color(0xFF4a4a4a), () => handleNumeratorInput('0'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('C', const Color(0xFF994433), () => handleNumeratorClear())),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('⌫', const Color(0xFF994433), () => handleNumeratorInput('⌫'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDenominatorKeyboard() {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('1', const Color(0xFF4a4a4a), () => handleDenominatorInput('1'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('2', const Color(0xFF4a4a4a), () => handleDenominatorInput('2'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('3', const Color(0xFF4a4a4a), () => handleDenominatorInput('3'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('4', const Color(0xFF4a4a4a), () => handleDenominatorInput('4'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('5', const Color(0xFF4a4a4a), () => handleDenominatorInput('5'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('6', const Color(0xFF4a4a4a), () => handleDenominatorInput('6'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('7', const Color(0xFF4a4a4a), () => handleDenominatorInput('7'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('8', const Color(0xFF4a4a4a), () => handleDenominatorInput('8'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('9', const Color(0xFF4a4a4a), () => handleDenominatorInput('9'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildNumberButton('0', const Color(0xFF4a4a4a), () => handleDenominatorInput('0'))),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('C', const Color(0xFF994433), () => handleDenominatorClear())),
                const SizedBox(width: 2),
                Expanded(child: buildNumberButton('⌫', const Color(0xFF994433), () => handleDenominatorInput('⌫'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOperators() {
    const Color operatorColor = Color(0xFF3a3a3a);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildOperatorButton('+', operatorColor, () => handleOperator('加法'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('-', operatorColor, () => handleOperator('减法'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('×', operatorColor, () => handleOperator('乘法'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('÷', operatorColor, () => handleOperator('除法'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                // 约分按钮：显示4/8→，横向格式
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double buttonHeight = constraints.maxHeight;
                      double fontSize = (buttonHeight * 0.64) * 0.85;
                      return AnimatedPressButton(
                        text: '',
                        width: null,
                        height: buttonHeight,
                        color: operatorColor,
                        onPressed: () => handleOperator('约分'),
                        fontSize: fontSize,
                        customChild: Center(
                          child: Text(
                            '4/8→',
                            style: TextStyle(
                              fontSize: fontSize * 0.8,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 2),
                // 通分按钮：显示1/2 1/3→，横向格式
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double buttonHeight = constraints.maxHeight;
                      double fontSize = (buttonHeight * 0.64) * 0.85;
                      return AnimatedPressButton(
                        text: '',
                        width: null,
                        height: buttonHeight,
                        color: operatorColor,
                        onPressed: () => handleOperator('通分'),
                        fontSize: fontSize,
                        customChild: Center(
                          child: Text(
                            '1/2 1/3→',
                            style: TextStyle(
                              fontSize: fontSize * 0.65,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 2),
                // 转换按钮：两个箭头垂直居中
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double buttonHeight = constraints.maxHeight;
                      return AnimatedPressButton(
                        text: '',
                        width: null,
                        height: buttonHeight,
                        color: operatorColor,
                        onPressed: () => handleOperator('转换'),
                        fontSize: buttonHeight * 0.64,
                        customChild: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('←', style: TextStyle(fontSize: buttonHeight * 0.5, color: Colors.white, fontWeight: FontWeight.w600)),
                              Text('→', style: TextStyle(fontSize: buttonHeight * 0.5, color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('1/x', operatorColor, () => handleOperator('倒数'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildOperatorButton('x²', operatorColor, () => handleOperator('平方'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('x³', operatorColor, () => handleOperator('立方'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('√', operatorColor, () => handleOperator('平方根'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('∛', operatorColor, () => handleOperator('立方根'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildOperatorButton('xⁿ', operatorColor, () => handleOperator('n次方'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('ⁿ√', operatorColor, () => handleOperator('n次根'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('log', operatorColor, () => handleOperator('对数'))),
                const SizedBox(width: 2),
                Expanded(child: buildOperatorButton('ln', operatorColor, () => handleOperator('自然对数'))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: buildOperatorButton('CA', const Color(0xFF994433), () => handleClearAll()),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 3,
                  child: buildOperatorButton('=', const Color(0xFF006622), () => handleCalculate()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== 事件处理方法 ==================

  void handleIntegerInput(String input) {
    if (input == 'C') {
      if (calculator.calculationResult != null) {
        final result = calculator.handleClearAll();
        _handleResult(result);
      } else {
        final result = calculator.handleIntegerInput(input);
        _handleResult(result);
      }
    } else {
      final result = calculator.handleIntegerInput(input);
      _handleResult(result);
    }
  }

  void handleNumeratorInput(String input) {
    final result = calculator.handleNumeratorInput(input);
    _handleResult(result);
  }

  void handleDenominatorInput(String input) {
    final result = calculator.handleDenominatorInput(input);
    _handleResult(result);
  }

  void handleNumeratorClear() {
    if (calculator.calculationResult != null) {
      final result = calculator.handleClearAll();
      _handleResult(result);
    } else {
      final result = calculator.handleNumeratorClear();
      _handleResult(result);
    }
  }

  void handleDenominatorClear() {
    if (calculator.calculationResult != null) {
      final result = calculator.handleClearAll();
      _handleResult(result);
    } else {
      final result = calculator.handleDenominatorClear();
      _handleResult(result);
    }
  }

  void handleOperator(String operator) {
    final result = calculator.handleOperator(operator);
    _handleResult(result);
  }

  void handleCalculate() {
    final result = calculator.handleCalculate();
    _handleResult(result);
  }

  void handleClearAll() {
    final result = calculator.handleClearAll();
    _handleResult(result);
  }

  void _handleResult(CalculatorResult result) {
    if (result.success) {
      onStateChanged();
    } else {
      showErrorDialog(result.errorMessage ?? 'Unknown error');
    }
  }

  // ================== 工具方法 ==================

  void showCalculationProcess() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculationProcessPage(
          calculationSteps: calculator.calculationSteps,
        ),
      ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.ltr, // 对话框布局使用LTR
          child: AlertDialog(
            backgroundColor: const Color(0xFF2a2a2a),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Directionality(
              textDirection: ui.TextDirection.rtl, // 错误标题文本使用RTL
              child: Text(
                  'error'.tr(),
                  style: const TextStyle(
                      color: Color(0xFFFF4444),
                      fontWeight: FontWeight.bold
                  )
              ),
            ),
            content: Directionality(
              textDirection: ui.TextDirection.rtl, // 错误消息文本使用RTL
              child: Text(
                  message,
                  style: const TextStyle(color: Colors.white)
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Directionality(
                  textDirection: ui.TextDirection.rtl, // 按钮文本使用RTL
                  child: Text(
                      'ok'.tr(),
                      style: const TextStyle(
                          color: Color(0xFF00FF88),
                          fontWeight: FontWeight.w600
                      )
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}