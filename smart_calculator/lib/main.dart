import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'locker_screen.dart';
import 'package:flutter/services.dart';

// ═══════ COLORS ═══════
const kBg = Color(0xFF000000);
const kCard = Color(0xFF1A1A1A);
const kCard2 = Color(0xFF262626);
const kRed = Color(0xFFE63946);
const kRedDark = Color(0xFF8B0000);
const kGrey = Color(0xFF2A2A2A);
const kTextWhite = Color(0xFFFFFFFF);
const kTextGrey = Color(0xFF9B9B9B);

void main() {
  runApp(const SmartCalculatorApp());
}

class SmartCalculatorApp extends StatelessWidget {
  const SmartCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        primaryColor: kRed,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kTextWhite,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  final _screens = const [
    BasicCalculator(),
    FinanceScreen(),
    ToolsScreen(),
    CurrencyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _screens[_i],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kRed.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: kRed.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            backgroundColor: kCard,
            indicatorColor: kRed.withValues(alpha: 0.25),
            selectedIndex: _i,
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (v) => setState(() => _i = v),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined, color: kTextGrey),
                selectedIcon: Icon(Icons.calculate, color: kRed),
                label: 'Calc',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined, color: kTextGrey),
                selectedIcon: Icon(Icons.bar_chart, color: kRed),
                label: 'Finance',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined, color: kTextGrey),
                selectedIcon: Icon(Icons.grid_view, color: kRed),
                label: 'Tools',
              ),
              NavigationDestination(
                icon: Icon(Icons.currency_exchange_outlined, color: kTextGrey),
                selectedIcon: Icon(Icons.currency_exchange, color: kRed),
                label: 'Currency',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════ BASIC CALCULATOR ═══════
class BasicCalculator extends StatefulWidget {
  const BasicCalculator({super.key});
  @override
  State<BasicCalculator> createState() => _BasicCalculatorState();
}

class _BasicCalculatorState extends State<BasicCalculator> {
  String _display = '0';
  String _preview = '';

  static const Color softRed = Color(0xFFE63946);
  static const Color darkGrey = Color(0xFF2A2A2A);

  void _onKey(String v) {
    setState(() {
      if (v == 'C') {
        _display = '0';
        _preview = '';
      } else if (v == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
        _updatePreview();
      } else if (v == '=') {
        _handleEquals();
      } else {
        if (_display == '0' && '0123456789.'.contains(v)) {
          _display = v;
        } else {
          _display += v;
        }
        _updatePreview();
      }
    });
  }

  void _updatePreview() {
    final cleaned = _cleanExpression(_display);
    if (cleaned.isEmpty) {
      _preview = '';
      return;
    }

    if (!cleaned.contains(RegExp(r'[+\-×÷%]'))) {
      _preview = '';
      return;
    }

    if (_display.isNotEmpty &&
        '+-×÷%'.contains(_display[_display.length - 1])) {
      if (_display.length > 1 &&
          '+-×÷%'.contains(_display[_display.length - 2])) {
        _preview = '';
        return;
      }
      final temp = _display.substring(0, _display.length - 1);
      try {
        final result = _eval(temp);
        _preview = '= ${_formatResult(result)}';
      } catch (e) {
        _preview = '';
      }
      return;
    }

    try {
      final result = _eval(_display);
      _preview = '= ${_formatResult(result)}';
    } catch (e) {
      _preview = '';
    }
  }

  void _handleEquals() {
    String expr = _display;
    while (expr.isNotEmpty && '+-×÷'.contains(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }

    if (expr.isEmpty) {
      _display = '0';
      _preview = '';
      return;
    }

    try {
      final result = _eval(expr);
      _display = _formatResult(result);
      _preview = '';
    } catch (e) {
      _display = 'Error';
      _preview = '';
    }
  }

  String _cleanExpression(String expr) {
    if (expr.isEmpty) return expr;
    String cleaned = expr;
    while (cleaned.isNotEmpty && '+-×÷'.contains(cleaned[cleaned.length - 1])) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }

  String _formatResult(double r) {
    if (r.isNaN || r.isInfinite) return 'Error';
    if (r.truncateToDouble() == r) {
      return r.toInt().toString();
    }
    return r
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  double _eval(String s) {
    s = _handlePercentage(s);
    s = s.replaceAll('×', '*').replaceAll('÷', '/');
    if (s.isEmpty) throw Exception('Empty');
    return _parse(s);
  }

  String _handlePercentage(String expr) {
    if (!expr.contains('%')) return expr;

    final percentPattern =
        RegExp(r'(\d+\.?\d*)\s*([+\-×÷])\s*(\d+\.?\d*)%');

    while (percentPattern.hasMatch(expr)) {
      expr = expr.replaceFirstMapped(percentPattern, (m) {
        final base = m.group(1)!;
        final op = m.group(2)!;
        final pct = m.group(3)!;
        if (op == '+' || op == '-') {
          return '$base$op($base*$pct/100)';
        } else {
          return '$base$op($pct/100)';
        }
      });
    }

    final soloPercent = RegExp(r'(\d+\.?\d*)%');
    expr = expr.replaceAllMapped(soloPercent, (m) {
      return '(${m.group(1)}/100)';
    });

    return expr;
  }

  double _parse(String s) {
    while (s.contains('(')) {
      final start = s.lastIndexOf('(');
      final end = s.indexOf(')', start);
      if (end == -1) break;
      final inner = s.substring(start + 1, end);
      final innerResult = _parse(inner);
      s = s.substring(0, start) +
          innerResult.toString() +
          s.substring(end + 1);
    }

    for (int i = s.length - 1; i > 0; i--) {
      if ((s[i] == '+' || s[i] == '-') && !'*/'.contains(s[i - 1])) {
        final left = _parse(s.substring(0, i));
        final right = _parse(s.substring(i + 1));
        return s[i] == '+' ? left + right : left - right;
      }
    }
    for (int i = s.length - 1; i > 0; i--) {
      if (s[i] == '*' || s[i] == '/') {
        final left = _parse(s.substring(0, i));
        final right = _parse(s.substring(i + 1));
        return s[i] == '*' ? left * right : left / right;
      }
    }
    return double.parse(s);
  }

  Widget _btn(String label, {Color? bg, Color? fg}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Material(
            color: bg ?? darkGrey,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
             onTap: () {
  SystemSound.play(SystemSoundType.click);
  _onKey(label);
},
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: fg ?? kTextWhite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Text('Calculator',
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kTextWhite)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: darkGrey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: softRed.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.history, color: softRed, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_preview.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        _preview,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _display,
                      style: GoogleFonts.poppins(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: kTextWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(children: [
                    _btn('C', bg: softRed, fg: kTextWhite),
                    _btn('⌫', bg: darkGrey, fg: softRed),
                    _btn('%', bg: darkGrey, fg: kTextWhite),
                    _btn('÷', bg: darkGrey, fg: softRed),
                  ]),
                  Row(children: [
                    _btn('7'),
                    _btn('8'),
                    _btn('9'),
                    _btn('×', bg: darkGrey, fg: softRed),
                  ]),
                  Row(children: [
                    _btn('4'),
                    _btn('5'),
                    _btn('6'),
                    _btn('-', bg: darkGrey, fg: softRed),
                  ]),
                  Row(children: [
                    _btn('1'),
                    _btn('2'),
                    _btn('3'),
                    _btn('+', bg: darkGrey, fg: softRed),
                  ]),
                  Row(children: [
                    _btn('0'),
                    _btn('.'),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: AspectRatio(
                          aspectRatio: 2.05,
                          child: Material(
                            color: softRed,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
  SystemSound.play(SystemSoundType.click);
  _onKey('=');
},
                              child: Center(
                                child: Text(
                                  '=',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: kTextWhite,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════ FINANCE ═══════
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'t': 'EMI Calculator', 's': 'Loan EMI', 'i': Icons.home_work, 'c': kRed, 'screen': const EmiCalculator()},
      {'t': 'SIP Calculator', 's': 'Mutual Fund', 'i': Icons.trending_up, 'c': const Color(0xFF00D09C), 'screen': const SipCalculator()},
      {'t': 'FD Calculator', 's': 'Fixed Deposit', 'i': Icons.savings, 'c': const Color(0xFFFFA500), 'screen': const FdCalculator()},
      {'t': 'GST Calculator', 's': 'Tax Calculator', 'i': Icons.receipt_long, 'c': const Color(0xFF8B5CF6), 'screen': const GstCalculator()},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Finance',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kTextWhite)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kRed.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.notifications_none,
                      color: kRed, size: 22),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LockerScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kRed.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: kRed, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Everything you need to plan finances',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kRed, kRedDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Portfolio',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: kTextWhite.withValues(alpha: 0.9))),
                  const SizedBox(height: 6),
                  Text('₹ 12,45,600',
                      style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: kTextWhite)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward,
                          color: kTextWhite, size: 16),
                      const SizedBox(width: 4),
                      Text('+12.5% this month',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: kTextWhite)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Calculators',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextWhite)),
            const SizedBox(height: 12),
            ...items.map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _modernCard(
                    title: it['t'] as String,
                    subtitle: it['s'] as String,
                    icon: it['i'] as IconData,
                    color: it['c'] as Color,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => it['screen'] as Widget),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _modernCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: kTextWhite)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: kTextGrey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: kTextGrey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════ TOOLS ═══════
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'t': 'BMI', 'i': Icons.favorite, 'c': kRed, 's': const BmiCalculator()},
      {'t': 'Age', 'i': Icons.cake, 'c': const Color(0xFFFF6B9D), 's': const AgeCalculator()},
      {'t': 'Date', 'i': Icons.calendar_month, 'c': const Color(0xFF3B82F6), 's': const DateCalculator()},
      {'t': 'Unit', 'i': Icons.swap_horiz, 'c': const Color(0xFF00D09C), 's': const UnitConverter()},
      {'t': 'Tax', 'i': Icons.receipt, 'c': const Color(0xFF8B5CF6), 's': const GstCalculator()},
      {'t': 'Currency', 'i': Icons.currency_exchange, 'c': const Color(0xFFFFA500), 's': const CurrencyScreen()},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tools',
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kTextWhite)),
            const SizedBox(height: 6),
            Text('Finance & Tools',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                final it = items[i];
                return _gridCard(
                  label: it['t'] as String,
                  icon: it['i'] as IconData,
                  color: it['c'] as Color,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => it['s'] as Widget),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kRed.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb, color: kRed, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Tip',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kTextWhite)),
                        const SizedBox(height: 4),
                        Text('Use SIP to build wealth over time with compounding.',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: kTextGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextWhite)),
          ],
        ),
      ),
    );
  }
}

