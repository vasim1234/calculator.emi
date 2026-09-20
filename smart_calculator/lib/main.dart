import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const SmartCalculatorApp());
}

class SmartCalculatorApp extends StatelessWidget {
  const SmartCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4F46E5),
          foregroundColor: Colors.white,
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
      body: _screens[_i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Calc'),
          NavigationDestination(icon: Icon(Icons.currency_rupee), label: 'Finance'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.currency_exchange), label: 'Currency'),
        ],
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

  void _onKey(String v) {
    setState(() {
      if (v == 'C') {
        _display = '0';
      } else if (v == '⌫') {
        _display = _display.length > 1 ? _display.substring(0, _display.length - 1) : '0';
      } else if (v == '=') {
        try {
          final result = _eval(_display);
          _display = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 4);
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

  Widget _btn(String label, {Color? bg, Color? fg, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AspectRatio(
          aspectRatio: 1.15,
          child: ElevatedButton(
            onPressed: () => _onKey(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: bg ?? Colors.white,
              foregroundColor: fg ?? Colors.black87,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧮 Calculator')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(_display,
                    style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(children: [
                    _btn('C', bg: Colors.red.shade100),
                    _btn('⌫', bg: Colors.orange.shade100),
                    _btn('%', bg: Colors.orange.shade100),
                    _btn('÷', bg: Colors.indigo.shade100),
                  ]),
                  Row(children: [
                    _btn('7'), _btn('8'), _btn('9'),
                    _btn('×', bg: Colors.indigo.shade100),
                  ]),
                  Row(children: [
                    _btn('4'), _btn('5'), _btn('6'),
                    _btn('-', bg: Colors.indigo.shade100),
                  ]),
                  Row(children: [
                    _btn('1'), _btn('2'), _btn('3'),
                    _btn('+', bg: Colors.indigo.shade100),
                  ]),
                  // ✅ FIXED: single '=' button with double width
                  Row(children: [
                    _btn('0'),
                    _btn('.'),
                    _btn('=', bg: Colors.green.shade400, fg: Colors.white, flex: 2),
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
      {'t': 'EMI Calculator', 'i': Icons.home_work, 'c': Colors.indigo, 's': const EmiCalculator()},
      {'t': 'SIP Calculator', 'i': Icons.trending_up, 'c': Colors.green, 's': const SipCalculator()},
      {'t': 'FD Calculator', 'i': Icons.savings, 'c': Colors.orange, 's': const FdCalculator()},
      {'t': 'GST Calculator', 'i': Icons.receipt_long, 'c': Colors.purple, 's': const GstCalculator()},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('💰 Finance')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: (it['c'] as Color).withValues(alpha: 0.15),
                child: Icon(it['i'] as IconData, color: it['c'] as Color),
              ),
              title: Text(it['t'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => it['s'] as Widget)),
            ),
          );
        },
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
      {'t': 'BMI Calculator', 'i': Icons.favorite, 'c': Colors.red, 's': const BmiCalculator()},
      {'t': 'Age Calculator', 'i': Icons.cake, 'c': Colors.pink, 's': const AgeCalculator()},
      {'t': 'Date Calculator', 'i': Icons.calendar_month, 'c': Colors.blue, 's': const DateCalculator()},
      {'t': 'Unit Converter', 'i': Icons.swap_horiz, 'c': Colors.teal, 's': const UnitConverter()},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('🔧 Tools')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: (it['c'] as Color).withValues(alpha: 0.15),
                child: Icon(it['i'] as IconData, color: it['c'] as Color),
              ),
              title: Text(it['t'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => it['s'] as Widget)),
            ),
          );
        },
      ),
    );
  }
}

// ═══════ CURRENCY (placeholder) ═══════
class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💱 Currency')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Live Currency Converter\n\n(API integration next update mein)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
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
  final _p = TextEditingController();
  final _r = TextEditingController();
  final _n = TextEditingController();
  String _res = '';

  void _calc() {
    final p = double.tryParse(_p.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final n = double.tryParse(_n.text) ?? 0;
    if (p <= 0 || r <= 0 || n <= 0) {
      setState(() => _res = '⚠️ Sabhi fields sahi bharo');
      return;
    }
    final i = r / 12 / 100;
    final emi = (p * i * pow(1 + i, n)) / (pow(1 + i, n) - 1);
    final total = emi * n;
    setState(() {
      _res = 'Monthly EMI: ₹${emi.toStringAsFixed(2)}\n'
          'Total Interest: ₹${(total - p).toStringAsFixed(2)}\n'
          'Total Payment: ₹${total.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _calcScreen('EMI Calculator', [
      _field('Loan Amount (₹)', _p, '500000'),
      _field('Interest Rate (% p.a.)', _r, '8.5'),
      _field('Tenure (Months)', _n, '60'),
    ], _calc, _res);
  }
}

