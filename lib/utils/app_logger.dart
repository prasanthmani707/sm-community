// lib/utils/app_logger.dart
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:universal_html/html.dart' as html;

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 3,
      lineLength: 120,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static List<String> _logs = [];
  static io.File? _logFile;

  /// Initialize AppLogger
  static Future<void> init() async {
    if (!kIsWeb) {
      // Mobile / Desktop
      final dir = await getApplicationDocumentsDirectory();
      _logFile = io.File("${dir.path}/app_log.txt");

      if (await _logFile!.exists()) {
        final content = await _logFile!.readAsString();
        _logs = content.split("\n");
      } else {
        await _logFile!.create();
      }
    } else {
      // Web: load from LocalStorage
      final stored = html.window.localStorage['app_logs'];
      if (stored != null) {
        _logs = List<String>.from(jsonDecode(stored));
      }
    }
  }

  static Future<void> _save(String message) async {
    _logs.add(message);

    if (!kIsWeb && _logFile != null) {
      await _logFile!.writeAsString(_logs.join("\n"));
    } else if (kIsWeb) {
      html.window.localStorage['app_logs'] = jsonEncode(_logs);
    }
  }

  static Future<void> d(dynamic message) async {
    final msg = "[DEBUG] $message";
    _logger.d(msg);
    await _save(msg);
  }

  static Future<void> i(dynamic message) async {
    final msg = "[INFO] $message";
    _logger.i(msg);
    await _save(msg);
  }

  static Future<void> w(dynamic message) async {
    final msg = "[WARN] $message";
    _logger.w(msg);
    await _save(msg);
  }

  static Future<void> e(dynamic message, {dynamic error, StackTrace? stackTrace}) async {
    final msg = "[ERROR] $message";
    _logger.e(msg, error: error, stackTrace: stackTrace);
    await _save(msg);
  }

  /// Get all stored logs
  static List<String> getStoredLogs() => _logs;

  /// Export logs as single string
  static String exportLogs() => _logs.join("\n");

  /// Download logs as .txt (Web only)
  static void downloadLogs(String fileName) {
    if (!kIsWeb) return;

    final blob = html.Blob([exportLogs()], 'text/plain', 'native');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}