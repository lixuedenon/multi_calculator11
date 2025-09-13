import 'package:flutter/material.dart';
import 'dart:math' as math;

class RightTriangleLayoutCalculator {
  static const double _minButtonSize = 35.0;
  static const double _maxButtonSize = 55.0;
  static const double _minInputRowHeight = 35.0;
  static const double _maxInputRowHeight = 55.0;
  static const double _minDisplayHeight = 150.0;
  static const double _maxDisplayHeight = 400.0;

  static LayoutResult calculateLayout(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final safeArea = mediaQuery.padding;

    // 1. 计算可用空间
    final availableHeight = screenSize.height -
        safeArea.top -
        safeArea.bottom -
        _getAppBarHeight(screenSize.height) -
        24.0; // 基础padding

    final availableWidth = screenSize.width - 24.0; // 左右padding

    // 2. 屏幕特征分析
    final screenInfo = _analyzeScreen(screenSize, availableHeight);

    // 3. 计算组件最小需求
    final minRequirements = _calculateMinRequirements(screenInfo);

    // 4. 检查空间充足性并分配
    if (availableHeight < minRequirements.totalMinHeight) {
      // 启用紧凑模式
      return _calculateCompactLayout(availableHeight, screenInfo);
    } else {
      // 正常模式，按优先级分配剩余空间
      return _calculateNormalLayout(availableHeight, screenInfo, minRequirements);
    }
  }

  static ScreenInfo _analyzeScreen(Size screenSize, double availableHeight) {
    final aspectRatio = screenSize.width / screenSize.height;
    final isNarrowScreen = aspectRatio < 0.5;
    final isShortScreen = availableHeight < 600;
    final isTallScreen = availableHeight > 800;

    return ScreenInfo(
      width: screenSize.width,
      height: screenSize.height,
      availableHeight: availableHeight,
      aspectRatio: aspectRatio,
      isNarrowScreen: isNarrowScreen,
      isShortScreen: isShortScreen,
      isTallScreen: isTallScreen,
    );
  }

  static MinRequirements _calculateMinRequirements(ScreenInfo screenInfo) {
    // 基础尺寸根据屏幕调整
    final basePadding = screenInfo.isShortScreen ? 4.0 : 8.0;
    final buttonSize = screenInfo.isShortScreen ? _minButtonSize :
    screenInfo.isTallScreen ? _maxButtonSize : 45.0;
    final inputRowHeight = screenInfo.isShortScreen ? _minInputRowHeight :
    screenInfo.isTallScreen ? _maxInputRowHeight : 45.0;

    // 键盘区：4行按钮 + 间距 + padding
    final keyboardHeight = (4 * buttonSize) + (3 * 8.0) + (2 * basePadding);

    // 输入区：3行输入 + 间距 + padding
    final inputHeight = (3 * inputRowHeight) + (2 * 12.0) + (2 * basePadding);

    // 显示区：至少要能显示基本三角形
    final displayHeight = math.max(_minDisplayHeight,
        screenInfo.availableHeight * 0.25);

    return MinRequirements(
      displayHeight: displayHeight,
      inputHeight: inputHeight,
      keyboardHeight: keyboardHeight,
      totalMinHeight: displayHeight + inputHeight + keyboardHeight + (2 * 8.0), // 组件间距
      buttonSize: buttonSize,
      inputRowHeight: inputRowHeight,
      basePadding: basePadding,
    );
  }

  static LayoutResult _calculateCompactLayout(double availableHeight, ScreenInfo screenInfo) {
    // 紧凑模式：优先保证功能，压缩尺寸
    final compactPadding = 3.0;
    final compactButtonSize = _minButtonSize;
    final compactInputHeight = _minInputRowHeight;

    // 重新计算最小需求
    final keyboardHeight = (4 * compactButtonSize) + (3 * 6.0) + (2 * compactPadding);
    final inputHeight = (3 * compactInputHeight) + (2 * 8.0) + (2 * compactPadding);
    final componentSpacing = 4.0;

    final usedHeight = keyboardHeight + inputHeight + (2 * componentSpacing);
    final displayHeight = math.max(_minDisplayHeight, availableHeight - usedHeight);

    return LayoutResult(
      displayHeight: displayHeight,
      inputHeight: inputHeight,
      keyboardHeight: keyboardHeight,
      buttonSize: compactButtonSize,
      inputRowHeight: compactInputHeight,
      basePadding: compactPadding,
      componentSpacing: componentSpacing,
      labelWidth: 25.0,
      labelSpacing: 2.0,
      fontSize: 14.0,
      isCompactMode: true,
    );
  }

