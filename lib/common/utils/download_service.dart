import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bili_own/common/utils/download_manager.dart';
import 'package:bili_own/common/models/local/download/download_entry_info.dart';
import 'package:bili_own/common/models/local/download/download_media_file_info.dart';
import 'package:bili_own/common/models/local/download/current_download_info.dart';
import 'package:bili_own/common/models/local/download/bili_download_entry_info.dart';
import 'package:bili_own/common/api/video_play_api.dart';
import 'package:bili_own/common/utils/bili_own_storage.dart';
import 'package:bili_own/common/utils/permission_utils.dart';
import 'package:bili_own/common/utils/nomedia_utils.dart';

// 下载条目和路径信息
class DownloadEntryAndPathInfo {
  DownloadEntryAndPathInfo({
    required this.pageDirPath,
    required this.entryDirPath,
    required this.entry,
  });

  final String pageDirPath;
  final String entryDirPath;
  final DownloadEntryInfo entry;
}

// 下载服务
class DownloadService extends GetxController implements DownloadCallback {
  static DownloadService get instance => Get.find<DownloadService>();

  final List<DownloadEntryAndPathInfo> downloadList = <DownloadEntryAndPathInfo>[];
  final List<DownloadEntryAndPathInfo> waitDownloadQueue = <DownloadEntryAndPathInfo>[];
  final Rx<CurrentDownloadInfo?> curDownload = Rx<CurrentDownloadInfo?>(null);
  DownloadManager? _downloadManager;
  DownloadManager? _audioDownloadManager;
  int _currentTaskId = 1;
  int _idCounter = 1;
  bool _isPaused = false; // 添加暂停状态标志

  @override
  void onInit() {
    super.onInit();
    _readDownloadList();
    // 为所有现有的下载目录添加.noMedia文件
    NoMediaUtils.addNoMediaToAllDownloadDirs();
  }

  // 读取下载列表
  void _readDownloadList() async {
    // 检查并请求存储权限
    final hasPermission = await PermissionUtils.requestStoragePermission();
    if (!hasPermission) {
      print("存储权限被拒绝，无法读取下载列表");
      return;
    }
    
    final downloadPath = await _getDownloadPath();
    final downloadDir = Directory(downloadPath);
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
      return;
    }

    final list = <DownloadEntryAndPathInfo>[];
    downloadDir.listSync().whereType<Directory>().forEach((dir) {
      list.addAll(_readDownloadDirectory(dir));
    });

    downloadList.clear();
    downloadList.addAll(list.reversed);
  }

  // 读取下载目录
  List<DownloadEntryAndPathInfo> _readDownloadDirectory(Directory dir) {
    if (!dir.existsSync()) {
      return [];
    }

    final list = <DownloadEntryAndPathInfo>[];
    dir.listSync().whereType<Directory>().forEach((pageDir) {
      final entryFile = File(path.join(pageDir.path, "entry.json"));
      if (entryFile.existsSync()) {
        try {
          final entryJson = entryFile.readAsStringSync();
          final entryMap = json.decode(entryJson);
          // 简化处理，实际应根据entry.json结构创建DownloadEntryInfo对象
          // 这里仅作示例
          final entry = DownloadEntryInfo(
            mediaType: entryMap['media_type'] ?? 1,
            hasDashAudio: entryMap['has_dash_audio'] ?? false,
            isCompleted: entryMap['is_completed'] ?? false,
            totalBytes: entryMap['total_bytes'] ?? 0,
            downloadedBytes: entryMap['downloaded_bytes'] ?? 0,
            title: entryMap['title'] ?? '',
            typeTag: entryMap['type_tag'],
            cover: entryMap['cover'] ?? '',
            preferedVideoQuality: entryMap['prefered_video_quality'] ?? 0,
            qualityPithyDescription: entryMap['quality_pithy_description'] ?? '',
            guessedTotalBytes: entryMap['guessed_total_bytes'] ?? 0,
            totalTimeMilli: entryMap['total_time_milli'] ?? 0,
            danmakuCount: entryMap['danmaku_count'] ?? 0,
            timeUpdateStamp: entryMap['time_update_stamp'] ?? 0,
            timeCreateStamp: entryMap['time_create_stamp'] ?? 0,
            canPlayInAdvance: entryMap['can_play_in_advance'] ?? false,
            interruptTransformTempFile: entryMap['interrupt_transform_temp_file'] ?? false,
            avid: entryMap['avid'] is int ? entryMap['avid'] : null,
            spid: entryMap['spid'] is int ? entryMap['spid'] : null,
            bvid: entryMap['bvid'] is String ? entryMap['bvid'] : null,
            ownerId: entryMap['owner_id'] is int ? entryMap['owner_id'] : null,
          );
          
          list.add(DownloadEntryAndPathInfo(
            pageDirPath: pageDir.path,
            entryDirPath: pageDir.path,
            entry: entry,
          ));
        } catch (e) {
          print("读取下载条目失败: $e");
        }
      }
    });

    return list;
  }

  // 获取下载路径
  Future<String> _getDownloadPath() async {
    // 使用应用私有目录
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, "downloads");
  }

  // 获取下载文件目录
  Future<Directory> _getDownloadFileDir(DownloadEntryInfo entry) async {
    final downloadPath = await _getDownloadPath();
    final entryDir = Directory(path.join(downloadPath, entry.avid?.toString() ?? "unknown"));
    if (!entryDir.existsSync()) {
      entryDir.createSync(recursive: true);
    }
    return entryDir;
  }

  @override
  void onTaskRunning(CurrentDownloadInfo info) {
    // 更新当前下载信息
    curDownload.value = info;
  }

  @override
  void onTaskComplete(CurrentDownloadInfo info) {
    // 下载完成，清空当前下载信息
    curDownload.value = null;
  }

  @override
  void onTaskError(CurrentDownloadInfo info, Object error) {
    // 下载出错，清空当前下载信息
    curDownload.value = null;
  }

  // 暂停下载
  void pauseDownload() {
    _isPaused = true;
    if (_downloadManager != null) {
      _downloadManager!.pauseDownload(_currentTaskId.toString());
    }
    if (_audioDownloadManager != null) {
      _audioDownloadManager!.pauseDownload(_currentTaskId.toString());
    }
  }

  // 恢复下载
  void resumeDownload() {
    _isPaused = false;
    // 实际恢复下载的逻辑需要根据具体实现来处理
  }

  // 取消下载
  void cancelDownload() {
    if (_downloadManager != null) {
      _downloadManager!.cancelDownload(_currentTaskId.toString());
    }
    if (_audioDownloadManager != null) {
      _audioDownloadManager!.cancelDownload(_currentTaskId.toString());
    }
    curDownload.value = null;
  }
}