import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AnyAngleTrigCalculatorPage extends StatelessWidget {
  const AnyAngleTrigCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('any_angle_calculator'.tr()),
      ),
      body: const Center(
        child: Text(
          'Any angle trig calculator page (Coming soon)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
