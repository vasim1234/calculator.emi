import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'locker_utils.dart';

const kBg2 = Color(0xFF000000);
const kCardL = Color(0xFF1A1A1A);
const kCard2L = Color(0xFF262626);
const kRedL = Color(0xFFE63946);
const kTextWhiteL = Color(0xFFFFFFFF);
const kTextGreyL = Color(0xFF9B9B9B);

// ═══════ MAIN LOCKER SCREEN ═══════
class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});
  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  bool _unlocked = false;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final has = await LockerUtils.hasPin();
    setState(() => _hasPin = has);
    if (!has) {
      // No PIN → show setup
      _unlocked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPin) {
      return PinSetupScreen(onComplete: () {
        setState(() {
          _hasPin = true;
          _unlocked = true;
        });
      });
    }
    if (!_unlocked) {
      return PinEntryScreen(onSuccess: () {
        setState(() => _unlocked = true);
      });
    }
    return const NotesListScreen();
  }
}

// ═══════ PIN SETUP (First Time) ═══════
class PinSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const PinSetupScreen({super.key, required this.onComplete});
  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;

  void _onKey(String v) {
    setState(() {
      if (_confirming) {
        if (_confirmPin.length < 4) _confirmPin += v;
      } else {
        if (_pin.length < 4) _pin += v;
      }

      if (!_confirming && _pin.length == 4) {
        setState(() => _confirming = true);
      } else if (_confirming && _confirmPin.length == 4) {
        _verifyAndSave();
      }
    });
  }

  void _verifyAndSave() async {
    if (_pin == _confirmPin) {
      await LockerUtils.setPin(_pin);
      if (mounted) widget.onComplete();
    } else {
      setState(() {
        _pin = '';
        _confirmPin = '';
        _confirming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIN match nahi hua, dobara try karo',
              style: GoogleFonts.poppins()),
          backgroundColor: kRedL,
        ),
      );
    }
  }

  void _backspace() {
    setState(() {
      if (_confirming) {
        if (_confirmPin.isNotEmpty)
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirmPin : _pin;
    return Scaffold(
      backgroundColor: kBg2,
      appBar: AppBar(
        backgroundColor: kBg2,
        title: Text('Setup PIN',
            style: GoogleFonts.poppins(color: kTextWhiteL)),
        iconTheme: const IconThemeData(color: kTextWhiteL),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            _confirming ? 'Confirm PIN' : 'Set 4-digit PIN',
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextWhiteL),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current.length ? kRedL : kCard2L,
                  border: Border.all(color: kRedL.withValues(alpha: 0.5)),
                ),
              );
            }),
          ),
          const SizedBox(height: 60),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _keyRow(['1', '2', '3']),
            _keyRow(['4', '5', '6']),
            _keyRow(['7', '8', '9']),
            _keyRow(['⌫', '0', '']),
          ],
        ),
      ),
    );
  }

  Widget _keyRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((k) {
          if (k.isEmpty) return const Expanded(child: SizedBox());
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: kCardL,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (k == '⌫') {
                      _backspace();
                    } else {
                      _onKey(k);
                    }
                  },
                  child: Center(
                    child: Text(k,
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: kTextWhiteL)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════ PIN ENTRY (Every Time) ═══════
class PinEntryScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const PinEntryScreen({super.key, required this.onSuccess});
  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = '';

  void _onKey(String v) {
    setState(() {
      if (_pin.length < 4) _pin += v;
      if (_pin.length == 4) _verify();
    });
  }

  void _verify() async {
    final ok = await LockerUtils.verifyPin(_pin);
    if (ok) {
      widget.onSuccess();
    } else {
      setState(() => _pin = '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Galat PIN', style: GoogleFonts.poppins()),
          backgroundColor: kRedL,
        ),
      );
    }
  }

  void _backspace() {
    setState(() {
      if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      appBar: AppBar(
        backgroundColor: kBg2,
        title: Text('Enter PIN',
            style: GoogleFonts.poppins(color: kTextWhiteL)),
        iconTheme: const IconThemeData(color: kTextWhiteL),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.lock, color: kRedL, size: 60),
          const SizedBox(height: 20),
          Text('Enter your 4-digit PIN',
              style: GoogleFonts.poppins(
                  fontSize: 18, color: kTextWhiteL)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? kRedL : kCard2L,
                  border: Border.all(color: kRedL.withValues(alpha: 0.5)),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _keyRow(['1', '2', '3']),
            _keyRow(['4', '5', '6']),
            _keyRow(['7', '8', '9']),
            _keyRow(['⌫', '0', '']),
          ],
        ),
      ),
    );
  }

  Widget _keyRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((k) {
          if (k.isEmpty) return const Expanded(child: SizedBox());
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: kCardL,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (k == '⌫') {
                      _backspace();
                    } else {
                      _onKey(k);
                    }
                  },
                  child: Center(
                    child: Text(k,
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: kTextWhiteL)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════ NOTES LIST ═══════
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});
  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Map<String, String>> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await LockerUtils.getNotes();
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _addOrEdit({int? index}) async {
    final isEdit = index != null;
    final titleCtrl = TextEditingController(
        text: isEdit ? _notes[index]['title'] : '');
    final contentCtrl = TextEditingController(
        text: isEdit ? _notes[index]['content'] : '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardL,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit Note' : 'New Note',
            style: GoogleFonts.poppins(
                color: kTextWhiteL, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: GoogleFonts.poppins(color: kTextWhiteL),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: GoogleFonts.poppins(color: kTextGreyL),
                filled: true,
                fillColor: kCard2L,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 5,
              style: GoogleFonts.poppins(color: kTextWhiteL),
              decoration: InputDecoration(
                hintText: 'Note...',
                hintStyle: GoogleFonts.poppins(color: kTextGreyL),
                filled: true,
                fillColor: kCard2L,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: kTextGreyL)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRedL),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Save',
                style: GoogleFonts.poppins(color: kTextWhiteL)),
          ),
        ],
      ),
    );

    if (result == true) {
      final title = titleCtrl.text.trim();
      final content = contentCtrl.text.trim();
      if (title.isEmpty && content.isEmpty) return;
      if (isEdit) {
        await LockerUtils.updateNote(index, title, content);
      } else {
        await LockerUtils.addNote(title, content);
      }
      _load();
    }
  }

  Future<void> _delete(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardL,
        title: Text('Delete?',
            style: GoogleFonts.poppins(color: kTextWhiteL)),
        content: Text('Yeh note delete ho jayega.',
            style: GoogleFonts.poppins(color: kTextGreyL)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: kTextGreyL)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRedL),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: kTextWhiteL)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await LockerUtils.deleteNote(index);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg2,
      appBar: AppBar(
        backgroundColor: kBg2,
        title: Text('Private Notes',
            style: GoogleFonts.poppins(color: kTextWhiteL)),
        iconTheme: const IconThemeData(color: kTextWhiteL),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kRedL,
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add, color: kTextWhiteL),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kRedL))
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 80, color: kCard2L),
                      const SizedBox(height: 16),
                      Text('Koi notes nahi',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: kTextGreyL)),
                      const SizedBox(height: 8),
                      Text('+ dabao naya note banane ke liye',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: kTextGreyL)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (ctx, i) {
                    final n = _notes[i];
                    return Card(
                      color: kCardL,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          n['title']!.isEmpty ? '(No title)' : n['title']!,
                          style: GoogleFonts.poppins(
                              color: kTextWhiteL,
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                        subtitle: Text(
                          n['content']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              color: kTextGreyL, fontSize: 13),
                        ),
                        trailing: PopupMenuButton<String>(
                          color: kCard2L,
                          icon: const Icon(Icons.more_vert,
                              color: kTextGreyL),
                          onSelected: (v) {
                            if (v == 'edit') _addOrEdit(index: i);
                            if (v == 'delete') _delete(i);
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit',
                                  style: GoogleFonts.poppins(
                                      color: kTextWhiteL)),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete',
                                  style: GoogleFonts.poppins(
                                      color: kRedL)),
                            ),
                          ],
                        ),
                        onTap: () => _addOrEdit(index: i),
                      ),
                    );
                  },
                ),
    );
  }
}