// ═══════ CURRENCY ═══════
class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});
  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amount = TextEditingController(text: '1');
  String _from = 'USD';
  String _to = 'INR';
  double _rate = 0;
  double _result = 0;
  bool _loading = true;
  String _error = '';
  String _source = '';
  DateTime? _lastUpdated;

  final Map<String, Map<String, String>> _currencies = {
    'USD': {'name': 'US Dollar', 'flag': '🇺🇸'},
    'INR': {'name': 'Indian Rupee', 'flag': '🇮🇳'},
    'EUR': {'name': 'Euro', 'flag': '🇪🇺'},
    'GBP': {'name': 'British Pound', 'flag': '🇬🇧'},
    'JPY': {'name': 'Japanese Yen', 'flag': '🇯🇵'},
    'AUD': {'name': 'Australian Dollar', 'flag': '🇦🇺'},
    'CAD': {'name': 'Canadian Dollar', 'flag': '🇨🇦'},
    'CHF': {'name': 'Swiss Franc', 'flag': '🇨🇭'},
    'CNY': {'name': 'Chinese Yuan', 'flag': '🇨🇳'},
    'AED': {'name': 'UAE Dirham', 'flag': '🇦🇪'},
    'SAR': {'name': 'Saudi Riyal', 'flag': '🇸🇦'},
    'SGD': {'name': 'Singapore Dollar', 'flag': '🇸🇬'},
    'HKD': {'name': 'Hong Kong Dollar', 'flag': '🇭🇰'},
    'NZD': {'name': 'New Zealand Dollar', 'flag': '🇳🇿'},
    'KRW': {'name': 'South Korean Won', 'flag': '🇰🇷'},
    'THB': {'name': 'Thai Baht', 'flag': '🇹🇭'},
    'MYR': {'name': 'Malaysian Ringgit', 'flag': '🇲🇾'},
    'IDR': {'name': 'Indonesian Rupiah', 'flag': '🇮🇩'},
    'PHP': {'name': 'Philippine Peso', 'flag': '🇵🇭'},
    'PKR': {'name': 'Pakistani Rupee', 'flag': '🇵🇰'},
    'BDT': {'name': 'Bangladeshi Taka', 'flag': '🇧🇩'},
    'LKR': {'name': 'Sri Lankan Rupee', 'flag': '🇱🇰'},
    'NPR': {'name': 'Nepalese Rupee', 'flag': '🇳🇵'},
    'ZAR': {'name': 'South African Rand', 'flag': '🇿🇦'},
    'BRL': {'name': 'Brazilian Real', 'flag': '🇧🇷'},
    'MXN': {'name': 'Mexican Peso', 'flag': '🇲🇽'},
    'RUB': {'name': 'Russian Ruble', 'flag': '🇷🇺'},
    'TRY': {'name': 'Turkish Lira', 'flag': '🇹🇷'},
    'SEK': {'name': 'Swedish Krona', 'flag': '🇸🇪'},
    'NOK': {'name': 'Norwegian Krone', 'flag': '🇳🇴'},
  };

  @override
  void initState() {
    super.initState();
    _fetchRate();
  }

  Future<void> _fetchRate() async {
    setState(() {
      _loading = true;
      _error = '';
      _source = '';
    });

    if (_from == _to) {
      setState(() {
        _rate = 1;
        _result = double.tryParse(_amount.text) ?? 0;
        _loading = false;
        _source = 'Same currency';
        _lastUpdated = DateTime.now();
      });
      return;
    }

    // LAYER 1: Cache
    final cached = await _getCachedRate(_from, _to);
    if (cached != null) {
      setState(() {
        _rate = cached['rate']!;
        _result = (double.tryParse(_amount.text) ?? 0) * cached['rate']!;
        _loading = false;
        _source = 'Cached (${_formatDate(cached['date']!)})';
        _lastUpdated = cached['date'];
      });
      return;
    }

    // LAYER 2: Frankfurter API
    final apiRate = await _fetchFrankfurter();
    if (apiRate > 0) {
      final now = DateTime.now();
      await _saveCachedRate(_from, _to, apiRate, now);
      setState(() {
        _rate = apiRate;
        _result = (double.tryParse(_amount.text) ?? 0) * apiRate;
        _loading = false;
        _source = 'Live (ECB)';
        _lastUpdated = now;
      });
      return;
    }

    // LAYER 3: Local fallback
    final fallbackRate = _getFallbackRate(_from, _to);
    if (fallbackRate > 0) {
      setState(() {
        _rate = fallbackRate;
        _result = (double.tryParse(_amount.text) ?? 0) * fallbackRate;
        _loading = false;
        _source = 'Offline (Approx.)';
        _error = 'Internet issue — approximate rate shown';
      });
    } else {
      setState(() {
        _loading = false;
        _error = 'Unable to fetch rate. Check internet.';
      });
    }
  }

  String _cacheKey(String from, String to) {
    final today = DateTime.now();
    return 'rate_${from}_${to}_${today.year}_${today.month}_${today.day}';
  }

  Future<Map<String, dynamic>?> _getCachedRate(
      String from, String to) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _cacheKey(from, to);
      final todayRate = prefs.getDouble(todayKey);
      final todayTimestamp = prefs.getInt('${todayKey}_ts');

      if (todayRate != null && todayTimestamp != null) {
        return {
          'rate': todayRate,
          'date': DateTime.fromMillisecondsSinceEpoch(todayTimestamp),
        };
      }

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey =
          'rate_${from}_${to}_${yesterday.year}_${yesterday.month}_${yesterday.day}';
      final yesterdayRate = prefs.getDouble(yesterdayKey);
      final yesterdayTimestamp = prefs.getInt('${yesterdayKey}_ts');

      if (yesterdayRate != null && yesterdayTimestamp != null) {
        return {
          'rate': yesterdayRate,
          'date': DateTime.fromMillisecondsSinceEpoch(yesterdayTimestamp),
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveCachedRate(
      String from, String to, double rate, DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKey(from, to);
      await prefs.setDouble(key, rate);
      await prefs.setInt('${key}_ts', timestamp.millisecondsSinceEpoch);

      final keys = prefs.getKeys();
      for (final k in keys) {
        if (k.startsWith('rate_')) {
          final tsKey = '${k}_ts';
          final ts = prefs.getInt(tsKey);
          if (ts != null) {
            final age = DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(ts));
            if (age.inDays > 7) {
              await prefs.remove(k);
              await prefs.remove(tsKey);
            }
          }
        }
      }
    } catch (e) {
      // silent
    }
  }

  Future<void> _clearTodayCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKey(_from, _to);
      await prefs.remove(key);
      await prefs.remove('${key}_ts');
    } catch (e) {
      // silent
    }
  }

  String _formatDate(DateTime d) {
    return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<double> _fetchFrankfurter() async {
    try {
      final url = Uri.parse(
          'https://api.frankfurter.dev/v2/rate/$_from/$_to');
      final response =
          await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = (data['rate'] as num?)?.toDouble() ?? 0;
        if (rate > 0) return rate;
      }
    } catch (e) {
      // silent
    }
    return 0;
  }

  double _getFallbackRate(String from, String to) {
    final usdRates = {
      'USD': 1.0,
      'INR': 95.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'JPY': 149.5,
      'AUD': 1.52,
      'CAD': 1.36,
      'CHF': 0.88,
      'CNY': 7.24,
      'AED': 3.67,
      'SAR': 3.75,
      'SGD': 1.34,
      'HKD': 7.82,
      'NZD': 1.64,
      'KRW': 1330.0,
      'THB': 36.5,
      'MYR': 4.47,
      'IDR': 15800.0,
      'PHP': 56.5,
      'PKR': 278.0,
      'BDT': 110.0,
      'LKR': 305.0,
      'NPR': 152.0,
      'ZAR': 18.5,
      'BRL': 5.05,
      'MXN': 17.2,
      'RUB': 92.5,
      'TRY': 34.2,
      'SEK': 10.5,
      'NOK': 10.8,
    };
    final fromUsd = usdRates[from];
    final toUsd = usdRates[to];
    if (fromUsd == null || toUsd == null) return 0;
    return toUsd / fromUsd;
  }

  void _calculate() {
    final amt = double.tryParse(_amount.text) ?? 0;
    setState(() {
      _result = amt * _rate;
    });
  }

  void _swap() {
    setState(() {
      final temp = _from;
      _from = _to;
      _to = temp;
    });
    _fetchRate();
  }

  Future<void> _forceRefresh() async {
    await _clearTodayCache();
    await _fetchRate();
  }

  Future<void> _pickCurrency(bool isFrom) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kTextGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Select Currency',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextWhite)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _currencies.length,
                  itemBuilder: (context, i) {
                    final code = _currencies.keys.elementAt(i);
                    final info = _currencies[code]!;
                    final isSelected = (isFrom ? _from : _to) == code;
                    return ListTile(
                      onTap: () => Navigator.pop(context, code),
                      leading: Text(info['flag']!,
                          style: const TextStyle(fontSize: 28)),
                      title: Text(code,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? kRed : kTextWhite)),
                      subtitle: Text(info['name']!,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: kTextGrey)),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: kRed)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          _from = selected;
        } else {
          _to = selected;
        }
      });
      _fetchRate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: Text('Currency Converter',
            style: GoogleFonts.poppins(color: kTextWhite)),
        iconTheme: const IconThemeData(color: kTextWhite),
        actions: [
          IconButton(
            onPressed: _forceRefresh,
            icon: const Icon(Icons.refresh, color: kRed),
            tooltip: 'Force Refresh (clears cache)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('From',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickCurrency(true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kRed.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text(_currencies[_from]!['flag']!,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_from,
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kTextWhite)),
                          Text(_currencies[_from]!['name']!,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: kTextGrey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: kTextWhite),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.poppins(
                  color: kTextWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: kCard,
                hintText: 'Enter amount',
                hintStyle: GoogleFonts.poppins(color: kTextGrey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 18),
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _swap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kRed.withValues(alpha: 0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.swap_vert,
                      color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('To',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickCurrency(false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kRed.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text(_currencies[_to]!['flag']!,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_to,
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kTextWhite)),
                          Text(_currencies[_to]!['name']!,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: kTextGrey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: kTextWhite),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kRed, kRedDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  else ...[
                    Text('Converted Amount',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 8),
                    Text(
                      '${_currencies[_to]!['flag']} ${_result.toStringAsFixed(2)} $_to',
                      style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Text(
                      '1 $_from = ${_rate.toStringAsFixed(4)} $_to',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    if (_source.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _source.contains('Cache')
                                  ? Icons.cached
                                  : _source.contains('Live')
                                      ? Icons.cloud_done
                                      : Icons.offline_bolt,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(_source,
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                    if (_lastUpdated != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Updated: ${_lastUpdated!.hour}:${_lastUpdated!.minute.toString().padLeft(2, '0')} • ${_lastUpdated!.day}/${_lastUpdated!.month}/${_lastUpdated!.year}',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: kRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: kRed)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Popular Conversions',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextWhite)),
                TextButton.icon(
                  onPressed: _forceRefresh,
                  icon: const Icon(Icons.refresh, color: kRed, size: 16),
                  label: Text('Refresh',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: kRed)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickPair('USD', 'INR'),
                _quickPair('EUR', 'INR'),
                _quickPair('GBP', 'INR'),
                _quickPair('AED', 'INR'),
                _quickPair('USD', 'EUR'),
                _quickPair('INR', 'USD'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickPair(String from, String to) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _from = from;
          _to = to;
        });
        _fetchRate();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kRed.withValues(alpha: 0.3)),
        ),
        child: Text('$from → $to',
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextWhite)),
      ),
    );
  }
}

