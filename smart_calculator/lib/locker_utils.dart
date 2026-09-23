import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LockerUtils {
  static const String _pinKey = 'locker_pin';
  static const String _notesKey = 'locker_notes';

  // ═══════ PIN MANAGEMENT ═══════
  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey);
    return pin != null && pin.isNotEmpty;
  }

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) == pin;
  }

  static Future<void> changePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
  }

  static Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }

  // ═══════ NOTES MANAGEMENT ═══════
  static Future<List<Map<String, String>>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map<Map<String, String>>((e) {
      return {
        'title': e['title']?.toString() ?? '',
        'content': e['content']?.toString() ?? '',
        'date': e['date']?.toString() ?? '',
      };
    }).toList();
  }

  static Future<void> saveNotes(List<Map<String, String>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesKey, jsonEncode(notes));
  }

  static Future<void> addNote(String title, String content) async {
    final notes = await getNotes();
    notes.insert(0, {
      'title': title,
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });
    await saveNotes(notes);
  }

  static Future<void> updateNote(
      int index, String title, String content) async {
    final notes = await getNotes();
    if (index < 0 || index >= notes.length) return;
    notes[index] = {
      'title': title,
      'content': content,
      'date': DateTime.now().toIso8601String(),
    };
    await saveNotes(notes);
  }

  static Future<void> deleteNote(int index) async {
    final notes = await getNotes();
    if (index < 0 || index >= notes.length) return;
    notes.removeAt(index);
    await saveNotes(notes);
  }
}
