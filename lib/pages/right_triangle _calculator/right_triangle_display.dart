import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../utils/right_triangle_calculator/right_triangle_calculator.dart';
import 'package:easy_localization/easy_localization.dart';

class RightTriangleDisplay extends StatefulWidget {
  final TriangleResult? result;
  final Map<String, String> inputValues;
  final String? activeInput;

  const RightTriangleDisplay({
    Key? key,
    this.result,
    required this.inputValues,
    this.activeInput,
  }) : super(key: key);

  @override
  State<RightTriangleDisplay> createState() => _RightTriangleDisplayState();
}

class _RightTriangleDisplayState extends State<RightTriangleDisplay> {
  Offset _panOffset = Offset.zero;
  double _scaleFactor = 1.0;

  String getValueDisplay(String key, double? value) {
    if (value != null) {
      return RightTriangleCalculator.formatNumber(value);
    }
    return widget.inputValues[key]?.isNotEmpty == true ? widget.inputValues[key]! : '?';
  }

  void _zoomIn() {
    setState(() {
      _scaleFactor = (_scaleFactor * 1.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _scaleFactor = (_scaleFactor * 0.8).clamp(0.5, 3.0);
    });
  }

  void _resetView() {
    setState(() {
      _scaleFactor = 1.0;
      _panOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部控制栏：缩放按钮（左侧）+ 操作提示（中间）
          Row(
            children: [
              // 左侧：缩放控制按钮
              IconButton(
                onPressed: _zoomOut,
                icon: const Icon(Icons.remove, color: Colors.white, size: 14),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(28, 28),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _resetView,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 14),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(28, 28),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: _zoomIn,
                icon: const Icon(Icons.add, color: Colors.white, size: 14),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(28, 28),
                ),
              ),

              const SizedBox(width: 20),

              // 中间：操作提示
              Expanded(
                child: Center(
                  child: Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(
                      '${'dragToMove'.tr()} · ${'doubleTapReset'.tr()}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // 三角形绘制区域
          Expanded(
            child: Container(
              width: double.infinity,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final newOffset = _panOffset + details.delta;
                    const boundary = 300.0;

                    _panOffset = Offset(
                      newOffset.dx.clamp(-boundary, boundary),
                      newOffset.dy.clamp(-boundary, boundary),
                    );
                  });
                },
                onDoubleTap: () {
                  setState(() {
                    _panOffset = Offset.zero;
                  });
                },
                child: CustomPaint(
                  painter: SimpleDraggableTrianglePainter(
                    result: widget.result,
                    inputValues: widget.inputValues,
                    getValueDisplay: getValueDisplay,
                    panOffset: _panOffset,
                    scaleFactor: _scaleFactor,
                  ),
                ),
              ),
            ),
          ),

          // 计算结果显示
          if (widget.result != null && widget.result!.area != null)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(
                      '${'areaShort'.tr()} = ${RightTriangleCalculator.formatNumber(widget.result!.area)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.result!.perimeter != null)
                    Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Text(
                        '${'perimeterShort'.tr()} = ${RightTriangleCalculator.formatNumber(widget.result!.perimeter)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
}

class SimpleDraggableTrianglePainter extends CustomPainter {
  final TriangleResult? result;
  final Map<String, String> inputValues;
  final String Function(String, double?) getValueDisplay;
  final Offset panOffset;
  final double scaleFactor;

  SimpleDraggableTrianglePainter({
    required this.result,
    required this.inputValues,
    required this.getValueDisplay,
    required this.panOffset,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 网格背景
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), gridPaint);
    }
    for (int i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), gridPaint);
    }

    // 计算三角形尺寸
    double displayA = 100 * scaleFactor;
    double displayB = 130 * scaleFactor;

    if (result != null && result!.a != null && result!.b != null && result!.c != null) {
      final maxSide = math.max(math.max(result!.a!, result!.b!), result!.c!);
      const fixedMaxDisplay = 150.0;
      final baseScale = fixedMaxDisplay / maxSide;

      displayA = result!.a! * baseScale * scaleFactor;
      displayB = result!.b! * baseScale * scaleFactor;
    }

    // 三角形顶点
    final centerX = size.width / 2 + panOffset.dx;
    final centerY = size.height / 2 + panOffset.dy;

    final pointA = Offset(centerX - displayB / 2, centerY + displayA / 2);
    final pointB = Offset(centerX + displayB / 2, centerY + displayA / 2);
    final pointC = Offset(centerX - displayB / 2, centerY - displayA / 2);

    // 绘制三角形
    final path = Path();
    path.moveTo(pointA.dx, pointA.dy);
    path.lineTo(pointB.dx, pointB.dy);
    path.lineTo(pointC.dx, pointC.dy);
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // 绘制直角标记
    const rightAngleSize = 6.0;
    final rightAnglePath = Path();
    rightAnglePath.moveTo(pointA.dx, pointA.dy - rightAngleSize);
    rightAnglePath.lineTo(pointA.dx + rightAngleSize, pointA.dy - rightAngleSize);
    rightAnglePath.lineTo(pointA.dx + rightAngleSize, pointA.dy);
    canvas.drawPath(rightAnglePath, paint);

    final degreeSymbol = 'degrees'.tr();

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    const angleStyle = TextStyle(
      color: Colors.amber,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    // 边长标注
    _drawText(canvas, 'b = ${getValueDisplay('b', result?.b)}',
        Offset((pointA.dx + pointB.dx) / 2, pointA.dy - 12), textStyle);
    _drawText(canvas, 'a = ${getValueDisplay('a', result?.a)}',
        Offset(pointA.dx - 40, (pointA.dy + pointC.dy) / 2), textStyle);
    _drawText(canvas, 'c = ${getValueDisplay('c', result?.c)}',
        Offset((pointB.dx + pointC.dx) / 2 + 35, (pointB.dy + pointC.dy) / 2), textStyle);

    // 角度标注
    _drawText(canvas, 'B = ${getValueDisplay('angleB', result?.angleB)}${result?.angleB != null ? degreeSymbol : ''}',
        Offset(pointC.dx + 25, pointC.dy - 20), angleStyle);
    _drawText(canvas, 'A = ${getValueDisplay('angleA', result?.angleA)}${result?.angleA != null ? degreeSymbol : ''}',
        Offset(pointB.dx - 5, pointB.dy - 20), angleStyle);
    _drawText(canvas, '90$degreeSymbol',
        Offset(pointA.dx - 20, pointA.dy - 8), angleStyle);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! SimpleDraggableTrianglePainter) return true;
    return oldDelegate.result != result ||
        oldDelegate.inputValues != inputValues ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}