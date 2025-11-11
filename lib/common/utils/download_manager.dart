import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/local/download/bili_download_entry_info.dart';
import '../models/local/download/bili_download_media_file_info.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Dio _dio = Dio();
  final Map<String, StreamController<double>> _progressControllers = {};
  final Map<String, CancelToken> _cancelTokens = {};

  // 下载视频
  Future<void> downloadVideo(
    BiliDownloadEntryInfo entryInfo,
    List<BiliDownloadMediaFileInfo> mediaFiles,
  ) async {
    // 创建下载目录
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String downloadDir = path.join(appDir.path, 'downloads');
    await Directory(downloadDir).create(recursive: true);

    // 更新下载信息
    final String taskId = entryInfo.taskId;
    final String videoDir = path.join(downloadDir, taskId);
    await Directory(videoDir).create(recursive: true);

    // 下载所有媒体文件
    for (var mediaFile in mediaFiles) {
      await _downloadMediaFile(mediaFile, videoDir);
    }
  }

  // 下载单个媒体文件
  Future<void> _downloadMediaFile(
    BiliDownloadMediaFileInfo mediaFile,
    String saveDir,
  ) async {
    final String taskId = mediaFile.taskId;
    final String fileName = '$taskId.mp4';
    final String savePath = path.join(saveDir, fileName);

    // 创建进度控制器
    _progressControllers[taskId] = StreamController<double>();
    _cancelTokens[taskId] = CancelToken();

    try {
      await _dio.download(
        mediaFile.downloadUrl,
        savePath,
        cancelToken: _cancelTokens[taskId],
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _progressControllers[taskId]?.add(progress);
          }
        },
      );
    } catch (e) {
      // 处理下载错误
      rethrow;
    } finally {
      // 清理资源
      await _progressControllers[taskId]?.close();
      _progressControllers.remove(taskId);
      _cancelTokens.remove(taskId);
    }
  }

  // 获取下载进度流
  Stream<double>? getDownloadProgress(String taskId) {
    return _progressControllers[taskId]?.stream;
  }

  // 暂停下载
  void pauseDownload(String taskId) {
    _cancelTokens[taskId]?.cancel();
  }

  // 取消下载
  void cancelDownload(String taskId) {
    _cancelTokens[taskId]?.cancel();
  }
}