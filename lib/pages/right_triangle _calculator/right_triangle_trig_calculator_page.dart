import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RightTriangleTrigCalculatorPage extends StatelessWidget {
  const RightTriangleTrigCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('right_triangle_calculator'.tr()),
      ),
      body: const Center(
        child: Text(
          'Right triangle trig calculator page (Coming soon)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
