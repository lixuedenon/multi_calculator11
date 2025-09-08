import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import '../pages/fraction_calculator_page.dart';
import '../pages/right_triangle_main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Map<String, Locale> supportedLocales = {
    '中文': const Locale('zh', 'CN'),
    'English': const Locale('en', 'US'),
    '日本語': const Locale('ja', 'JP'),
    '한국어': const Locale('ko', 'KR'),
    'Français': const Locale('fr', 'FR'),
    'Deutsch': const Locale('de', 'DE'),
    'Español': const Locale('es', 'ES'),
    'العربية': const Locale('ar', 'SA'),
  };

  String get currentLanguageKey {
    return supportedLocales.entries
        .firstWhere((entry) => entry.value == context.locale,
        orElse: () => supportedLocales.entries.first)
        .key;
  }

  void navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  List<_CalculatorModule> get modules => [
    _CalculatorModule(
      keyName: 'fraction_calculator',
      icon: Icons.calculate,
      page: const FractionCalculatorPage(),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'calculus_calculator',
      icon: Icons.functions,
      page: const _SimpleTestPage(),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'right_triangle_calculator',
      icon: Icons.architecture,
      page: const RightTriangleMain(),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'any_angle_triangle_calculator',
      icon: Icons.change_history,
      page: _ComingSoonPage('any_angle_triangle_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'stairs_calculator',
      icon: Icons.stairs,
      page: _ComingSoonPage('stairs_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'tax_optimization_calculator',
      icon: Icons.percent,
      page: _ComingSoonPage('tax_optimization_calculator'.tr()),
      isAvailable: false,
    ),
    _CalculatorModule(
      keyName: 'mortgage_calculator',
      icon: Icons.home,
      page: _ComingSoonPage('mortgage_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'unit_converter',
      icon: Icons.compare_arrows,
      page: _ComingSoonPage('unit_converter'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'compound_interest_calculator',
      icon: Icons.trending_up,
      page: _ComingSoonPage('compound_interest_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'date_time_calculator',
      icon: Icons.schedule,
      page: _ComingSoonPage('date_time_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'polynomial_factorization',
      icon: Icons.auto_awesome,
      page: _ComingSoonPage('polynomial_factorization'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'balance_calculator',
      icon: Icons.balance,
      page: _ComingSoonPage('balance_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'matrix_calculator',
      icon: Icons.grid_3x3,
      page: _ComingSoonPage('matrix_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'travel_calculator',
      icon: Icons.flight,
      page: _ComingSoonPage('travel_calculator'.tr()),
      isAvailable: true,
    ),
    _CalculatorModule(
      keyName: 'social_security_calculator',
      icon: Icons.security,
      page: _ComingSoonPage('social_security_calculator'.tr()),
      isAvailable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2a2a2a), Color(0xFF1a1a1a), Color(0xFF0a0a0a)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildCalculatorGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'app_title'.tr(),
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          _buildLanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.public, color: Color(0xFF00FF88), size: 20),
      color: const Color(0xFF1a1a1a),
      onSelected: (String newKey) {
        context.setLocale(supportedLocales[newKey]!);
        setState(() {});
      },
      itemBuilder: (BuildContext context) {
        return supportedLocales.keys.map((String keyItem) {
          return PopupMenuItem<String>(
            value: keyItem,
            child: Container(
              width: 120,
              child: Text(
                keyItem,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildCalculatorGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return _buildCalculatorCard(module);
        },
      ),
    );
  }

  Widget _buildCalculatorCard(_CalculatorModule module) {
    return GestureDetector(
      onTap: module.isAvailable ? () => navigateTo(module.page) : null,
      child: Container(
        decoration: BoxDecoration(
          color: module.isAvailable ? const Color(0xFF2a2a2a) : const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: module.isAvailable ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: module.isAvailable ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              module.icon,
              size: 32,
              color: module.isAvailable ? const Color(0xFF00FF88) : Colors.grey.shade600,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    module.keyName.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: module.isAvailable ? Colors.white : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getChineseSubtitle(module.keyName),
                    style: TextStyle(
                      fontSize: 9,
                      color: module.isAvailable ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChineseSubtitle(String keyName) {
    switch (keyName) {
      case 'fraction_calculator': return '分数计算器';
      case 'calculus_calculator': return '微积分计算器';
      case 'right_triangle_calculator': return '直角三角形计算器';
      case 'any_angle_triangle_calculator': return '任意三角形计算器';
      case 'stairs_calculator': return '楼梯计算器';
      case 'tax_optimization_calculator': return '税务优化计算器';
      case 'mortgage_calculator': return '房贷计算器';
      case 'unit_converter': return '单位转换器';
      case 'compound_interest_calculator': return '复利计算器';
      case 'date_time_calculator': return '日期时间计算器';
      case 'polynomial_factorization': return '多项式因式分解';
      case 'balance_calculator': return '天平计算器';
      case 'matrix_calculator': return '矩阵计算器';
      case 'travel_calculator': return '旅行计算器';
      case 'social_security_calculator': return '社会保障计算器';
      default: return '';
    }
  }
}

class _CalculatorModule {
  final String keyName;
  final IconData icon;
  final Widget page;
  final bool isAvailable;

  _CalculatorModule({
    required this.keyName,
    required this.icon,
    required this.page,
    required this.isAvailable,
  });
}

class _ComingSoonPage extends StatelessWidget {
  final String title;

  const _ComingSoonPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2a2a2a), Color(0xFF1a1a1a), Color(0xFF0a0a0a)],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 5),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF00FF88),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Icon(
                          Icons.construction,
                          color: const Color(0xFF00FF88),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'coming_soon'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleTestPage extends StatelessWidget {
  const _SimpleTestPage();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Color(0xFF00FF88), size: 20),
          ),
          title: const Text('RTL测试', style: TextStyle(color: Color(0xFFFF6B35), fontSize: 18)),
          backgroundColor: Colors.grey[900],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('左按钮', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('右按钮', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 24))),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}