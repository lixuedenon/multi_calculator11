import 'package:flutter/material.dart';

class FractionDisplay extends StatelessWidget {
  final int? integerPart;
  final int? numerator;
  final int? denominator;

  const FractionDisplay({
    Key? key,
    this.integerPart,
    this.numerator,
    this.denominator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果没有任何输入，显示为空
    if ((integerPart == null || integerPart == 0) &&
        (numerator == null || numerator == 0) &&
        (denominator == null || denominator == 1)) {
      return const SizedBox.shrink(); // 不显示任何内容
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 整数部分
        if (integerPart != null && integerPart != 0)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              integerPart.toString(),
              style: const TextStyle(fontSize: 36),
            ),
          ),
        // 分数部分
        if ((numerator != null && numerator != 0) ||
            (denominator != null && denominator != 1))
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                numerator?.toString() ?? '',
                style: const TextStyle(fontSize: 24),
              ),
              Container(
                width: 40,
                height: 2,
                color: Colors.black,
              ),
              Text(
                denominator?.toString() ?? '',
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
      ],
    );
  }
}