// ═══════ EMI ═══════
class EmiCalculator extends StatefulWidget {
  const EmiCalculator({super.key});
  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends State<EmiCalculator> {
  final _p = TextEditingController(text: '500000');
  final _r = TextEditingController(text: '8.5');
  final _n = TextEditingController(text: '12');
  double _emi = 0, _interest = 0, _total = 0;
  List<Map<String, dynamic>> _schedule = [];

  void _calc() {
    final p = double.tryParse(_p.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final n = double.tryParse(_n.text)?.toInt() ?? 0;
    if (p <= 0 || r <= 0 || n <= 0) return;

    final monthlyRate = r / 12 / 100;
    final emi = (p * monthlyRate * pow(1 + monthlyRate, n)) /
        (pow(1 + monthlyRate, n) - 1);

    double balance = p;
    List<Map<String, dynamic>> schedule = [];
    for (int i = 1; i <= n; i++) {
      final interestPaid = balance * monthlyRate;
      final principalPaid = emi - interestPaid;
      balance = balance - principalPaid;
      schedule.add({
        'month': i,
        'emi': emi,
        'interest': interestPaid,
        'principal': principalPaid,
        'balance': balance < 0 ? 0.0 : balance,
      });
    }

    setState(() {
      _emi = emi;
      _total = emi * n;
      _interest = _total - p;
      _schedule = schedule;
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
  }

  Future<void> _generatePdf() async {
    final bytes = await _buildEmiPdfBytes();
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'EMI_Statement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<Uint8List> _buildEmiPdfBytes() async {
    final pdf = pw.Document();
    final dateStr = _pdfDate();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) {
          if (context.pageNumber == 1) return pw.SizedBox();
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('EMI Statement - Smart Calculator',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700)),
                pw.Text(
                    'Page ${context.pageNumber}/${context.pagesCount}',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700)),
              ],
            ),
          );
        },
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'This is a computer-generated statement from Smart Calculator App.',
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ),
        build: (context) => [
          pdfHeader('EMI CALCULATION', 'Smart Calculator', dateStr),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Loan Details'),
          pdfRow('Loan Amount', 'Rs. ${_p.text}'),
          pdfRow('Interest Rate', '${_r.text}% p.a.'),
          pdfRow('Tenure', '${_n.text} Months'),
          pw.SizedBox(height: 20),
          pdfSummaryBox(
            label: 'Monthly EMI',
            value: 'Rs. ${_emi.toStringAsFixed(2)}',
            sub1: 'Principal',
            v1: 'Rs. ${_p.text}',
            sub2: 'Total Interest',
            v2: 'Rs. ${_interest.toStringAsFixed(2)}',
          ),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Month-wise Payment Schedule'),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.8),
              1: pw.FlexColumnWidth(1.4),
              2: pw.FlexColumnWidth(1.4),
              3: pw.FlexColumnWidth(1.5),
              4: pw.FlexColumnWidth(1.6),
            },
            children: [
              pdfTableHeaderRow(
                  ['Month', 'EMI', 'Interest', 'Principal', 'Balance']),
              ..._schedule.asMap().entries.map((e) {
                final i = e.key;
                final row = e.value;
                final isEven = i % 2 == 0;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven
                        ? PdfColors.white
                        : PdfColor.fromHex('#F8F8F8'),
                  ),
                  children: [
                    pdfDataCell('${row['month']}'),
                    pdfDataCell(
                        'Rs. ${(row['emi'] as double).toStringAsFixed(2)}'),
                    pdfDataCell(
                        'Rs. ${(row['interest'] as double).toStringAsFixed(2)}'),
                    pdfDataCell(
                        'Rs. ${(row['principal'] as double).toStringAsFixed(2)}'),
                    pdfDataCell(
                        'Rs. ${(row['balance'] as double).toStringAsFixed(2)}'),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F0F0F0'),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Summary',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(
                    'Total Principal: Rs. ${_p.text}  |  Total Interest: Rs. ${_interest.toStringAsFixed(2)}  |  Total Payment: Rs. ${_total.toStringAsFixed(2)}',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey800)),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: Text('EMI Calculator',
            style: GoogleFonts.poppins(color: kTextWhite)),
        iconTheme: const IconThemeData(color: kTextWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _inputField('Loan Amount (Rs.)', _p),
            _inputField('Interest Rate (% p.a.)', _r),
            _inputField('Tenure (Months)', _n),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _generatePdf,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kRed, kRedDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kRed.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('Tap to Download PDF',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color:
                                    Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Monthly EMI',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color:
                                Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 6),
                    Text('Rs. ${_emi.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Interest',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white
                                        .withValues(alpha: 0.7))),
                            Text('Rs. ${_interest.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total Payment',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white
                                        .withValues(alpha: 0.7))),
                            Text('Rs. ${_total.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _calc,
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: Text('Calculate EMI',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 55,
              child: OutlinedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.picture_as_pdf, color: kRed),
                label: Text('Download PDF Statement',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kRed, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final bytes = await _buildEmiPdfBytes();
                  await Printing.sharePdf(
                    bytes: bytes,
                    filename:
                        'EMI_Statement_${DateTime.now().millisecondsSinceEpoch}.pdf',
                  );
                },
                icon: const Icon(Icons.share, color: Color(0xFF25D366)),
                label: Text('Share on WhatsApp',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF25D366))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xFF25D366), width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: kTextWhite, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: kCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
            onChanged: (_) => _calc(),
          ),
        ],
      ),
    );
  }
}

