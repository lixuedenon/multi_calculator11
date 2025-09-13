// fraction_calculation_process_page.dart - RTL修复完整版

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/fraction_calculator/fraction_models.dart';

class CalculationProcessPage extends StatelessWidget {
  final List<CalculationStep> calculationSteps;

  const CalculationProcessPage({
    super.key,
    required this.calculationSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr, // 整个页面使用LTR布局
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE0E0E0),
          elevation: 1,
          title: Directionality(
            textDirection: ui.TextDirection.rtl, // 只有标题使用RTL
            child: Text(
              'calculation_history'.tr(),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: calculationSteps.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history,
                size: 64,
                color: Colors.black26,
              ),
              const SizedBox(height: 16),
              Directionality(
                textDirection: ui.TextDirection.rtl, // 提示文本使用RTL
                child: Text(
                  'no_calculation_records'.tr(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: calculationSteps.length,
          itemBuilder: (context, index) {
            final step = calculationSteps[index];
            return _buildCalculationCard(step, index);
          },
        ),
      ),
    );
  }

  Widget _buildCalculationCard(CalculationStep step, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 步骤标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl, // 操作类型文本使用RTL
                    child: Text(
                      _translateOperation(step.operation),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 原始表达式
            _buildSectionTitle('original_expression'.tr()),
            const SizedBox(height: 8),
            _buildExpressionDisplay(step.input),

            const SizedBox(height: 16),

            // 详细计算过程
            if (step.detailProcess != null && step.detailProcess!.isNotEmpty) ...[
              _buildSectionTitle('detailed_calculation_steps'.tr()),
              const SizedBox(height: 8),
              _buildDetailedProcessSteps(step.detailProcess!),
              const SizedBox(height: 16),
            ],

            // 最终结果 - 支持双结果显示
            _buildSectionTitle('final_result'.tr()),
            const SizedBox(height: 8),
            _buildResultDisplay(step.result, step.detailProcess),

            // 时间戳
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.black38,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(step.timestamp),
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Directionality(
      textDirection: ui.TextDirection.rtl, // 节标题使用RTL
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExpressionDisplay(String expression) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: _parseAndDisplayMathExpression(expression),
    );
  }

  // 支持双结果显示的结果构建方法
  Widget _buildResultDisplay(String result, String? detailProcess) {
    // 检查是否有双结果标记
    bool hasDualResult = detailProcess != null && detailProcess.contains('【双结果】');

    if (hasDualResult) {
      // 提取双结果信息
      String dualResultLine = detailProcess!.split('\n').firstWhere(
            (line) => line.contains('【双结果】'),
        orElse: () => '',
      );

      if (dualResultLine.isNotEmpty) {
        // 解析双结果：【双结果】：116 2/3 , [FRACTION:350:3]
        String resultsPart = dualResultLine.split('：')[1].trim();
        List<String> results = resultsPart.split(' , ');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一个结果
              if (results.length > 0) ...[
                Row(
                  children: [
                    const Icon(Icons.looks_one, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: _parseAndDisplayMathExpression(results[0].trim())),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // 第二个结果
              if (results.length > 1) ...[
                Row(
                  children: [
                    const Icon(Icons.looks_two, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: _parseAndDisplayMathExpression(results[1].trim())),
                  ],
                ),
              ],
            ],
          ),
        );
      }
    }

    // 检查是否为幂运算、根运算、对数运算且有小数结果
    bool isSpecialOperation = detailProcess != null && (
        detailProcess.contains('立方') ||
            detailProcess.contains('平方') ||
            detailProcess.contains('平方根') ||
            detailProcess.contains('立方根') ||
            detailProcess.contains('对数') ||
            detailProcess.contains('幂运算') ||
            detailProcess.contains('根运算')
    );

    if (isSpecialOperation) {
      // 解析结果，检查是否有小数形式
      try {
        // 从结果中提取分数
        if (result.contains('/') || result.contains(' ')) {
          // 尝试解析分数并计算小数值
          List<String> parts = result.split(' ');
          double decimalValue = 0.0;

          if (parts.length == 1 && parts[0].contains('/')) {
            // 纯分数：如 681/125
            List<String> fracParts = parts[0].split('/');
            if (fracParts.length == 2) {
              double num = double.parse(fracParts[0]);
              double den = double.parse(fracParts[1]);
              decimalValue = num / den;
            }
          } else if (parts.length >= 2) {
            // 带分数：如 681 59/125
            double integer = double.parse(parts[0]);
            if (parts[1].contains('/')) {
              List<String> fracParts = parts[1].split('/');
              if (fracParts.length == 2) {
                double num = double.parse(fracParts[0]);
                double den = double.parse(fracParts[1]);
                decimalValue = integer + (num / den);
              }
            }
          }

          // 如果计算出了小数值，显示双格式
          if (decimalValue != 0.0) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分数形式
                  Row(
                    children: [
                      const Icon(Icons.calculate, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: _parseAndDisplayMathExpression(result)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 小数形式
                  Row(
                    children: [
                      const Icon(Icons.numbers, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '≈ ${decimalValue.toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        // 解析失败，使用默认单结果显示
      }
    }

    // 单结果显示
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: _parseAndDisplayMathExpression(result),
    );
  }

  Widget _buildDetailedProcessSteps(String process) {
    List<String> steps = process.split('\n');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.asMap().entries.map((entry) {
          int index = entry.key;
          String step = entry.value.trim();

          if (step.isEmpty) return const SizedBox(height: 4);

          // 检查是否是步骤标题
          bool isStepTitle = step.startsWith('步骤') || step.startsWith('Step');

          // 检查是否是双结果标记行，如果是则跳过显示（因为会在结果区域显示）
          bool isDualResultLine = step.contains('【双结果】');
          if (isDualResultLine) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 只对非步骤标题行添加缩进
                if (!isStepTitle) ...[
                  const SizedBox(width: 16),
                ],
                // 步骤内容 - 数学表达式保持LTR，文本使用RTL
                Expanded(
                  child: _buildStepContent(step, isStepTitle),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepContent(String step, bool isStepTitle) {
    // 如果包含数学符号或分数，保持LTR显示
    if (_containsMathContent(step)) {
      return _parseAndDisplayMathExpression(step,
          style: TextStyle(
            fontSize: isStepTitle ? 13 : 12,
            fontWeight: isStepTitle ? FontWeight.w600 : FontWeight.normal,
            color: isStepTitle ? Colors.blue.shade700 : Colors.black87,
          ));
    } else {
      // 纯文本使用RTL
      return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Text(
          step,
          style: TextStyle(
            fontSize: isStepTitle ? 13 : 12,
            fontWeight: isStepTitle ? FontWeight.w600 : FontWeight.normal,
            color: isStepTitle ? Colors.blue.shade700 : Colors.black87,
          ),
        ),
      );
    }
  }

  // 检查文本是否包含数学内容
  bool _containsMathContent(String text) {
    return text.contains('/') ||
        text.contains('×') ||
        text.contains('÷') ||
        text.contains('+') ||
        text.contains('-') ||
        text.contains('=') ||
        text.contains('(') ||
        text.contains(')') ||
        text.contains('[FRACTION:') ||
        RegExp(r'\d+').hasMatch(text);
  }

  // 解析并显示数学表达式 - 数学内容保持LTR
  Widget _parseAndDisplayMathExpression(String expression, {TextStyle? style}) {
    List<Widget> widgets = [];

    TextStyle defaultStyle = style ?? const TextStyle(
      color: Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    // 处理特殊的手写分数标记 [FRACTION:分子表达式:分母表达式]
    RegExp handwrittenFractionRegex = RegExp(r'\[FRACTION:([^:]+):([^:]+)\]');

    // 原有的正则表达式
    RegExp fractionRegex = RegExp(r'(-?\d+)\s*/\s*(\d+)'); // 匹配 ±数字/数字
    RegExp mixedNumberRegex = RegExp(r'(-?\d+)\s+(\d+)\s*/\s*(\d+)'); // 匹配 ±整数 分子/分母

    // 简化复杂表达式匹配，避免与除法冲突
    RegExp complexExpressionRegex = RegExp(r'(\d+)\s*[×*]\s*(\d+)\s*/\s*(\d+)'); // 匹配 数字×数字/数字

    // 更精确的除法表达式匹配，避免误匹配
    RegExp divisionWithFractionRegex = RegExp(r'(\d+)\s*[÷]\s*(\d+)\s*/\s*(\d+)'); // 只匹配带÷号的除法

    String processedExpression = expression;
    List<Map<String, dynamic>> replacements = [];

    // 1. 首先找到所有手写分数标记
    Iterable<RegExpMatch> handwrittenMatches = handwrittenFractionRegex.allMatches(expression);
    for (RegExpMatch match in handwrittenMatches) {
      String numeratorExpr = match.group(1)!.trim();
      String denominatorExpr = match.group(2)!.trim();

      replacements.add({
        'start': match.start,
        'end': match.end,
        'type': 'handwritten_fraction',
        'numeratorExpr': numeratorExpr,
        'denominatorExpr': denominatorExpr,
        'original': match.group(0)!,
      });
    }

    // 2. 找到所有带分数（优先级高）
    Iterable<RegExpMatch> mixedMatches = mixedNumberRegex.allMatches(expression);
    for (RegExpMatch match in mixedMatches) {
      bool isPartOfHandwritten = replacements.any((r) =>
      match.start >= r['start'] && match.end <= r['end']);

      if (!isPartOfHandwritten) {
        String integer = match.group(1)!;
        String numerator = match.group(2)!;
        String denominator = match.group(3)!;

        replacements.add({
          'start': match.start,
          'end': match.end,
          'type': 'mixed',
          'integer': integer,
          'numerator': numerator,
          'denominator': denominator,
          'original': match.group(0)!,
        });
      }
    }

    // 3. 更精确地处理除法表达式
    Iterable<RegExpMatch> divisionMatches = divisionWithFractionRegex.allMatches(expression);
    for (RegExpMatch match in divisionMatches) {
      // 检查是否与已有匹配重叠
      bool isPartOfOther = replacements.any((r) =>
      (match.start >= r['start'] && match.end <= r['end']) ||
          (r['start'] >= match.start && r['end'] <= match.end));

      if (!isPartOfOther) {
        String dividend = match.group(1)!;
        String fractionNumerator = match.group(2)!;
        String fractionDenominator = match.group(3)!;

        replacements.add({
          'start': match.start,
          'end': match.end,
          'type': 'division_with_fraction',
          'dividend': dividend,
          'fractionNumerator': fractionNumerator,
          'fractionDenominator': fractionDenominator,
          'original': match.group(0)!,
        });
      }
    }

    // 4. 找到复杂表达式 (如 36*5/6)
    Iterable<RegExpMatch> complexMatches = complexExpressionRegex.allMatches(expression);
    for (RegExpMatch match in complexMatches) {
      // 检查是否与其他表达式重叠
      bool isPartOfOther = replacements.any((r) =>
      (match.start >= r['start'] && match.end <= r['end']) ||
          (r['start'] >= match.start && r['end'] <= match.end));

      if (!isPartOfOther) {
        String multiplier = match.group(1)!;
        String numerator = match.group(2)!;
        String denominator = match.group(3)!;

        replacements.add({
          'start': match.start,
          'end': match.end,
          'type': 'complex_fraction',
          'multiplier': multiplier,
          'numerator': numerator,
          'denominator': denominator,
          'original': match.group(0)!,
        });
      }
    }

    // 5. 最后找普通分数
    Iterable<RegExpMatch> fractionMatches = fractionRegex.allMatches(expression);
    for (RegExpMatch match in fractionMatches) {
      bool isPartOfOther = replacements.any((r) =>
      (match.start >= r['start'] && match.end <= r['end']) ||
          (r['start'] >= match.start && r['end'] <= match.end));

      if (!isPartOfOther) {
        replacements.add({
          'start': match.start,
          'end': match.end,
          'type': 'fraction',
          'numerator': match.group(1)!,
          'denominator': match.group(2)!,
          'original': match.group(0)!,
        });
      }
    }

    // 按位置排序，并移除重叠项
    replacements.sort((a, b) => a['start'].compareTo(b['start']));

    // 移除重叠的替换项
    List<Map<String, dynamic>> cleanReplacements = [];
    for (int i = 0; i < replacements.length; i++) {
      bool isOverlapping = false;
      for (int j = 0; j < cleanReplacements.length; j++) {
        if (replacements[i]['start'] < cleanReplacements[j]['end'] &&
            replacements[i]['end'] > cleanReplacements[j]['start']) {
          isOverlapping = true;
          break;
        }
      }
      if (!isOverlapping) {
        cleanReplacements.add(replacements[i]);
      }
    }

    // 构建widgets
    int lastEnd = 0;
    for (Map<String, dynamic> replacement in cleanReplacements) {
      // 添加前面的普通文本
      if (replacement['start'] > lastEnd) {
        String beforeText = expression.substring(lastEnd, replacement['start']);
        if (beforeText.isNotEmpty) {
          widgets.addAll(_parseSimpleText(beforeText, defaultStyle));
        }
      }

      // 添加对应的widget
      switch (replacement['type']) {
        case 'handwritten_fraction':
        // 渲染手写分数格式
          widgets.add(_buildHandwrittenExpressionFraction(
              replacement['numeratorExpr'], replacement['denominatorExpr']));
          break;
        case 'division_with_fraction':
          widgets.add(Text(replacement['dividend'], style: defaultStyle));
          widgets.add(const SizedBox(width: 4));
          widgets.add(Text('÷', style: defaultStyle));
          widgets.add(const SizedBox(width: 4));
          widgets.add(_buildHandwrittenFraction(
              '${replacement['fractionNumerator']}/${replacement['fractionDenominator']}'));
          break;
        case 'complex_fraction':
          widgets.add(Text(replacement['multiplier'], style: defaultStyle));
          widgets.add(const SizedBox(width: 2));
          widgets.add(Text('×', style: defaultStyle));
          widgets.add(const SizedBox(width: 2));
          widgets.add(_buildHandwrittenFraction(
              '${replacement['numerator']}/${replacement['denominator']}'));
          break;
        case 'mixed':
          widgets.add(_buildMixedNumber(replacement['integer'],
              '${replacement['numerator']}/${replacement['denominator']}'));
          break;
        case 'fraction':
          widgets.add(_buildHandwrittenFraction(
              '${replacement['numerator']}/${replacement['denominator']}'));
          break;
      }

      lastEnd = replacement['end'];
    }

    // 添加剩余的文本
    if (lastEnd < expression.length) {
      String remainingText = expression.substring(lastEnd);
      if (remainingText.isNotEmpty) {
        widgets.addAll(_parseSimpleText(remainingText, defaultStyle));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      children: widgets,
    );
  }

  // 构建手写表达式分数格式 - 用于通分中间步骤
  Widget _buildHandwrittenExpressionFraction(String numeratorExpr, String denominatorExpr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分子表达式
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              numeratorExpr,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // 分数线
          Container(
            width: math.max(
              numeratorExpr.length * 7.0,
              denominatorExpr.length * 7.0,
            ) + 8,
            height: 1.5,
            color: Colors.black87,
          ),
          // 分母表达式
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              denominatorExpr,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 解析简单文本（非分数部分）
  List<Widget> _parseSimpleText(String text, TextStyle style) {
    List<Widget> widgets = [];
    List<String> parts = text.split(' ');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        widgets.add(Text(parts[i], style: style));
        if (i < parts.length - 1) {
          widgets.add(const SizedBox(width: 6));
        }
      }
    }

    return widgets;
  }

  // 构建手写格式的分数 - 支持负数
  Widget _buildHandwrittenFraction(String fraction) {
    if (!fraction.contains('/')) {
      return Text(
        fraction,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    List<String> parts = fraction.split('/');
    if (parts.length != 2) return Text(fraction);

    String numerator = parts[0].trim();
    String denominator = parts[1].trim();

    // 处理负数显示
    bool isNegative = numerator.startsWith('-');
    if (isNegative) {
      numerator = numerator.substring(1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 负号单独显示
          if (isNegative) ...[
            const Text(
              '-',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 1),
          ],
          // 分数部分
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                numerator,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: math.max(
                  numerator.length * 8.0,
                  denominator.length * 8.0,
                ) + 4,
                height: 1.5,
                color: Colors.black87,
              ),
              Text(
                denominator,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建带分数格式 - 支持负数
  Widget _buildMixedNumber(String integer, String fraction) {
    bool isNegative = integer.startsWith('-');
    String displayInteger = isNegative ? integer.substring(1) : integer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 负号单独显示
          if (isNegative) ...[
            const Text(
              '-',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 1),
          ],
          // 整数部分
          Text(
            displayInteger,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          // 分数部分
          _buildHandwrittenFraction(fraction),
        ],
      ),
    );
  }

  // 翻译运算名称
  String _translateOperation(String operation) {
    try {
      switch (operation) {
        case '加法': return 'fraction_add'.tr();
        case '减法': return 'fraction_subtract'.tr();
        case '乘法': return 'fraction_multiply'.tr();
        case '除法': return 'fraction_divide'.tr();
        case '约分': return 'fraction_simplify'.tr();
        case '通分': return 'fraction_common'.tr();
        case '转换': return 'fraction_convert'.tr();
        case '倒数': return 'fraction_reciprocal'.tr();
        case '平方': return 'fraction_square'.tr();
        case '立方': return 'fraction_cube'.tr();
        case '平方根': return 'fraction_sqrt'.tr();
        case '立方根': return 'fraction_cbrt'.tr();
        case 'n次方': return 'fraction_power'.tr();
        case 'n次根': return 'fraction_root'.tr();
        case '对数': return 'fraction_log'.tr();
        case '自然对数': return 'fraction_ln'.tr();
        case '幂运算': return 'exponentiation'.tr();
        case '根运算': return 'root_operation'.tr();
        default: return operation;
      }
    } catch (e) {
      return operation;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}