// ═══════ SIP ═══════
class SipCalculator extends StatefulWidget {
  const SipCalculator({super.key});
  @override
  State<SipCalculator> createState() => _SipCalculatorState();
}

class _SipCalculatorState extends State<SipCalculator> {
  final _m = TextEditingController();
  final _r = TextEditingController();
  final _y = TextEditingController();
  String _res = '';

  void _calc() {
    final m = double.tryParse(_m.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final y = double.tryParse(_y.text) ?? 0;
    if (m <= 0 || r <= 0 || y <= 0) {
      setState(() => _res = '⚠️ Sabhi fields sahi bharo');
      return;
    }
    final i = r / 12 / 100;
    final n = y * 12;
    final mat = m * ((pow(1 + i, n) - 1) / i) * (1 + i);
    final inv = m * n;
    setState(() {
      _res = 'Invested: ₹${inv.toStringAsFixed(0)}\n'
          'Returns: ₹${(mat - inv).toStringAsFixed(0)}\n'
          'Maturity: ₹${mat.toStringAsFixed(0)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _calcScreen('SIP Calculator', [
      _field('Monthly Investment (₹)', _m, '5000'),
      _field('Expected Return (% p.a.)', _r, '12'),
      _field('Time Period (Years)', _y, '10'),
    ], _calc, _res);
  }
}

// ═══════ FD ═══════
class FdCalculator extends StatefulWidget {
  const FdCalculator({super.key});
  @override
  State<FdCalculator> createState() => _FdCalculatorState();
}

class _FdCalculatorState extends State<FdCalculator> {
  final _p = TextEditingController();
  final _r = TextEditingController();
  final _t = TextEditingController();
  String _res = '';

  void _calc() {
    final p = double.tryParse(_p.text) ?? 0;
    final r = double.tryParse(_r.text) ?? 0;
    final t = double.tryParse(_t.text) ?? 0;
    if (p <= 0 || r <= 0 || t <= 0) {
      setState(() => _res = '⚠️ Sabhi fields sahi bharo');
      return;
    }
    const n = 4;
    final mat = p * pow(1 + (r / 100) / n, n * t);
    setState(() {
      _res = 'Maturity: ₹${mat.toStringAsFixed(0)}\n'
          'Interest: ₹${(mat - p).toStringAsFixed(0)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _calcScreen('FD Calculator', [
      _field('Principal (₹)', _p, '100000'),
      _field('Interest Rate (% p.a.)', _r, '7.5'),
      _field('Tenure (Years)', _t, '5'),
    ], _calc, _res);
  }
}

// ═══════ GST ═══════
class GstCalculator extends StatefulWidget {
  const GstCalculator({super.key});
  @override
  State<GstCalculator> createState() => _GstCalculatorState();
}

class _GstCalculatorState extends State<GstCalculator> {
  final _a = TextEditingController();
  double _rate = 18;
  String _mode = 'add';
  String _res = '';

