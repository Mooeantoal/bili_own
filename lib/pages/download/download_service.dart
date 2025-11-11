import 'dart:async';
import 'package:get/get.dart';
import '../../common/utils/download_manager.dart';
import '../../common/models/local/download/bili_download_entry_info.dart';
import '../../common/models/local/download/bili_download_media_file_info.dart';

class DownloadService extends GetxController {
  static DownloadService get to => Get.find();

  final DownloadManager _downloadManager = DownloadManager();
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  final List<BiliDownloadEntryInfo> _downloadList = <BiliDownloadEntryInfo>[].obs;

  // 下载列表
  List<BiliDownloadEntryInfo> get downloadList => _downloadList;

  // 下载进度
  double getDownloadProgress(String taskId) {
    return _downloadProgress[taskId] ?? 0.0;
  }

  // 是否正在下载
  bool isDownloading(String taskId) {
    return _isDownloading[taskId] ?? false;
  }

  // 添加到下载队列
  Future<void> addToDownloadQueue(
    BiliDownloadEntryInfo entryInfo,
    List<BiliDownloadMediaFileInfo> mediaFiles,
  ) async {
    // 添加到下载列表
    _downloadList.add(entryInfo);
    _isDownloading[entryInfo.taskId] = true;
    update();

    // 监听下载进度
    final progressStream = _downloadManager.getDownloadProgress(entryInfo.taskId);
    if (progressStream != null) {
      progressStream.listen((progress) {
        _downloadProgress[entryInfo.taskId] = progress;
        update();
      });
    }

    // 开始下载
    try {
      await _downloadManager.downloadVideo(entryInfo, mediaFiles);
      // 下载完成
      _isDownloading[entryInfo.taskId] = false;
      update();
    } catch (e) {
      // 下载失败
      _isDownloading[entryInfo.taskId] = false;
      update();
      rethrow;
    }
  }

  // 暂停下载
  void pauseDownload(String taskId) {
    _downloadManager.pauseDownload(taskId);
    _isDownloading[taskId] = false;
    update();
  }

  // 取消下载
  void cancelDownload(String taskId) {
    _downloadManager.cancelDownload(taskId);
    _isDownloading[taskId] = false;
    _downloadProgress.remove(taskId);
    // 从下载列表中移除
    _downloadList.removeWhere((element) => element.taskId == taskId);
    update();
  }
}