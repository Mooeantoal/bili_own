// 日志工具类，用于将日志同时输出到控制台和文件
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class LogUtils {
  static final LogUtils _instance = LogUtils._internal();
  factory LogUtils() => _instance;
  LogUtils._internal();

  File? _logFile;
  IOSink? _logSink;
  bool _initialized = false;

  // 初始化日志系统
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logPath = '${directory.path}/app.log';
      _logFile = File(logPath);
      
      // 如果文件不存在，创建它
      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }
      
      // 创建文件写入流
      _logSink = _logFile!.openWrite(mode: FileMode.writeOnlyAppend);
      _initialized = true;
    } catch (e) {
      // 如果初始化失败，不影响应用正常运行
      debugPrint('日志系统初始化失败: $e');
    }
  }

  // 记录日志
  void log(String message, {DateTime? time}) {
    final now = time ?? DateTime.now();
    final formattedTime = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
    
    final logMessage = '[$formattedTime] $message\n';
    
    // 输出到控制台
    debugPrint(logMessage);
    
    // 写入文件
    if (_initialized && _logSink != null) {
      _logSink!.write(logMessage);
      // 立即刷新到文件
      _logSink!.flush();
    }
  }

  // 获取日志文件路径
  Future<String?> getLogFilePath() async {
    if (!_initialized) return null;
    return _logFile?.path;
  }

  // 获取日志内容
  Future<List<String>> getLogs() async {
    if (!_initialized || _logFile == null) return [];
    
    try {
      if (await _logFile!.exists()) {
        final content = await _logFile!.readAsString();
        // 按行分割，过滤空行，并反转顺序（最新的在前面）
        final lines = content.split('\n').reversed.where((line) => line.isNotEmpty).toList();
        return lines;
      }
    } catch (e) {
      debugPrint('读取日志文件失败: $e');
    }
    
    return [];
  }

  // 清空日志
  Future<void> clearLogs() async {
    if (!_initialized || _logFile == null) return;
    
    try {
      await _logSink?.flush();
      await _logSink?.close();
      await _logFile!.writeAsString('');
      _logSink = _logFile!.openWrite(mode: FileMode.writeOnlyAppend);
    } catch (e) {
      debugPrint('清空日志文件失败: $e');
    }
  }

  // 关闭日志系统
  Future<void> close() async {
    await _logSink?.flush();
    await _logSink?.close();
    _initialized = false;
  }
}

// 全局日志函数
void appLog(String message) {
  LogUtils().log(message);
}