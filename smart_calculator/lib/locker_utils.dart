import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class LockerUtils {
  static const String _pinKey = 'locker_pin';
  static const String _notesKey = 'locker_notes';
  static const String _securityQKey = 'locker_security_q';
  static const String _securityAKey = 'locker_security_a';
  static const String _biometricKey = 'locker_biometric';

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

  // ═══════ SECURITY QUESTION ═══════
  static Future<bool> hasSecurityQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    final q = prefs.getString(_securityQKey);
    return q != null && q.isNotEmpty;
  }

  static Future<void> setSecurityQuestion(
      String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_securityQKey, question);
    await prefs.setString(_securityAKey, answer.toLowerCase().trim());
  }

  static Future<String?> getSecurityQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_securityQKey);
  }

  static Future<bool> verifySecurityAnswer(String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_securityAKey);
    if (stored == null) return false;
    return stored == answer.toLowerCase().trim();
  }

  // ═══════ BIOMETRIC ═══════
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  static Future<void> setBiometric(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }

  // ═══════ RESET ═══════
  static Future<void> resetLocker() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.remove(_notesKey);
    await prefs.remove(_securityQKey);
    await prefs.remove(_securityAKey);
    await prefs.remove(_biometricKey);
  }

  static Future<void> clearNotesOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notesKey);
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

  // ═══════ PHOTO MANAGEMENT ═══════
  static Future<Directory> getPhotosDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hiddenDir = Directory('${appDir.path}/hidden_photos');
    if (!await hiddenDir.exists()) {
      await hiddenDir.create(recursive: true);
    }
    return hiddenDir;
  }

  static Future<List<Map<String, String>>> getPhotos() async {
    try {
      final dir = await getPhotosDir();
      final files = await dir.list().toList();
      final photos = <Map<String, String>>[];
      for (final f in files) {
        if (f is File) {
          final stat = await f.stat();
          photos.add({
            'path': f.path,
            'name': f.path.split('/').last,
            'date': stat.modified.toIso8601String(),
          });
        }
      }
      photos.sort((a, b) => b['date']!.compareTo(a['date']!));
      return photos;
    } catch (e) {
      return [];
    }
  }

  static Future<String?> hidePhoto(String sourcePath) async {
  try {
    final dir = await getPhotosDir();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${sourcePath.split('/').last}';
    final destPath = '${dir.path}/$fileName';

    // Step 1: Copy to app private folder
    await File(sourcePath).copy(destPath);

    // Step 2: Delete using MediaStore (works Android 10+)
    try {
      final mediaStore = MediaStore();
      await mediaStore.ensureInitialized();
      await mediaStore.deleteFile(sourcePath);
    } catch (e) {
      // Fallback: direct delete
      try {
        final original = File(sourcePath);
        if (await original.exists()) {
          await original.delete();
        }
      } catch (e2) {
        // Silent fail
      }
    }

    return destPath;
  } catch (e) {
    return null;
  }
  }

  static Future<void> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // silent
    }
  }
}