  void _calc() {
    final a = double.tryParse(_a.text) ?? 0;
    if (a <= 0) {
      setState(() => _res = '⚠️ Amount daalo');
      return;
    }
    double base, gst, total;
    if (_mode == 'add') {
      gst = a * _rate / 100;
      base = a;
      total = a + gst;
    } else {
      base = a * 100 / (100 + _rate);
      gst = a - base;
      total = a;
    }
    setState(() {
      _res = 'Base: ₹${base.toStringAsFixed(2)}\n'
          'GST ($_rate%): ₹${gst.toStringAsFixed(2)}\n'
          'Total: ₹${total.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GST Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _a,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              value: _rate,
              decoration: const InputDecoration(labelText: 'GST Rate', border: OutlineInputBorder()),
              items: [5.0, 12.0, 18.0, 28.0]
                  .map((r) => DropdownMenuItem(value: r, child: Text('$r%')))
                  .toList(),
              onChanged: (v) => setState(() => _rate = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'Mode', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'add', child: Text('Add GST')),
                DropdownMenuItem(value: 'remove', child: Text('Remove GST')),
              ],
              onChanged: (v) => setState(() => _mode = v!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calc,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Calculate', style: TextStyle(fontSize: 16)),
            ),
            if (_res.isNotEmpty) _resultBox(_res),
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
  final _w = TextEditingController();
  final _h = TextEditingController();
  String _res = '';

  void _calc() {
    final w = double.tryParse(_w.text) ?? 0;
    final h = (double.tryParse(_h.text) ?? 0) / 100;
    if (w <= 0 || h <= 0) {
      setState(() => _res = '⚠️ Weight aur Height daalo');
      return;
    }
    final bmi = w / (h * h);
    String cat;
    if (bmi < 18.5) cat = '🔵 Underweight';
    else if (bmi < 25) cat = '🟢 Normal';
    else if (bmi < 30) cat = '🟡 Overweight';
    else cat = '🔴 Obese';
    setState(() => _res = 'BMI: ${bmi.toStringAsFixed(1)}\nCategory: $cat');
  }

  @override
  Widget build(BuildContext context) {
    return _calcScreen('BMI Calculator', [
      _field('Weight (kg)', _w, '70'),
      _field('Height (cm)', _h, '170'),
    ], _calc, _res);
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
    );
    if (d != null) setState(() => _dob = d);
  }

  void _calc() {
    if (_dob == null) {
      setState(() => _res = '⚠️ DOB select karo');
      return;
    }
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
    final days = now.difference(dob).inDays;
    setState(() {
      _res = 'Age: $y years, $m months, $d days\n'
          'Total Months: ${y * 12 + m}\n'
          'Total Days: $days';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.calendar_today),
              label: Text(_dob == null
                  ? 'Select Date of Birth'
                  : 'DOB: ${_dob!.day}/${_dob!.month}/${_dob!.year}'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calc,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Calculate', style: TextStyle(fontSize: 16)),
            ),
            if (_res.isNotEmpty) _resultBox(_res),
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
  DateTime? _s;
  DateTime? _e;
  String _res = '';

  Future<void> _pick(bool start) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => start ? _s = d : _e = d);
  }

  void _calc() {
    if (_s == null || _e == null) {
      setState(() => _res = '⚠️ Dono dates select karo');
      return;
    }
    final diff = _e!.difference(_s!).inDays.abs();
    setState(() {
      _res = 'Total Days: $diff\n'
          'Weeks: ${diff ~/ 7} weeks ${diff % 7} days\n'
          'Months (approx): ${(diff / 30.44).toStringAsFixed(1)}\n'
          'Years (approx): ${(diff / 365.25).toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pick(true),
              icon: const Icon(Icons.calendar_today),
              label: Text(_s == null
                  ? 'Start Date'
                  : 'Start: ${_s!.day}/${_s!.month}/${_s!.year}'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pick(false),
              icon: const Icon(Icons.calendar_today),
              label: Text(_e == null
                  ? 'End Date'
                  : 'End: ${_e!.day}/${_e!.month}/${_e!.year}'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calc,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Calculate', style: TextStyle(fontSize: 16)),
            ),
            if (_res.isNotEmpty) _resultBox(_res),
          ],
        ),
      ),
    );
  }
}

// ═══════ UNIT CONVERTER ═══════
class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});
  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  String _cat = 'length';
  String _from = 'm';
  String _to = 'km';
  final _val = TextEditingController();
  String _res = '';

  final Map<String, Map<String, double>> _units = {
    'length': {'m': 1, 'km': 1000, 'cm': 0.01, 'mm': 0.001, 'inch': 0.0254, 'ft': 0.3048, 'mile': 1609.34},
    'weight': {'kg': 1, 'g': 0.001, 'mg': 0.000001, 'ton': 1000, 'lb': 0.453592, 'oz': 0.0283495},
  };

  List<String> get _u => _cat == 'temp' ? ['C', 'F', 'K'] : _units[_cat]!.keys.toList();

  void _convert() {
    final v = double.tryParse(_val.text) ?? 0;
    if (v == 0) {
      setState(() => _res = '⚠️ Value daalo');
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
    setState(() => _res = '$v $_from = ${r.toStringAsFixed(4)} $_to');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _cat,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'length', child: Text('Length')),
                DropdownMenuItem(value: 'weight', child: Text('Weight')),
                DropdownMenuItem(value: 'temp', child: Text('Temperature')),
              ],
              onChanged: (v) {
                setState(() {
                  _cat = v!;
                  _from = _u.first;
                  _to = _u.last;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _val,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _from,
                  decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                  items: _u.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _from = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _to,
                  decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                  items: _u.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _to = v!),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Convert', style: TextStyle(fontSize: 16)),
            ),
            if (_res.isNotEmpty) _resultBox(_res),
          ],
        ),
      ),
    );
  }
}

// ═══════ HELPERS ═══════
Widget _field(String label, TextEditingController c, String hint) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Widget _resultBox(String text) {
  return Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.indigo.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.indigo.shade200),
    ),
    child: Text(text, style: const TextStyle(fontSize: 16, height: 1.8)),
  );
}

Widget _calcScreen(String title, List<Widget> fields, VoidCallback onCalc, String res) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...fields,
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: onCalc,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Calculate', style: TextStyle(fontSize: 16)),
          ),
          if (res.isNotEmpty) _resultBox(res),
        ],
      ),
    ),
  );
}
