import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/local/download/bili_download_entry_info.dart';
import '../models/local/download/bili_download_media_file_info.dart';
import '../models/local/download/current_download_info.dart';

// 下载回调接口
abstract class DownloadCallback {
  void onTaskRunning(CurrentDownloadInfo info);
  void onTaskComplete(CurrentDownloadInfo info);
  void onTaskError(CurrentDownloadInfo info, Object error);
}

class DownloadManager {
  // 添加downloadInfo字段
  late CurrentDownloadInfo downloadInfo;
  late DownloadCallback callback;
  final Dio _dio = Dio();
  final Map<String, StreamController<double>> _progressControllers = {};
  final Map<String, CancelToken> _cancelTokens = {};

  // 添加构造函数
  DownloadManager.withParams({
    required this.downloadInfo,
    required this.callback,
  });

  // 添加start方法
  void start(File file) {
    // 启动下载任务
    _downloadFile(file);
  }

  // 下载文件
  Future<void> _downloadFile(File file) async {
    try {
      // 设置下载状态
      downloadInfo = downloadInfo.copyWith(status: CurrentDownloadInfo.STATUS_DOWNLOADING);
      callback.onTaskRunning(downloadInfo);

      // 创建Dio实例并配置
      final dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 120);
      dio.options.receiveTimeout = Duration(seconds: 120);

      // 设置请求头
      if (downloadInfo.header != null) {
        dio.options.headers.addAll(downloadInfo.header!);
      }

      // 检查文件是否已存在
      var downloadLength = 0;
      if (file.existsSync()) {
        if (downloadInfo.size == 0) {
          file.deleteSync();
        } else {
          downloadLength = file.lengthSync();
          downloadInfo = downloadInfo.copyWith(progress: downloadLength);
        }
      }

      // 设置Range请求头以支持断点续传
      if (downloadLength > 0 && downloadInfo.size != 0) {
        if (downloadInfo.size == downloadLength) {
          // 文件已下载完成
          downloadInfo = downloadInfo.copyWith(status: CurrentDownloadInfo.STATUS_COMPLETED);
          callback.onTaskComplete(downloadInfo);
          return;
        }
        dio.options.headers['Range'] = 'bytes=$downloadLength-${downloadInfo.size}';
      }

      // 创建取消令牌
      final cancelToken = CancelToken();

      // 执行下载
      await dio.download(
        downloadInfo.url,
        file.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // 更新下载进度
            final progress = downloadLength + received;
            downloadInfo = downloadInfo.copyWith(
              progress: progress,
              size: downloadInfo.size == 0 ? total : downloadInfo.size,
            );
            callback.onTaskRunning(downloadInfo);
          }
        },
      );

      // 下载完成
      downloadInfo = downloadInfo.copyWith(
        status: CurrentDownloadInfo.STATUS_COMPLETED,
        progress: file.lengthSync(),
      );
      callback.onTaskComplete(downloadInfo);
    } catch (e) {
      // 下载出错
      downloadInfo = downloadInfo.copyWith(status: CurrentDownloadInfo.STATUS_FAIL_DOWNLOAD);
      callback.onTaskError(downloadInfo, e);
    }
  }

  // 下载视频
  Future<void> downloadVideo(
    BiliDownloadEntryInfo entryInfo,
    List<BiliDownloadMediaFileInfo> mediaFiles,
  ) async {
    // 创建当前下载信息
    final currentDownloadInfo = CurrentDownloadInfo(
      entryInfo: entryInfo,
      mediaFiles: mediaFiles,
    );

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
      await _downloadMediaFile(mediaFile, videoDir, currentDownloadInfo);
    }
  }

  // 下载单个媒体文件
  Future<void> _downloadMediaFile(
    BiliDownloadMediaFileInfo mediaFile,
    String saveDir,
    CurrentDownloadInfo currentDownloadInfo,
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
  
  // 添加cancel方法以解决原始问题
  void cancel() {
    // 取消当前下载任务
    if (downloadInfo.taskId != 0) {
      cancelDownload(downloadInfo.taskId.toString());
    }
  }
}