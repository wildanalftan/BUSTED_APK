import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static bool _useFileFallback = false;
  static File? _fallbackFile;

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      // Test read to see if secure storage works
      await _storage.read(key: 'test_connection');
    } catch (e) {
      _useFileFallback = true;
      debugPrint('Secure storage failed, falling back to file persistence: $e');
    }

    if (_useFileFallback || Platform.isWindows) {
      // Force file fallback on Windows if secure storage fails,
      // or proactively use it for simpler, cross-process transparent database viewing.
      _useFileFallback = true;
      try {
        final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
        final dir = Directory('$userProfile/.bustedworld');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        _fallbackFile = File('${dir.path}/db.json');
        if (!await _fallbackFile!.exists()) {
          await _fallbackFile!.writeAsString(jsonEncode({}));
        }
      } catch (ex) {
        debugPrint('Fallback file creation failed: $ex');
      }
    }
  }

  static Future<String?> read(String key) async {
    if (_useFileFallback && _fallbackFile != null) {
      try {
        if (!await _fallbackFile!.exists()) return null;
        final content = await _fallbackFile!.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        return map[key] as String?;
      } catch (e) {
        debugPrint('Failed to read from fallback storage: $e');
        return null;
      }
    }
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('Failed to read from secure storage: $e');
      return null;
    }
  }

  static Future<void> write(String key, String value) async {
    if (_useFileFallback && _fallbackFile != null) {
      try {
        Map<String, dynamic> map = {};
        if (await _fallbackFile!.exists()) {
          final content = await _fallbackFile!.readAsString();
          if (content.isNotEmpty) {
            map = jsonDecode(content) as Map<String, dynamic>;
          }
        }
        map[key] = value;
        await _fallbackFile!.writeAsString(jsonEncode(map));
      } catch (e) {
        debugPrint('Failed to write to fallback storage: $e');
      }
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Failed to write to secure storage: $e');
    }
  }

  static Future<void> delete(String key) async {
    if (_useFileFallback && _fallbackFile != null) {
      try {
        if (await _fallbackFile!.exists()) {
          final content = await _fallbackFile!.readAsString();
          final map = jsonDecode(content) as Map<String, dynamic>;
          map.remove(key);
          await _fallbackFile!.writeAsString(jsonEncode(map));
        }
      } catch (e) {
        debugPrint('Failed to delete from fallback storage: $e');
      }
      return;
    }
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Failed to delete from secure storage: $e');
    }
  }

  static Future<void> clearAll() async {
    if (_useFileFallback && _fallbackFile != null) {
      try {
        await _fallbackFile!.writeAsString(jsonEncode({}));
      } catch (e) {
        debugPrint('Failed to clear fallback storage: $e');
      }
      return;
    }
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Failed to clear secure storage: $e');
    }
  }
}