// ═══════ SIP ═══════
class SipCalculator extends StatefulWidget {
  const SipCalculator({super.key});
  @override
  State<SipCalculator> createState() => _SipCalculatorState();
}

class _SipCalculatorState extends State<SipCalculator> {
  final _m = TextEditingController(text: '5000');
  final _r = TextEditingController(text: '12');
  final _y = TextEditingController(text: '10');
  double _mat = 0, _inv = 0;
  List<Map<String, dynamic>> _schedule = [];

  void _calc() {
    final m = double.tryParse(_m.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final y = double.tryParse(_y.text)?.toInt() ?? 0;
    if (m <= 0 || r <= 0 || y <= 0) return;
    final i = r / 12 / 100;
    final n = y * 12;

    List<Map<String, dynamic>> schedule = [];
    double cumulativeInv = 0;
    double cumulativeVal = 0;
    for (int yr = 1; yr <= y; yr++) {
      double yearInv = 0;
      for (int mth = 0; mth < 12; mth++) {
        yearInv += m;
        cumulativeInv += m;
        cumulativeVal = (cumulativeVal + m) * (1 + i);
      }
      schedule.add({
        'year': yr,
        'yearly': yearInv,
        'invested': cumulativeInv,
        'value': cumulativeVal,
        'returns': cumulativeVal - cumulativeInv,
      });
    }
    final mat = m * ((pow(1 + i, n) - 1) / i) * (1 + i);
    final inv = m * n;
    setState(() {
      _mat = mat;
      _inv = inv;
      _schedule = schedule;
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final dateStr = _pdfDate();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Computer-generated statement from Smart Calculator App.',
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ),
        build: (context) => [
          pdfHeader('SIP CALCULATION', 'Smart Calculator - Mutual Fund',
              dateStr),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Investment Details'),
          pdfRow('Monthly SIP', 'Rs. ${_m.text}'),
          pdfRow('Expected Return', '${_r.text}% p.a.'),
          pdfRow('Time Period', '${_y.text} Years'),
          pw.SizedBox(height: 16),
          pdfSummaryBox(
            label: 'Maturity Value',
            value: 'Rs. ${_mat.toStringAsFixed(2)}',
            sub1: 'Invested',
            v1: 'Rs. ${_inv.toStringAsFixed(2)}',
            sub2: 'Est. Returns',
            v2: 'Rs. ${(_mat - _inv).toStringAsFixed(2)}',
          ),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Year-wise Growth'),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.7),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(1.3),
              4: pw.FlexColumnWidth(1.2),
            },
            children: [
              pdfTableHeaderRow(
                  ['Year', 'Yearly SIP', 'Invested', 'Value', 'Returns']),
              ..._schedule.asMap().entries.map((e) {
                final r = e.value;
                final isEven = e.key % 2 == 0;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: isEven
                          ? PdfColors.white
                          : PdfColor.fromHex('#F8F8F8')),
                  children: [
                    pdfDataCell('${r['year']}'),
                    pdfDataCell(
                        'Rs. ${(r['yearly'] as double).toStringAsFixed(0)}'),
                    pdfDataCell(
                        'Rs. ${(r['invested'] as double).toStringAsFixed(0)}'),
                    pdfDataCell(
                        'Rs. ${(r['value'] as double).toStringAsFixed(0)}'),
                    pdfDataCell(
                        'Rs. ${(r['returns'] as double).toStringAsFixed(0)}'),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'SIP_Statement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return _simpleCalc(
      title: 'SIP Calculator',
      fields: [
        {'label': 'Monthly (Rs.)', 'c': _m},
        {'label': 'Return (% p.a.)', 'c': _r},
        {'label': 'Years', 'c': _y},
      ],
      onCalc: _calc,
      resultWidget: Column(
        children: [
          GestureDetector(
            onTap: _generatePdf,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: [kRed, kRedDark]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Tap to Download PDF',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Maturity Value',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Rs. ${_mat.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invested',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color:
                                      Colors.white.withValues(alpha: 0.7))),
                          Text('Rs. ${_inv.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Returns',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color:
                                      Colors.white.withValues(alpha: 0.7))),
                          Text('Rs. ${(_mat - _inv).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf, color: kRed),
              label: Text('Download PDF Statement',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kRed, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════ FD ═══════
class FdCalculator extends StatefulWidget {
  const FdCalculator({super.key});
  @override
  State<FdCalculator> createState() => _FdCalculatorState();
}

class _FdCalculatorState extends State<FdCalculator> {
  final _p = TextEditingController(text: '100000');
  final _r = TextEditingController(text: '7.5');
  final _t = TextEditingController(text: '5');
  double _mat = 0, _int = 0;
  List<Map<String, dynamic>> _schedule = [];

  void _calc() {
    final p = double.tryParse(_p.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final t = double.tryParse(_t.text)?.toInt() ?? 0;
    if (p <= 0 || r <= 0 || t <= 0) return;
    const n = 4;
    final mat = p * pow(1 + (r / 100) / n, n * t);

    List<Map<String, dynamic>> schedule = [];
    double balance = p;
    for (int yr = 1; yr <= t; yr++) {
      double openBal = balance;
      for (int q = 0; q < 4; q++) {
        balance = balance * (1 + (r / 100) / 4);
      }
      schedule.add({
        'year': yr,
        'opening': openBal,
        'closing': balance,
        'interest': balance - openBal,
      });
    }

    setState(() {
      _mat = mat;
      _int = mat - p;
      _schedule = schedule;
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final dateStr = _pdfDate();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Computer-generated FD maturity statement.',
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ),
        build: (context) => [
          pdfHeader('FD MATURITY CERTIFICATE',
              'Smart Calculator - Fixed Deposit', dateStr),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Deposit Details'),
          pdfRow('Principal Amount', 'Rs. ${_p.text}'),
          pdfRow('Interest Rate', '${_r.text}% p.a.'),
          pdfRow('Tenure', '${_t.text} Years'),
          pdfRow('Compounding', 'Quarterly'),
          pw.SizedBox(height: 16),
          pdfSummaryBox(
            label: 'Maturity Amount',
            value: 'Rs. ${_mat.toStringAsFixed(2)}',
            sub1: 'Principal',
            v1: 'Rs. ${_p.text}',
            sub2: 'Interest Earned',
            v2: 'Rs. ${_int.toStringAsFixed(2)}',
          ),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Year-wise Breakdown'),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.7),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.3),
              3: pw.FlexColumnWidth(1.5),
            },
            children: [
              pdfTableHeaderRow(
                  ['Year', 'Opening', 'Interest', 'Closing']),
              ..._schedule.asMap().entries.map((e) {
                final r = e.value;
                final isEven = e.key % 2 == 0;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: isEven
                          ? PdfColors.white
                          : PdfColor.fromHex('#F8F8F8')),
                  children: [
                    pdfDataCell('${r['year']}'),
                    pdfDataCell(
                        'Rs. ${(r['opening'] as double).toStringAsFixed(0)}'),
                    pdfDataCell(
                        'Rs. ${(r['interest'] as double).toStringAsFixed(0)}'),
                    pdfDataCell(
                        'Rs. ${(r['closing'] as double).toStringAsFixed(0)}'),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'FD_Statement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return _simpleCalc(
      title: 'FD Calculator',
      fields: [
        {'label': 'Principal (Rs.)', 'c': _p},
        {'label': 'Rate (% p.a.)', 'c': _r},
        {'label': 'Years', 'c': _t},
      ],
      onCalc: _calc,
      resultWidget: Column(
        children: [
          GestureDetector(
            onTap: _generatePdf,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: [kRed, kRedDark]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Tap to Download PDF',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Maturity Amount',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Rs. ${_mat.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Principal',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color:
                                      Colors.white.withValues(alpha: 0.7))),
                          Text('Rs. ${_p.text}',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Interest',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color:
                                      Colors.white.withValues(alpha: 0.7))),
                          Text('Rs. ${_int.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf, color: kRed),
              label: Text('Download FD Certificate',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kRed, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════ GST ═══════
class GstCalculator extends StatefulWidget {
  const GstCalculator({super.key});
  @override
  State<GstCalculator> createState() => _GstCalculatorState();
}

class _GstCalculatorState extends State<GstCalculator> {
  final _a = TextEditingController(text: '10000');
  double _rate = 18;
  String _mode = 'add';
  double _base = 0, _gst = 0, _total = 0;

  void _calc() {
    final a = double.tryParse(_a.text) ?? 0;
    if (a <= 0) return;
    setState(() {
      if (_mode == 'add') {
        _gst = a * _rate / 100;
        _base = a;
        _total = a + _gst;
      } else {
        _base = a * 100 / (100 + _rate);
        _gst = a - _base;
        _total = a;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final dateStr = _pdfDate();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Computer-generated tax invoice from Smart Calculator App.',
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ),
        build: (context) => [
          pdfHeader('GST INVOICE', 'Smart Calculator - Tax Calculation',
              dateStr),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Invoice Details'),
          pdfRow('Mode', _mode == 'add' ? 'Add GST' : 'Remove GST'),
          pdfRow('GST Rate', '$_rate%'),
          pdfRow('Entered Amount', 'Rs. ${_a.text}'),
          pw.SizedBox(height: 16),
          pdfSummaryBox(
            label: 'Total Amount',
            value: 'Rs. ${_total.toStringAsFixed(2)}',
            sub1: 'Base Amount',
            v1: 'Rs. ${_base.toStringAsFixed(2)}',
            sub2: 'GST ($_rate%)',
            v2: 'Rs. ${_gst.toStringAsFixed(2)}',
          ),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Tax Breakdown'),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1.5),
            },
            children: [
              pdfTableHeaderRow(['Description', 'Amount']),
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfColor.fromHex('#F8F8F8')),
                children: [
                  pdfDataCell('Base Amount (Taxable Value)'),
                  pdfDataCell('Rs. ${_base.toStringAsFixed(2)}'),
                ],
              ),
              pw.TableRow(
                children: [
                  pdfDataCell('CGST (${_rate / 2}%)'),
                  pdfDataCell('Rs. ${(_gst / 2).toStringAsFixed(2)}'),
                ],
              ),
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfColor.fromHex('#F8F8F8')),
                children: [
                  pdfDataCell('SGST (${_rate / 2}%)'),
                  pdfDataCell('Rs. ${(_gst / 2).toStringAsFixed(2)}'),
                ],
              ),
              pw.TableRow(
                children: [
                  pdfDataCell('Total GST'),
                  pdfDataCell('Rs. ${_gst.toStringAsFixed(2)}'),
                ],
              ),
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFE5E5')),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Grand Total',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Rs. ${_total.toStringAsFixed(2)}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#E63946'))),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Note: CGST and SGST are equally divided from total GST. '
              'For inter-state transactions, IGST may apply instead.',
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'GST_Invoice_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: Text('GST Calculator',
            style: GoogleFonts.poppins(color: kTextWhite)),
        iconTheme: const IconThemeData(color: kTextWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Amount (Rs.)',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 6),
            TextField(
              controller: _a,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: kTextWhite, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: kCard,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (_) => _calc(),
            ),
            const SizedBox(height: 16),
            Text('GST Rate',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              children: [5.0, 12.0, 18.0, 28.0].map((r) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _rate = r);
                    _calc();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: _rate == r ? kRed : kCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$r%',
                        style: GoogleFonts.poppins(
                            color: kTextWhite,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: ['add', 'remove'].map((m) {
                final selected = _mode == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _mode = m);
                      _calc();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? kRed : kCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(m == 'add' ? 'Add GST' : 'Remove GST',
                            style: GoogleFonts.poppins(
                                color: kTextWhite,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _generatePdf,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [kRed, kRedDark]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kRed.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('Tap to Download PDF',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Total Amount',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 6),
                    Text('Rs. ${_total.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Base Amount',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color:
                                        Colors.white.withValues(alpha: 0.7))),
                            Text('Rs. ${_base.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('GST ($_rate%)',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color:
                                        Colors.white.withValues(alpha: 0.7))),
                            Text('Rs. ${_gst.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.picture_as_pdf, color: kRed),
                label: Text('Download GST Invoice',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kRed, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════ BMI ═══════
class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});
  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {
  final _w = TextEditingController(text: '70');
  final _h = TextEditingController(text: '170');
  double _bmi = 0;
  String _cat = '';
  Color _catColor = kRed;

  void _calc() {
    final w = double.tryParse(_w.text) ?? 0;
    final h = (double.tryParse(_h.text) ?? 0) / 100;
    if (w <= 0 || h <= 0) return;
    setState(() {
      _bmi = w / (h * h);
      if (_bmi < 18.5) {
        _cat = 'Underweight';
        _catColor = const Color(0xFF3B82F6);
      } else if (_bmi < 25) {
        _cat = 'Normal';
        _catColor = const Color(0xFF00D09C);
      } else if (_bmi < 30) {
        _cat = 'Overweight';
        _catColor = const Color(0xFFFFA500);
      } else {
        _cat = 'Obese';
        _catColor = kRed;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final dateStr = _pdfDate();
    final w = double.tryParse(_w.text) ?? 0;
    final h = double.tryParse(_h.text) ?? 0;
    final idealMin = 18.5 * (h / 100) * (h / 100);
    final idealMax = 24.9 * (h / 100) * (h / 100);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Computer-generated health report from Smart Calculator App.',
            style:
                const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ),
        build: (context) => [
          pdfHeader('BMI HEALTH REPORT', 'Smart Calculator - Health Check',
              dateStr),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Personal Details'),
          pdfRow('Weight', '$w kg'),
          pdfRow('Height', '$h cm'),
          pw.SizedBox(height: 16),
          pdfSummaryBox(
            label: 'Your BMI Score',
            value: _bmi.toStringAsFixed(1),
            sub1: 'Category',
            v1: _cat,
            sub2: 'Ideal Range',
            v2:
                '${idealMin.toStringAsFixed(1)} - ${idealMax.toStringAsFixed(1)} kg',
          ),
          pw.SizedBox(height: 20),
          pdfSectionTitle('BMI Categories'),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(1.5),
            },
            children: [
              pdfTableHeaderRow(['BMI Range', 'Category']),
              _bmiCatRow('< 18.5', 'Underweight (Blue)', _bmi < 18.5),
              _bmiCatRow('18.5 - 24.9', 'Normal (Green)',
                  _bmi >= 18.5 && _bmi < 25),
              _bmiCatRow('25.0 - 29.9', 'Overweight (Orange)',
                  _bmi >= 25 && _bmi < 30),
              _bmiCatRow('>= 30.0', 'Obese (Red)', _bmi >= 30),
            ],
          ),
          pw.SizedBox(height: 20),
          pdfSectionTitle('Health Tips'),
          pw.Bullet(
              text:
                  'Maintain a balanced diet with fruits, vegetables and whole grains.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Bullet(
              text: 'Exercise for at least 30 minutes, 5 days a week.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Bullet(
              text: 'Drink 8-10 glasses of water daily.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Bullet(
              text: 'Get 7-8 hours of quality sleep every night.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Bullet(
              text:
                  'Consult a doctor or nutritionist for personalized advice.',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'BMI_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  pw.TableRow _bmiCatRow(String range, String label, bool isActive) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isActive
            ? PdfColor.fromHex('#FFE5E5')
            : PdfColors.white,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(range,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight:
                      isActive ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text('${isActive ? "▶ " : ""}$label',
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight:
                      isActive ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: isActive
                      ? PdfColor.fromHex('#E63946')
                      : PdfColors.black)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _simpleCalc(
      title: 'BMI Calculator',
      fields: [
        {'label': 'Weight (kg)', 'c': _w},
        {'label': 'Height (cm)', 'c': _h},
      ],
      onCalc: _calc,
      resultWidget: Column(
        children: [
          GestureDetector(
            onTap: _generatePdf,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: [kRed, kRedDark]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Tap to Download PDF',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Your BMI',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9))),
                  const SizedBox(height: 6),
                  Text(_bmi.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_cat,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf, color: kRed),
              label: Text('Download BMI Report',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kRed, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════ AGE ═══════
class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});
  @override
  State<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> {
  DateTime? _dob;
  String _res = '';

  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kRed,
              onPrimary: kTextWhite,
              surface: kCard,
              onSurface: kTextWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) {
      setState(() => _dob = d);
      _calc();
    }
  }

  void _calc() {
    if (_dob == null) return;
    final dob = _dob!;
    final now = DateTime.now();
    int y = now.year - dob.year;
    int m = now.month - dob.month;
    int d = now.day - dob.day;
    if (d < 0) {
      m--;
      d += DateTime(now.year, now.month, 0).day;
    }
    if (m < 0) {
      y--;
      m += 12;
    }
    setState(() => _res = '$y years, $m months, $d days');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: Text('Age Calculator',
            style: GoogleFonts.poppins(color: kTextWhite)),
        iconTheme: const IconThemeData(color: kTextWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _pick,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: kRed),
                      const SizedBox(width: 14),
                      Text(
                        _dob == null
                            ? 'Select Date of Birth'
                            : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: kTextWhite,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_res.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [kRed, kRedDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text('Your Age',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 8),
                    Text(_res,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════ DATE ═══════
class DateCalculator extends StatefulWidget {
  const DateCalculator({super.key});
  @override
  State<DateCalculator> createState() => _DateCalculatorState();
}

class _DateCalculatorState extends State<DateCalculator> {
  DateTime? _s, _e;
  String _res = '';

  Future<void> _pick(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kRed,
              onPrimary: kTextWhite,
              surface: kCard,
              onSurface: kTextWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) {
      setState(() => isStart ? _s = d : _e = d);
      _calc();
    }
  }

  void _calc() {
    if (_s == null || _e == null) return;
    final diff = _e!.difference(_s!).inDays.abs();
    setState(() => _res = '$diff days');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: Text('Date Calculator',
            style: GoogleFonts.poppins(color: kTextWhite)),
        iconTheme: const IconThemeData(color: kTextWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dateBtn(_s, 'Start Date', () => _pick(true)),
            const SizedBox(height: 12),
            _dateBtn(_e, 'End Date', () => _pick(false)),
            const SizedBox(height: 20),
            if (_res.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [kRed, kRedDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text('Difference',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(_res,
                        style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dateBtn(DateTime? d, String label, VoidCallback onTap) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: kRed),
              const SizedBox(width: 14),
              Text(
                d == null ? label : '${d.day}/${d.month}/${d.year}',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: kTextWhite,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════ UNIT ═══════
class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});
  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  String _cat = 'length';
  String _from = 'm';
  String _to = 'km';
  final _val = TextEditingController(text: '1');
  String _res = '';

  final Map<String, Map<String, double>> _units = {
    'length': {
      'm': 1,
      'km': 1000,
      'cm': 0.01,
      'mm': 0.001,
      'inch': 0.0254,
      'ft': 0.3048,
      'mile': 1609.34
    },
    'weight': {
      'kg': 1,
      'g': 0.001,
      'mg': 0.000001,
      'ton': 1000,
      'lb': 0.453592,
      'oz': 0.0283495
    },
  };

  List<String> get _u {
    if (_cat == 'temp') return ['C', 'F', 'K'];
    return _units[_cat]!.keys.toList();
  }

  void _convert() {
    final v = double.tryParse(_val.text) ?? 0;
    if (v == 0) {
      setState(() => _res = '');
      return;
    }
    double r;
    if (_cat == 'temp') {
      double c;
      if (_from == 'C') {
        c = v;
      } else if (_from == 'F') {
        c = (v - 32) * 5 / 9;
      } else {
        c = v - 273.15;
      }
      if (_to == 'C') {
        r = c;
      } else if (_to == 'F') {
        r = c * 9 / 5 + 32;
      } else {
        r = c + 273.15;
      }
    } else {
      r = v * _units[_cat]![_from]! / _units[_cat]![_to]!;
    }
    setState(() => _res = '${r.toStringAsFixed(4)} $_to');
  }

  @override
  void initState() {
    super.initState();
    _convert();
  }

  Widget _dropDown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: kCard2,
              icon: const Icon(Icons.keyboard_arrow_down, color: kTextWhite),
              style: GoogleFonts.poppins(color: kTextWhite, fontSize: 15),
              items: items.map((u) {
                return DropdownMenuItem(
                    value: u,
                    child: Text(u,
                        style: GoogleFonts.poppins(color: kTextWhite)));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final units = _u;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: Text('Unit Converter',
            style: GoogleFonts.poppins(color: kTextWhite)),
        iconTheme: const IconThemeData(color: kTextWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Category',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: ['length', 'weight', 'temp'].map((c) {
                final sel = _cat == c;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _cat = c;
                      _from = _u.first;
                      _to = _u.last;
                    });
                    _convert();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? kRed : kCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      c == 'length'
                          ? 'Length'
                          : (c == 'weight' ? 'Weight' : 'Temp'),
                      style: GoogleFonts.poppins(
                          color: kTextWhite, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Value',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 6),
            TextField(
              controller: _val,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: kTextWhite, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: kCard,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _dropDown('From', _from, units, (v) {
                  setState(() => _from = v!);
                  _convert();
                })),
                const SizedBox(width: 12),
                Expanded(
                    child: _dropDown('To', _to, units, (v) {
                  setState(() => _to = v!);
                  _convert();
                })),
              ],
            ),
            const SizedBox(height: 24),
            if (_res.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [kRed, kRedDark]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text('Result',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 8),
                    Text(_res,
                        style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════ HELPERS ═══════
Widget _simpleCalc({
  required String title,
  required List<Map<String, dynamic>> fields,
  required VoidCallback onCalc,
  required Widget resultWidget,
}) {
  return Scaffold(
    backgroundColor: kBg,
    appBar: AppBar(
      backgroundColor: kBg,
      title: Text(title, style: GoogleFonts.poppins(color: kTextWhite)),
      iconTheme: const IconThemeData(color: kTextWhite),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f['label'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: kTextGrey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: f['c'] as TextEditingController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                          color: kTextWhite, fontSize: 15),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kCard,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      onChanged: (_) => onCalc(),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          resultWidget,
        ],
      ),
    ),
  );
}

// ═══════ PDF HELPERS ═══════
pw.Widget pdfHeader(String title, String subtitle, String date) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#E63946'),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text(subtitle,
                style: const pw.TextStyle(
                    fontSize: 11, color: PdfColors.white)),
          ],
        ),
        pw.Text('Generated:\n$date',
            textAlign: pw.TextAlign.right,
            style:
                const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
      ],
    ),
  );
}

pw.Widget pdfRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(
                fontSize: 11, color: PdfColors.grey700)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

pw.Widget pdfSectionTitle(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(title,
        style: pw.TextStyle(
            fontSize: 14, fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget pdfHeaderCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white)),
  );
}

pw.Widget pdfDataCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 8.5)),
  );
}

pw.TableRow pdfTableHeaderRow(List<String> columns) {
  return pw.TableRow(
    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E63946')),
    children: columns.map((c) => pdfHeaderCell(c)).toList(),
  );
}

pw.Widget pdfSummaryBox(
    {required String label,
    required String value,
    String? sub1,
    String? v1,
    String? sub2,
    String? v2}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('#FFF0F0'),
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(
          color: PdfColor.fromHex('#E63946'), width: 1.5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(
                fontSize: 11, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#E63946'))),
        if (sub1 != null) ...[
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey400, height: 1),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(sub1,
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey600)),
                  pw.Text(v1 ?? '',
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (sub2 != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(sub2,
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey600)),
                    pw.Text(v2 ?? '',
                        style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

String _pdfDate() {
  final n = DateTime.now();
  return '${n.day}/${n.month}/${n.year} ${n.hour}:${n.minute.toString().padLeft(2, '0')}';
}
