import 'package:flutter/material.dart';
import 'right_triangle_layout_calculator.dart';

class RightTriangleKeyboard extends StatelessWidget {
  final Function(String) onInput;
  final Function() onClear;
  final Function() onBackspace;
  final Function() onCalculate;
  final LayoutResult layout;

  const RightTriangleKeyboard({
    Key? key,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
    required this.onCalculate,
    required this.layout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 左侧数字键盘区域
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // 第一行：7 8 9
                Expanded(
                  child: Row(
                    children: [
                      _buildNumberButton('7'),
                      const SizedBox(width: 8),
                      _buildNumberButton('8'),
                      const SizedBox(width: 8),
                      _buildNumberButton('9'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 第二行：4 5 6
                Expanded(
                  child: Row(
                    children: [
                      _buildNumberButton('4'),
                      const SizedBox(width: 8),
                      _buildNumberButton('5'),
                      const SizedBox(width: 8),
                      _buildNumberButton('6'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 第三行：1 2 3
                Expanded(
                  child: Row(
                    children: [
                      _buildNumberButton('1'),
                      const SizedBox(width: 8),
                      _buildNumberButton('2'),
                      const SizedBox(width: 8),
                      _buildNumberButton('3'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 第四行：0 . ⌫
                Expanded(
                  child: Row(
                    children: [
                      _buildNumberButton('0'),
                      const SizedBox(width: 8),
                      _buildNumberButton('.'),
                      const SizedBox(width: 8),
                      _buildBackspaceButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 右侧功能按钮区域
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // C按钮（占上半部分）
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onClear,
                        child: Center(
                          child: Text(
                            'C',
                            style: TextStyle(
                              fontSize: layout.buttonSize * 0.6,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // =按钮（占下半部分）
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onCalculate,
                        child: Center(
                          child: Text(
                            '=',
                            style: TextStyle(
                              fontSize: layout.buttonSize * 0.6,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 数字按钮（统一样式）
  Widget _buildNumberButton(String text) {
    return Expanded(
      child: Container(
        height: layout.buttonSize,
        decoration: BoxDecoration(
          color: const Color(0xFF4B5563),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF6B7280), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onInput(text),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: layout.buttonSize * 0.6,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 退格按钮（红色，图标）
  Widget _buildBackspaceButton() {
    return Expanded(
      child: Container(
        height: layout.buttonSize,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onBackspace,
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                color: Colors.white,
                size: layout.buttonSize * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}