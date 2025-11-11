import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'download_service.dart';
import '../../common/models/local/download/bili_download_entry_info.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late DownloadService _downloadService;

  @override
  void initState() {
    super.initState();
    _downloadService = Get.put(DownloadService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
      ),
      body: Obx(() {
        final downloadList = _downloadService.downloadList;
        if (downloadList.isEmpty) {
          return const Center(
            child: Text('暂无下载任务'),
          );
        }

        return ListView.builder(
          itemCount: downloadList.length,
          itemBuilder: (context, index) {
            final downloadItem = downloadList[index];
            return _buildDownloadItem(downloadItem);
          },
        );
      }),
    );
  }

  Widget _buildDownloadItem(BiliDownloadEntryInfo downloadItem) {
    final isDownloading = _downloadService.isDownloading(downloadItem.taskId);
    final progress = _downloadService.getDownloadProgress(downloadItem.taskId);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              downloadItem.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'UP主: ${downloadItem.upName}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    if (isDownloading)
                      IconButton(
                        icon: const Icon(Icons.pause, size: 20),
                        onPressed: () {
                          _downloadService.pauseDownload(downloadItem.taskId);
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.play_arrow, size: 20),
                        onPressed: () {
                          // TODO: 实现继续下载功能
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.cancel, size: 20),
                      onPressed: () {
                        _downloadService.cancelDownload(downloadItem.taskId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}