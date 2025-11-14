// 日志查看器组件
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bili_own/common/utils/log_utils.dart'; // 添加日志工具导入

class LogViewer extends StatefulWidget {
  const LogViewer({Key? key}) : super(key: key);

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  List<String> _logs = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  // 加载日志
  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 使用我们的日志工具获取日志
      final logs = await LogUtils().getLogs();
      setState(() {
        _logs = logs;
      });
    } catch (e) {
      setState(() {
        _logs = ['加载日志失败: $e'];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 刷新日志
  Future<void> _refreshLogs() async {
    await _loadLogs();
    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 复制日志到剪贴板
  void _copyLogsToClipboard() {
    final logText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日志已复制到剪贴板')),
    );
  }

  // 导出日志到文件
  Future<void> _exportLogs() async {
    try {
      // 请求存储权限
      final status = await Permission.storage.request();
      if (status.isGranted) {
        // 获取外部存储目录
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final logFile = File('${directory.path}/bili_own_logs.txt');
          final logText = _logs.join('\n');
          await logFile.writeAsString(logText);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('日志已导出到: ${logFile.path}')),
          );
        } else {
          // 备用方案：使用文档目录
          final docDirectory = await getApplicationDocumentsDirectory();
          final logFile = File('${docDirectory.path}/bili_own_logs.txt');
          final logText = _logs.join('\n');
          await logFile.writeAsString(logText);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('日志已导出到: ${logFile.path}')),
          );
        }
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要存储权限才能导出日志')),
        );
        // 打开应用设置
        await openAppSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('存储权限被拒绝')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出日志失败: $e')),
      );
    }
  }

  // 清空日志
  Future<void> _clearLogs() async {
    try {
      await LogUtils().clearLogs();
      setState(() {
        _logs = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日志已清空')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('清空日志失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志查看器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLogs,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogsToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _exportLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('暂无日志'))
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return ListTile(
                      title: Text(
                        log,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    );
                  },
                ),
    );
  }
}