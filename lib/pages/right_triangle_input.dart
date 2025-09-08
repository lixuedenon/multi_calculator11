import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'right_triangle_layout_calculator.dart';
import '../utils/right_triangle_calculator.dart';

class RightTriangleInput extends StatefulWidget {
  final Map<String, String> values;
  final Function(String, String) onChange;
  final String? activeInput;
  final Function(String) setActiveInput;
  final LayoutResult layout;
  final Function(String) showAngleError;

  const RightTriangleInput({
    Key? key,
    required this.values,
    required this.onChange,
    this.activeInput,
    required this.setActiveInput,
    required this.layout,
    required this.showAngleError,
  }) : super(key: key);

  @override
  State<RightTriangleInput> createState() => _RightTriangleInputState();
}

class _RightTriangleInputState extends State<RightTriangleInput> {
  Map<String, bool> _disabledInputs = {};

  @override
  void initState() {
    super.initState();
    _updateInputStates();
  }

  @override
  void didUpdateWidget(RightTriangleInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 直接调用更新，不做值比较（因为Map引用相同但内容可能不同）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateInputStates();
      }
    });
  }

  void _updateInputStates() {
    final isSufficient = RightTriangleCalculator.checkSufficientConditions(
      a: widget.values['a'],
      b: widget.values['b'],
      c: widget.values['c'],
      angleA: widget.values['angleA'],
      angleB: widget.values['angleB'],
      area: widget.values['area'],
    );

    setState(() {
      if (isSufficient) {
        // 满足计算条件时，禁用所有空的输入框
        final newDisabled = <String, bool>{};
        widget.values.forEach((key, value) {
          if (value?.isEmpty == true) {
            newDisabled[key] = true;
          }
        });
        _disabledInputs = newDisabled;
      } else {
        // 不满足条件时，启用所有输入框
        _disabledInputs = {};
      }
    });
  }

  void _handleInputChange(String name, String value) {
    // 角度验证
    if ((name == 'angleA' || name == 'angleB') && value.isNotEmpty) {
      final angleValue = double.tryParse(value);
      if (angleValue != null && angleValue >= 90) {
        widget.showAngleError('angleError'.tr());
        return;
      }
    }

    // 调用父组件的onChange
    widget.onChange(name, value);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(widget.layout.basePadding),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 第一行：直角边a和b
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildInputRow(context, 'directEdgeAShort'.tr(), 'a')),
                  SizedBox(width: widget.layout.componentSpacing),
                  Expanded(child: _buildInputRow(context, 'directEdgeBShort'.tr(), 'b')),
                ],
              ),
            ),
            SizedBox(height: widget.layout.componentSpacing),

            // 第二行：斜边c和锐角A
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildInputRow(context, 'hypotenuseShort'.tr(), 'c')),
                  SizedBox(width: widget.layout.componentSpacing),
                  Expanded(child: _buildInputRow(context, 'acuteAngleAShort'.tr(), 'angleA', unit: 'degrees'.tr())),
                ],
              ),
            ),
            SizedBox(height: widget.layout.componentSpacing),

            // 第三行：锐角B和面积
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildInputRow(context, 'acuteAngleBShort'.tr(), 'angleB', unit: 'degrees'.tr())),
                  SizedBox(width: widget.layout.componentSpacing),
                  Expanded(child: _buildInputRow(context, 'areaShort'.tr(), 'area')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(BuildContext context, String label, String name, {String? unit}) {
    final isActive = widget.activeInput == name;
    final isDisabled = _disabledInputs[name] ?? false;
    final hasValue = widget.values[name]?.isNotEmpty == true;

    // 根据输入类型设置文字颜色
    Color getTextColor() {
      switch (name) {
        case 'angleA':
        case 'angleB':
          return const Color(0xFFFBBF24);
        case 'a':
        case 'b':
        case 'c':
          return Colors.blue;
        case 'area':
          return Colors.red;
        default:
          return Colors.white;
      }
    }

    // 根据输入类型设置禁用符号颜色
    Color getDisabledIconColor() {
      switch (name) {
        case 'angleA':
        case 'angleB':
          return const Color(0xFFFBBF24); // 橙色
        case 'a':
        case 'b':
        case 'c':
          return Colors.blue; // 蓝色
        case 'area':
          return Colors.red; // 红色
        default:
          return Colors.grey[500]!;
      }
    }

    return Row(
      children: [
        // 标签部分
        SizedBox(
          width: widget.layout.labelWidth,
          child: Text(
            label,
            textDirection: ui.TextDirection.ltr,
            style: TextStyle(
              color: isDisabled
                  ? const Color(0xFFE5E7EB).withOpacity(0.5)
                  : const Color(0xFFE5E7EB),
              fontSize: widget.layout.fontSize,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: widget.layout.labelSpacing),

        // 输入框部分
        Expanded(
          child: Container(
            height: widget.layout.inputRowHeight,
            child: Stack(
              children: [
                TextFormField(
                  controller: TextEditingController(text: widget.values[name] ?? ''),
                  onChanged: isDisabled ? null : (value) => _handleInputChange(name, value),
                  onTap: isDisabled ? null : () => widget.setActiveInput(name),
                  enabled: !isDisabled,
                  keyboardType: TextInputType.none,
                  showCursor: !isDisabled,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isDisabled ? getTextColor().withOpacity(0.4) : getTextColor(),
                    fontSize: widget.layout.fontSize,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    hintText: isDisabled ? '' : '0',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: isDisabled
                        ? Colors.grey[750]
                        : isActive
                        ? Colors.grey[850]
                        : Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: isDisabled
                            ? Colors.grey[600]!
                            : isActive
                            ? Colors.blue
                            : Colors.grey[500]!,
                        width: isActive && !isDisabled ? 2 : 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey[500]!, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey[600]!, width: 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.layout.basePadding,
                      vertical: widget.layout.basePadding,
                    ),
                    isDense: true,
                  ),
                ),
                // 禁用符号
                if (isDisabled && !hasValue)
                  Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.block,
                        color: getDisabledIconColor(), // 使用匹配的颜色
                        size: widget.layout.fontSize + 4,
                      ),
                    ),
                  ),
                if (unit != null)
                  Positioned(
                    right: widget.layout.labelSpacing - 4,
                    top: 1,
                    child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Text(
                        unit,
                        style: TextStyle(
                          color: isDisabled
                              ? Colors.grey[500]
                              : Colors.grey[400],
                          fontSize: widget.layout.isCompactMode ? 16 : 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}