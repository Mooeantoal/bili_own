import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/utils/download_service.dart';
import 'package:bili_own/common/widget/download_progress_indicator.dart';

class DownloadPage extends StatelessWidget {
  final DownloadService downloadService = Get.find<DownloadService>();

  DownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final currentDownload = downloadService.curDownload.value;
        final downloadList = downloadService.downloadList;

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            // 当前下载进度
            if (currentDownload != null)
              DownloadProgressIndicator(
                downloadInfo: downloadService.curDownload,
                onCancel: () => downloadService.cancelDownload(currentDownload.entryInfo.taskId),
                onPause: () => downloadService.pauseDownload(currentDownload.entryInfo.taskId),
                onResume: () => downloadService.resumeDownload(currentDownload.entryInfo.taskId),
              )
            else
              const Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '当前没有正在进行的下载任务',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            const Divider(
              height: 32,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),

            // 下载列表标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '下载列表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 下载列表
            if (downloadList.isEmpty)
              const Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '暂无下载记录',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...downloadList.map((entry) {
                // 使用avid作为任务ID的替代
                final progress = downloadService.getDownloadProgress(entry.entry.avid?.toString() ?? "");
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.entry.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'UP主ID: ${entry.entry.ownerId ?? "未知"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '大小: ${_formatBytes(entry.entry.totalBytes)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0 ? Colors.green : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              progress == 1.0 ? '已完成' : '下载中',
                              style: TextStyle(
                                fontSize: 14,
                                color: progress == 1.0 ? Colors.green : Colors.orange,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // TODO: 实现删除下载记录功能
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        );
      }),
    );
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
}