// lib/utils/app_logger.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:universal_html/html.dart' as html;
import 'package:path/path.dart' as p;

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

  /// Save to internal logs list and store
  static Future<void> _save(String message) async {
    _logs.add(message);

    if (!kIsWeb && _logFile != null) {
      await _logFile!.writeAsString(_logs.join("\n"));
    } else if (kIsWeb) {
      html.window.localStorage['app_logs'] = jsonEncode(_logs);
    }
  }

  /// Debug log
  static Future<void> d(dynamic message) async {
    final msg = "[DEBUG] $message";
    _logger.d(msg);
    await _save(msg);
    await saveActionLog("debug", msg);
  }

  /// Info log
  static Future<void> i(dynamic message) async {
    final msg = "[INFO] $message";
    _logger.i(msg);
    await _save(msg);
    await saveActionLog("info", msg);
  }

  /// Warn log
  static Future<void> w(dynamic message) async {
    final msg = "[WARN] $message";
    _logger.w(msg);
    await _save(msg);
    await saveActionLog("warn", msg);
  }

  /// Error log
  static Future<void> e(dynamic message,
      {dynamic error, StackTrace? stackTrace}) async {
    final msg = "[ERROR] $message";
    _logger.e(msg, error: error, stackTrace: stackTrace);
    await _save(msg);
    await saveActionLog("error", msg);
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

  /// Save each action as separate .txt file (Desktop/Mobile/Web)
  static Future<void> saveActionLog(String actionName, String content) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (!kIsWeb) {
      io.Directory logsDir;

      // Desktop: store in project folder logs/
      if (!kIsWeb &&
          (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS)) {
        final projectDir = io.Directory.current.path;
        logsDir = io.Directory(p.join(projectDir, 'logs'));
      } else {
        // Mobile: store in app documents directory
        final dir = await getApplicationDocumentsDirectory();
        logsDir = io.Directory(dir.path);
      }

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final file = io.File(p.join(logsDir.path, "${actionName}_$timestamp.txt"));
      await file.writeAsString(content);
      print("Saved log file: ${file.path}");
    } else {
      // Web: trigger download
      final blob = html.Blob([content], 'text/plain');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', "${actionName}_$timestamp.txt")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}
