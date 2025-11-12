import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/utils/download_service.dart';
import 'package:bili_own/common/widget/download_progress_indicator.dart';

class TestDownloadPage extends StatefulWidget {
  const TestDownloadPage({Key? key}) : super(key: key);

  @override
  State<TestDownloadPage> createState() => _TestDownloadPageState();
}

class _TestDownloadPageState extends State<TestDownloadPage> {
  final DownloadService downloadService = Get.find<DownloadService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '下载进度实时显示测试',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // 实时下载进度显示
            DownloadProgressIndicator(
              downloadInfo: downloadService.curDownload,
              onCancel: downloadService.cancelDownload,
              onPause: downloadService.pauseDownload,
              onResume: downloadService.resumeDownload,
            ),
            
            const SizedBox(height: 20),
            
            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 模拟开始下载
                    // 这里应该调用实际的下载方法
                  },
                  child: const Text('开始下载'),
                ),
                ElevatedButton(
                  onPressed: downloadService.pauseDownload,
                  child: const Text('暂停下载'),
                ),
                ElevatedButton(
                  onPressed: downloadService.resumeDownload,
                  child: const Text('恢复下载'),
                ),
                ElevatedButton(
                  onPressed: downloadService.cancelDownload,
                  child: const Text('取消下载'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 下载列表
            const Text(
              '下载列表',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: Obx(() {
                final downloadList = downloadService.downloadList;
                if (downloadList.isEmpty) {
                  return const Center(
                    child: Text('暂无下载任务'),
                  );
                }
                
                return ListView.builder(
                  itemCount: downloadList.length,
                  itemBuilder: (context, index) {
                    final downloadItem = downloadList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(downloadItem.entry.title),
                        subtitle: Text('UP主ID: ${downloadItem.entry.ownerId ?? "未知"}'),
                        trailing: Text(
                          downloadItem.entry.isCompleted ? '已完成' : '未完成',
                          style: TextStyle(
                            color: downloadItem.entry.isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}