import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CalculusCalculatorPage extends StatelessWidget {
  const CalculusCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('calculus_calculator'.tr()),
      ),
      body: const Center(
        child: Text(
          'Calculus calculator page (Coming soon)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
