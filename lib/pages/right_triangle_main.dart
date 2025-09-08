import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../utils/right_triangle_calculator.dart';
import 'right_triangle_display.dart';
import 'right_triangle_input.dart';
import 'right_triangle_keyboard.dart';
import 'right_triangle_layout_calculator.dart';
import 'package:easy_localization/easy_localization.dart';

class RightTriangleMain extends StatefulWidget {
  const RightTriangleMain({Key? key}) : super(key: key);

  @override
  State<RightTriangleMain> createState() => _RightTriangleMainState();
}

class _RightTriangleMainState extends State<RightTriangleMain> {
  Map<String, String> inputValues = {
    'a': '',
    'b': '',
    'c': '',
    'angleA': '',
    'angleB': '',
    'area': '',
  };

  String? activeInput = 'a';
  TriangleResult? result;

  @override
  void initState() {
    super.initState();
  }

  void _handleInputChange(String name, String value) {
    setState(() {
      inputValues[name] = value;
    });
  }

  void _handleKeyboardInput(String value) {
    if (activeInput == null) return;

    final currentValue = inputValues[activeInput!] ?? '';
    String newValue;

    if (value == '.') {
      if (currentValue.contains('.')) return;
      newValue = currentValue + '.';
    } else {
      newValue = currentValue + value;
    }

    _handleInputChange(activeInput!, newValue);
  }

  void _handleBackspace() {
    if (activeInput == null) return;

    final currentValue = inputValues[activeInput!] ?? '';
    if (currentValue.isNotEmpty) {
      final newValue = currentValue.substring(0, currentValue.length - 1);
      _handleInputChange(activeInput!, newValue);
    }
  }

  void _handleCalculate() {
    final isSufficient = RightTriangleCalculator.checkSufficientConditions(
      a: inputValues['a'],
      b: inputValues['b'],
      c: inputValues['c'],
      angleA: inputValues['angleA'],
      angleB: inputValues['angleB'],
      area: inputValues['area'],
    );

    if (!isSufficient) {
      _showError('error'.tr(), 'minimumConditions'.tr());
      return;
    }

    final calculationResult = RightTriangleCalculator.calculate(
      a: inputValues['a'],
      b: inputValues['b'],
      c: inputValues['c'],
      angleA: inputValues['angleA'],
      angleB: inputValues['angleB'],
      area: inputValues['area'],
    );

    if (calculationResult != null) {
      setState(() {
        result = calculationResult;

        // 填充所有空的输入框
        if (inputValues['a']?.isEmpty == true && calculationResult.a != null) {
          inputValues['a'] = RightTriangleCalculator.formatNumber(calculationResult.a);
        }
        if (inputValues['b']?.isEmpty == true && calculationResult.b != null) {
          inputValues['b'] = RightTriangleCalculator.formatNumber(calculationResult.b);
        }
        if (inputValues['c']?.isEmpty == true && calculationResult.c != null) {
          inputValues['c'] = RightTriangleCalculator.formatNumber(calculationResult.c);
        }
        if (inputValues['angleA']?.isEmpty == true && calculationResult.angleA != null) {
          inputValues['angleA'] = RightTriangleCalculator.formatNumber(calculationResult.angleA);
        }
        if (inputValues['angleB']?.isEmpty == true && calculationResult.angleB != null) {
          inputValues['angleB'] = RightTriangleCalculator.formatNumber(calculationResult.angleB);
        }
        if (inputValues['area']?.isEmpty == true && calculationResult.area != null) {
          inputValues['area'] = RightTriangleCalculator.formatNumber(calculationResult.area);
        }
      });
    } else {
      _showError('error'.tr(), 'calculationError'.tr());
    }
  }

  void _handleClear() {
    setState(() {
      inputValues = {
        'a': '',
        'b': '',
        'c': '',
        'angleA': '',
        'angleB': '',
        'area': '',
      };
      activeInput = 'a';
      result = null;
    });
  }

  void _setActiveInput(String input) {
    setState(() {
      activeInput = input;
    });
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFF4444),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue[400]),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: LayoutBuilder(
          builder: (context, constraints) {
            final layout = RightTriangleLayoutCalculator.calculateLayout(context);

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(layout.basePadding),
                child: Column(
                  children: [
                    // AppBar
                    Container(
                      height: 56.0,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: const Color(0xFF00FF88),
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'rightTriangleCalculator'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF6B35),
                                fontSize: layout.fontSize + 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[800],
                                    title: Text(
                                      'usageInstructions'.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: layout.fontSize,
                                      ),
                                    ),
                                    content: Text(
                                      'minimumConditions'.tr(),
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: layout.fontSize - 2,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text(
                                          'OK',
                                          style: TextStyle(color: Colors.blue[400]),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.blue[400],
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: layout.componentSpacing),

                    // 三角形显示区域
                    Container(
                      height: layout.displayHeight,
                      child: RightTriangleDisplay(
                        result: result,
                        inputValues: inputValues,
                        activeInput: activeInput,
                      ),
                    ),

                    SizedBox(height: layout.componentSpacing),

                    // 输入面板
                    Container(
                      height: layout.inputHeight,
                      child: RightTriangleInput(
                        values: inputValues,
                        onChange: _handleInputChange,
                        activeInput: activeInput,
                        setActiveInput: _setActiveInput,
                        layout: layout,
                        showAngleError: (message) => _showError('error'.tr(), message),
                      ),
                    ),

                    SizedBox(height: layout.componentSpacing),

                    // 键盘和按钮区域
                    Container(
                      height: layout.keyboardHeight,
                      child: RightTriangleKeyboard(
                        onInput: _handleKeyboardInput,
                        onClear: _handleClear,
                        onBackspace: _handleBackspace,
                        onCalculate: _handleCalculate,
                        layout: layout,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}