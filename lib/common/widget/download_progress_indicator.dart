import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/models/local/download/current_download_info.dart';

class DownloadProgressIndicator extends StatelessWidget {
  final Rx<CurrentDownloadInfo?> downloadInfo;
  final VoidCallback? onCancel;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const DownloadProgressIndicator({
    Key? key,
    required this.downloadInfo,
    this.onCancel,
    this.onPause,
    this.onResume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final info = downloadInfo.value;
      if (info == null) {
        return const SizedBox.shrink();
      }

      final progress = info.size > 0 ? info.progress / info.size : 0.0;
      final percentage = (progress * 100).toStringAsFixed(1);
      final downloadedSize = _formatBytes(info.progress);
      final totalSize = _formatBytes(info.size);
      final statusText = _getStatusText(info.status);

      return Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      info.entryInfo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(info.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 进度条
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(info.status),
                ),
              ),
              const SizedBox(height: 8),

              // 进度信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$downloadedSize / $totalSize',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (info.status == CurrentDownloadInfo.STATUS_DOWNLOADING ||
                      info.status == CurrentDownloadInfo.STATUS_AUDIO_DOWNLOADING)
                    TextButton(
                      onPressed: onPause,
                      child: const Text('暂停'),
                    ),
                  if (info.status == CurrentDownloadInfo.STATUS_FAIL_DOWNLOAD)
                    TextButton(
                      onPressed: onResume,
                      child: const Text('重试'),
                    ),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('取消'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case CurrentDownloadInfo.STATUS_GET_DANMAKU:
        return '获取弹幕中';
      case CurrentDownloadInfo.STATUS_FAIL_DANMAKU:
        return '弹幕获取失败';
      case CurrentDownloadInfo.STATUS_GET_PLAYURL:
        return '获取播放地址';
      case CurrentDownloadInfo.STATUS_FAIL_PLAYURL:
        return '地址获取失败';
      case CurrentDownloadInfo.STATUS_DOWNLOADING:
        return '下载中';
      case CurrentDownloadInfo.STATUS_AUDIO_DOWNLOADING:
        return '音频下载中';
      case CurrentDownloadInfo.STATUS_FAIL_DOWNLOAD:
        return '下载失败';
      case CurrentDownloadInfo.STATUS_COMPLETED:
        return '下载完成';
      default:
        return '准备中';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case CurrentDownloadInfo.STATUS_FAIL_DANMAKU:
      case CurrentDownloadInfo.STATUS_FAIL_PLAYURL:
      case CurrentDownloadInfo.STATUS_FAIL_DOWNLOAD:
        return Colors.red;
      case CurrentDownloadInfo.STATUS_COMPLETED:
        return Colors.green;
      case CurrentDownloadInfo.STATUS_DOWNLOADING:
      case CurrentDownloadInfo.STATUS_AUDIO_DOWNLOADING:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(int status) {
    switch (status) {
      case CurrentDownloadInfo.STATUS_FAIL_DANMAKU:
      case CurrentDownloadInfo.STATUS_FAIL_PLAYURL:
      case CurrentDownloadInfo.STATUS_FAIL_DOWNLOAD:
        return Colors.red;
      case CurrentDownloadInfo.STATUS_COMPLETED:
        return Colors.green;
      case CurrentDownloadInfo.STATUS_DOWNLOADING:
      case CurrentDownloadInfo.STATUS_AUDIO_DOWNLOADING:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}