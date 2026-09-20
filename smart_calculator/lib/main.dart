import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

// ═══════ COLORS (Black + Red Theme) ═══════
const kBg = Color(0xFF000000);           // Pure Black
const kCard = Color(0xFF1A1A1A);         // Dark Grey Card
const kCard2 = Color(0xFF262626);        // Lighter Grey
const kRed = Color(0xFFFF2E2E);          // Bright Red
const kRedDark = Color(0xFFCC1F1F);      // Dark Red
const kRedGlow = Color(0xFFFF4444);      // Red Glow
const kGrey = Color(0xFF2E2E2E);         // Button Grey
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

  // ✅ Soft Red (thoda dark)
  static const Color softRed = Color(0xFFE63946);
  static const Color darkGrey = Color(0xFF2A2A2A);
  static const Color lightGrey = Color(0xFF3A3A3A);

  void _onKey(String v) {
    setState(() {
      if (v == 'C') {
        _display = '0';
      } else if (v == '⌫') {
        _display = _display.length > 1
            ? _display.substring(0, _display.length - 1)
            : '0';
      } else if (v == '=') {
        try {
          final result = _eval(_display);
          _display = result.toStringAsFixed(
              result.truncateToDouble() == result ? 0 : 4);
        } catch (e) {
          _display = 'Error';
        }
      } else {
        if (_display == '0' && '0123456789.'.contains(v)) {
          _display = v;
        } else {
          _display += v;
        }
      }
    });
  }

  double _eval(String s) {
    s = s.replaceAll('×', '*').replaceAll('÷', '/');
    return _parse(s);
  }

  double _parse(String s) {
    for (int i = s.length - 1; i > 0; i--) {
      if ((s[i] == '+' || s[i] == '-') && !'*/'.contains(s[i - 1])) {
        return s[i] == '+'
            ? _parse(s.substring(0, i)) + _parse(s.substring(i + 1))
            : _parse(s.substring(0, i)) - _parse(s.substring(i + 1));
      }
    }
    for (int i = s.length - 1; i > 0; i--) {
      if (s[i] == '*' || s[i] == '/') {
        return s[i] == '*'
            ? _parse(s.substring(0, i)) * _parse(s.substring(i + 1))
            : _parse(s.substring(0, i)) / _parse(s.substring(i + 1));
      }
    }
    return double.parse(s);
  }

  // ✅ FIXED: Clean colors, no bright/muddy issues
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
              onTap: () => _onKey(label),
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
          // Header
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
          // Display
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: SingleChildScrollView(
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
            ),
          ),
          // Keypad
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // Row 1: C, ⌫, %, ÷
                  Row(children: [
                    // C - soft red background, white text
                    _btn('C', bg: softRed, fg: kTextWhite),
                    // Backspace - dark grey with red icon color
                    _btn('⌫', bg: darkGrey, fg: softRed),
                    // % - dark grey, white text
                    _btn('%', bg: darkGrey, fg: kTextWhite),
                    // ÷ - dark grey with red text
                    _btn('÷', bg: darkGrey, fg: softRed),
                  ]),
                  // Row 2: 7, 8, 9, ×
                  Row(children: [
                    _btn('7'),
                    _btn('8'),
                    _btn('9'),
                    _btn('×', bg: darkGrey, fg: softRed),
                  ]),
                  // Row 3: 4, 5, 6, −
                  Row(children: [
                    _btn('4'),
                    _btn('5'),
                    _btn('6'),
                    _btn('-', bg: darkGrey, fg: softRed),
                  ]),
                  // Row 4: 1, 2, 3, +
                  Row(children: [
                    _btn('1'),
                    _btn('2'),
                    _btn('3'),
                    _btn('+', bg: darkGrey, fg: softRed),
                  ]),
                  // ✅ Row 5: 0, ., = (SIRF EK '=' button)
                  Row(children: [
                    _btn('0'),
                    _btn('.'),
                    // '=' button - double width, soft red
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
                              onTap: () => _onKey('='),
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
      {'t': 'SIP Calculator', 's': 'Mutual Fund', 'i': Icons.trending_up, 'c': Color(0xFF00D09C), 'screen': const SipCalculator()},
      {'t': 'FD Calculator', 's': 'Fixed Deposit', 'i': Icons.savings, 'c': Color(0xFFFFA500), 'screen': const FdCalculator()},
      {'t': 'GST Calculator', 's': 'Tax Calculator', 'i': Icons.receipt_long, 'c': Color(0xFF8B5CF6), 'screen': const GstCalculator()},
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
              ],
            ),
            const SizedBox(height: 6),
            Text('Everything you need to plan finances',
                style: GoogleFonts.poppins(fontSize: 13, color: kTextGrey)),
            const SizedBox(height: 20),

            // Portfolio Card - Red Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kRed, Color(0xFF8B0000)],
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
      {'t': 'Age', 'i': Icons.cake, 'c': Color(0xFFFF6B9D), 's': const AgeCalculator()},
      {'t': 'Date', 'i': Icons.calendar_month, 'c': Color(0xFF3B82F6), 's': const DateCalculator()},
      {'t': 'Unit', 'i': Icons.swap_horiz, 'c': Color(0xFF00D09C), 's': const UnitConverter()},
      {'t': 'Tax', 'i': Icons.receipt, 'c': Color(0xFF8B5CF6), 's': const GstCalculator()},
      {'t': 'Currency', 'i': Icons.currency_exchange, 'c': Color(0xFFFFA500), 's': const CurrencyScreen()},
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
class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        title: Text('Currency',
            style: GoogleFonts.poppins(color: kTextWhite)),
        iconTheme: const IconThemeData(color: kTextWhite),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: kRed.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.currency_exchange,
                    color: kRed, size: 50),
              ),
              const SizedBox(height: 20),
              Text('Currency Converter',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kTextWhite)),
              const SizedBox(height: 8),
              Text('Live rates coming soon...',
                  style: GoogleFonts.poppins(fontSize: 14, color: kTextGrey)),
            ],
          ),
        ),
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
  final _n = TextEditingController(text: '60');
  double _emi = 0, _interest = 0, _total = 0;

  void _calc() {
    final p = double.tryParse(_p.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final n = double.tryParse(_n.text) ?? 0;
    if (p <= 0 || r <= 0 || n <= 0) return;
    final i = r / 12 / 100;
    final emi = (p * i * pow(1 + i, n)) / (pow(1 + i, n) - 1);
    setState(() {
      _emi = emi;
      _total = emi * n;
      _interest = _total - p;
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
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
            _inputField('Loan Amount (₹)', _p),
            _inputField('Interest Rate (% p.a.)', _r),
            _inputField('Tenure (Months)', _n),
            const SizedBox(height: 10),
            _resultCard('Monthly EMI', '₹ ${_emi.toStringAsFixed(0)}',
                sub1: 'Total Interest', v1: _interest,
                sub2: 'Total Payment', v2: _total),
            const SizedBox(height: 16),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _calc,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: kRed.withValues(alpha: 0.5),
                ),
                child: Text('Calculate EMI',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kTextWhite)),
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

  void _calc() {
    final m = double.tryParse(_m.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final y = double.tryParse(_y.text) ?? 0;
    if (m <= 0 || r <= 0 || y <= 0) return;
    final i = r / 12 / 100;
    final n = y * 12;
    setState(() {
      _mat = m * ((pow(1 + i, n) - 1) / i) * (1 + i);
      _inv = m * n;
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
  }

  @override
  Widget build(BuildContext context) {
    return _simpleCalc(
      title: 'SIP Calculator',
      fields: [
        {'label': 'Monthly (₹)', 'c': _m},
        {'label': 'Return (% p.a.)', 'c': _r},
        {'label': 'Years', 'c': _y},
      ],
      onCalc: _calc,
      resultWidget: _resultCard('Maturity', '₹ ${_mat.toStringAsFixed(0)}',
          sub1: 'Invested', v1: _inv, sub2: 'Returns', v2: _mat - _inv),
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
  double _mat = 0, _inv = 0;

  void _calc() {
    final p = double.tryParse(_p.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final t = double.tryParse(_t.text) ?? 0;
    if (p <= 0 || r <= 0 || t <= 0) return;
    const n = 4;
    setState(() {
      _mat = p * pow(1 + (r / 100) / n, n * t);
      _inv = p;
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
  }

  @override
  Widget build(BuildContext context) {
    return _simpleCalc(
      title: 'FD Calculator',
      fields: [
        {'label': 'Principal (₹)', 'c': _p},
        {'label': 'Rate (% p.a.)', 'c': _r},
        {'label': 'Years', 'c': _t},
      ],
      onCalc: _calc,
      resultWidget: _resultCard('Maturity', '₹ ${_mat.toStringAsFixed(0)}',
          sub1: 'Principal', v1: _inv, sub2: 'Interest', v2: _mat - _inv),
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
            Text('Amount (₹)',
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
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
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
            _resultCard('Total', '₹ ${_total.toStringAsFixed(0)}',
                sub1: 'Base', v1: _base, sub2: 'GST', v2: _gst),
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

  void _calc() {
    final w = double.tryParse(_w.text) ?? 0;
    final h = (double.tryParse(_h.text) ?? 0) / 100;
    if (w <= 0 || h <= 0) return;
    setState(() {
      _bmi = w / (h * h);
      if (_bmi < 18.5) {
        _cat = 'Underweight';
      } else if (_bmi < 25) {
        _cat = 'Normal';
      } else if (_bmi < 30) {
        _cat = 'Overweight';
      } else {
        _cat = 'Obese';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _calc();
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
      resultWidget: _bmiCard(_bmi, _cat),
    );
  }

  Widget _bmiCard(double bmi, String cat) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kRed, Color(0xFF8B0000)],
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
          Text('Your BMI',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: kTextWhite.withValues(alpha: 0.9))),
          const SizedBox(height: 6),
          Text(bmi.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: kTextWhite)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: kTextWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(cat,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextWhite)),
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
                  gradient: const LinearGradient(
                      colors: [kRed, Color(0xFF8B0000)]),
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
                    Text('Your Age',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: kTextWhite.withValues(alpha: 0.9))),
                    const SizedBox(height: 8),
                    Text(_res,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: kTextWhite)),
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
                  gradient: const LinearGradient(
                      colors: [kRed, Color(0xFF8B0000)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text('Difference',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: kTextWhite)),
                    const SizedBox(height: 8),
                    Text(_res,
                        style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: kTextWhite)),
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
    'length': {'m': 1, 'km': 1000, 'cm': 0.01, 'mm': 0.001, 'inch': 0.0254, 'ft': 0.3048, 'mile': 1609.34},
    'weight': {'kg': 1, 'g': 0.001, 'mg': 0.000001, 'ton': 1000, 'lb': 0.453592, 'oz': 0.0283495},
  };

  List<String> get _u => _cat == 'temp' ? ['C', 'F', 'K'] : _units[_cat]!.keys.toList();

  void _convert() {
    final v = double.tryParse(_val.text) ?? 0;
    if (v == 0) {
      setState(() => _res = '');
      return;
    }
    double r;
    if (_cat == 'temp') {
      double c;
      if (_from == 'C') c = v;
      else if (_from == 'F') c = (v - 32) * 5 / 9;
      else c = v - 273.15;
      if (_to == 'C') r = c;
      else if (_to == 'F') r = c * 9 / 5 + 32;
      else r = c + 273.15;
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

  @override
  Widget build(BuildContext context) {
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
                      c == 'length' ? 'Length' : (c == 'weight' ? 'Weight' : 'Temp'),
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
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _dropDown('From', _from, _u, (v) {
                  setState(() => _from = v!);
                  _convert();
                })),
                const SizedBox(width: 12),
                Expanded(child: _dropDown('To', _to, _u, (v) {
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
                  gradient: const LinearGradient(
                      colors: [kRed, Color(0xFF8B0000)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text('Result',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: kTextWhite.withValues(alpha: 0.9))),
                    const SizedBox(height: 8),
                    Text(_res,
                        style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: kTextWhite)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
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

Widget _resultCard(String title, String value,
    {required String sub1,
    required double v1,
    required String sub2,
    required double v2}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [kRed, Color(0xFF8B0000)],
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
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 13, color: kTextWhite.withValues(alpha: 0.9))),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: kTextWhite)),
        const SizedBox(height: 12),
        Divider(color: kTextWhite.withValues(alpha: 0.2)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub1,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: kTextWhite.withValues(alpha: 0.7))),
                Text('₹ ${v1.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextWhite)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(sub2,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: kTextWhite.withValues(alpha: 0.7))),
                Text('₹ ${v2.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kTextWhite)),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
