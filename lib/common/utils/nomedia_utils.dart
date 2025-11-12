import 'dart:io';
import 'package:path/path.dart' as path;

class NoMediaUtils {
  /// 确保目录及其所有子目录都有.noMedia文件
  static void ensureNoMediaInDirectory(Directory directory) {
    if (!directory.existsSync()) {
      return;
    }

    // 在当前目录创建.noMedia文件
    _createNoMediaFile(directory);

    // 递归处理所有子目录
    directory.listSync().whereType<Directory>().forEach((subDir) {
      ensureNoMediaInDirectory(subDir);
    });
  }

  /// 在指定目录创建.noMedia文件
  static void _createNoMediaFile(Directory directory) {
    final noMediaFile = File(path.join(directory.path, ".nomedia"));
    if (!noMediaFile.existsSync()) {
      noMediaFile.createSync();
    }
  }

  /// 为所有现有的下载目录添加.noMedia文件
  static void addNoMediaToAllDownloadDirs() {
    final downloadDir = Directory("/storage/emulated/0/Download/Biliown");
    if (downloadDir.existsSync()) {
      ensureNoMediaInDirectory(downloadDir);
    }
  }
}