import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

class AppLogger {
  static List<String> _logs = [];
  static io.File? _logFile;

  /// Set your server URL here
  static const String serverBaseUrl = "http://localhost:8080";

  /// ---------------------------
  /// INIT
  /// ---------------------------
  static Future<void> init() async {
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = io.File("${dir.path}/app_log.txt");

      if (await _logFile!.exists()) {
        final content = await _logFile!.readAsString();
        _logs = content.split("\n");
      } else {
        await _logFile!.create();
      }
      print("AppLogger initialized on Mobile/Desktop");
    } else {
      final stored = html.window.localStorage['app_logs'];
      if (stored != null) {
        _logs = List<String>.from(jsonDecode(stored));
      }
      // No print on Web
    }
  }

  /// ---------------------------
  /// SAVE LOG LOCALLY
  /// ---------------------------
  static Future<void> _save(String message) async {
    _logs.add(message);

    if (!kIsWeb && _logFile != null) {
      await _logFile!.writeAsString(_logs.join("\n"));
    } else if (kIsWeb) {
      html.window.localStorage['app_logs'] = jsonEncode(_logs);
    }
  }

  /// ---------------------------
  /// PUBLIC LOG METHODS
  /// ---------------------------
  static Future<void> d(dynamic message) async {
    final msg = "[DEBUG] $message";

    // Only console on Mobile/Desktop
    if (!kIsWeb) print(msg);

    await _save(msg);
    await _sendToServer("debug", msg);
  }

  static Future<void> i(dynamic message) async {
    final msg = "[INFO] $message";

    if (!kIsWeb) print(msg);

    await _save(msg);
    await _sendToServer("info", msg);
  }

  static Future<void> w(dynamic message) async {
    final msg = "[WARN] $message";

    if (!kIsWeb) print(msg);

    await _save(msg);
    await _sendToServer("warn", msg);
  }

  static Future<void> e(dynamic message,
      {dynamic error, StackTrace? stackTrace}) async {
    final msg = "[ERROR] $message";

    if (!kIsWeb) print(msg);

    await _save(msg);
    await _sendToServer("error", msg);
  }

  /// ---------------------------
  /// GET / EXPORT LOGS
  /// ---------------------------
  static List<String> getStoredLogs() => _logs;
  static String exportLogs() => _logs.join("\n");

  static void downloadLogs(String fileName) {
    if (!kIsWeb) return;

    final blob = html.Blob([exportLogs()], 'text/plain', 'native');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// ---------------------------
  /// SAVE TO LOCAL FILE (Desktop/Mobile)
  /// ---------------------------
  static Future<void> _saveToLocalFile(String actionName, String content) async {
    io.Directory logsDir;

    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      final projectDir = io.Directory.current.path;
      logsDir = io.Directory(p.join(projectDir, 'logs'));
    } else {
      final dir = await getApplicationDocumentsDirectory();
      logsDir = io.Directory(dir.path);
    }

    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = io.File(p.join(logsDir.path, "${actionName}_$timestamp.txt"));
    await file.writeAsString(content);

    if (!kIsWeb) print("Saved log file: ${file.path}");
  }

  /// ---------------------------
  /// SEND LOG TO SERVER (WEB ONLY)
  /// ---------------------------
  static Future<void> _sendToServer(String action, String content) async {
    if (!kIsWeb) {
      await _saveToLocalFile(action, content);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$serverBaseUrl/logs"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": action,
          "content": content,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      // No print on Web
    } catch (_) {
      // Silently ignore network errors on Web
    }
  }
}