  static LayoutResult _calculateNormalLayout(double availableHeight,
      ScreenInfo screenInfo,
      MinRequirements minReq) {
    final componentSpacing = screenInfo.isShortScreen ? 6.0 : 8.0;
    final totalSpacing = 2 * componentSpacing;

    // 减去组件间距后的可用高度
    final heightForComponents = availableHeight - totalSpacing;

    // 如果空间刚好够最小需求，就用最小值
    if (heightForComponents <= minReq.totalMinHeight - totalSpacing) {
      return LayoutResult(
        displayHeight: minReq.displayHeight,
        inputHeight: minReq.inputHeight,
        keyboardHeight: minReq.keyboardHeight,
        buttonSize: minReq.buttonSize,
        inputRowHeight: minReq.inputRowHeight,
        basePadding: minReq.basePadding,
        componentSpacing: componentSpacing,
        labelWidth: screenInfo.isShortScreen ? 30.0 : 40.0,
        labelSpacing: screenInfo.isShortScreen ? 3.0 : 5.0,
        fontSize: screenInfo.isShortScreen ? 15.0 : 17.0,
        isCompactMode: false,
      );
    }

    // 有额外空间，按优先级分配
    final extraHeight = heightForComponents - (minReq.totalMinHeight - totalSpacing);

    // 分配策略：显示区优先级最高，然后是输入区，最后是键盘区
    final displayExtra = math.min(extraHeight * 0.5, _maxDisplayHeight - minReq.displayHeight);
    final inputExtra = math.min((extraHeight - displayExtra) * 0.6,
        minReq.inputHeight * 0.3);
    final keyboardExtra = extraHeight - displayExtra - inputExtra;

    final finalDisplayHeight = minReq.displayHeight + displayExtra;
    final finalInputHeight = minReq.inputHeight + inputExtra;
    final finalKeyboardHeight = minReq.keyboardHeight + keyboardExtra;

    // 根据最终分配调整组件尺寸
    final adjustedButtonSize = math.min(_maxButtonSize,
        minReq.buttonSize + (keyboardExtra / 8));
    final adjustedInputRowHeight = math.min(_maxInputRowHeight,
        minReq.inputRowHeight + (inputExtra / 6));

    return LayoutResult(
      displayHeight: finalDisplayHeight,
      inputHeight: finalInputHeight,
      keyboardHeight: finalKeyboardHeight,
      buttonSize: adjustedButtonSize,
      inputRowHeight: adjustedInputRowHeight,
      basePadding: minReq.basePadding,
      componentSpacing: componentSpacing,
      labelWidth: screenInfo.isShortScreen ? 35.0 : screenInfo.isTallScreen ? 45.0 : 40.0,
      labelSpacing: screenInfo.isShortScreen ? 4.0 : 6.0,
      fontSize: screenInfo.isShortScreen ? 16.0 : screenInfo.isTallScreen ? 18.0 : 17.0,
      isCompactMode: false,
    );
  }

  static double _getAppBarHeight(double screenHeight) {
    if (screenHeight < 700) return 50.0;
    if (screenHeight < 900) return 56.0;
    return 64.0;
  }
}

class ScreenInfo {
  final double width;
  final double height;
  final double availableHeight;
  final double aspectRatio;
  final bool isNarrowScreen;
  final bool isShortScreen;
  final bool isTallScreen;

  ScreenInfo({
    required this.width,
    required this.height,
    required this.availableHeight,
    required this.aspectRatio,
    required this.isNarrowScreen,
    required this.isShortScreen,
    required this.isTallScreen,
  });
}

class MinRequirements {
  final double displayHeight;
  final double inputHeight;
  final double keyboardHeight;
  final double totalMinHeight;
  final double buttonSize;
  final double inputRowHeight;
  final double basePadding;

  MinRequirements({
    required this.displayHeight,
    required this.inputHeight,
    required this.keyboardHeight,
    required this.totalMinHeight,
    required this.buttonSize,
    required this.inputRowHeight,
    required this.basePadding,
  });
}

class LayoutResult {
  final double displayHeight;
  final double inputHeight;
  final double keyboardHeight;
  final double buttonSize;
  final double inputRowHeight;
  final double basePadding;
  final double componentSpacing;
  final double labelWidth;
  final double labelSpacing;
  final double fontSize;
  final bool isCompactMode;

  LayoutResult({
    required this.displayHeight,
    required this.inputHeight,
    required this.keyboardHeight,
    required this.buttonSize,
    required this.inputRowHeight,
    required this.basePadding,
    required this.componentSpacing,
    required this.labelWidth,
    required this.labelSpacing,
    required this.fontSize,
    required this.isCompactMode,
  });
}