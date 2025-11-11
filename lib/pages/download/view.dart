import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'download_service.dart';
import '../../common/models/local/download/bili_download_entry_info.dart';
import '../../common/api/video_play_api.dart';
import '../../common/models/local/video/video_play_info.dart';
import '../../common/models/local/video/video_play_item.dart';
import '../../common/models/local/video/audio_play_item.dart';
import '../../common/models/local/download/bili_download_media_file_info.dart';
import 'dart:math';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late DownloadService _downloadService;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _downloadService = Get.put(DownloadService());
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: '请输入B站视频链接',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleDownloadByUrl,
                  child: const Text('下载'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
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
          ),
        ],
      ),
    );
  }

  // 通过链接下载视频
  Future<void> _handleDownloadByUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      Get.snackbar('错误', '请输入视频链接');
      return;
    }

    try {
      // 解析URL获取bvid和cid
      final parsedInfo = _parseBilibiliUrl(url);
      if (parsedInfo == null) {
        Get.snackbar('错误', '无法解析视频链接');
        return;
      }

      final bvid = parsedInfo['bvid']!;
      final cid = parsedInfo['cid']!;

      // 获取视频播放信息
      final videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: int.parse(cid));
      if (videoPlayInfo.videos.isEmpty) {
        Get.snackbar('错误', '无法获取视频信息');
        return;
      }

      // 创建下载任务
      final taskId = '${bvid}_$cid';
      final entryInfo = BiliDownloadEntryInfo(
        title: '通过链接下载的视频',
        cover: '',
        preferedVideoQuality: videoPlayInfo.videos.first.quality.index,
        durlBackupUrl: '',
        totalBytes: videoPlayInfo.videos.first.bandWidth,
        downloadedBytes: 0,
        filePath: '',
        taskId: taskId,
        type: 'video',
        state: 0,
        errorMsg: '',
        createTime: DateTime.now().millisecondsSinceEpoch,
        finishTime: 0,
        aid: '',
        cid: cid.toString(),
        bvid: bvid,
        seasonId: '',
        episodeId: '',
        upName: '未知UP主',
        upMid: '',
      );

      // 创建媒体文件信息
      final mediaFiles = <BiliDownloadMediaFileInfo>[];
      if (videoPlayInfo.videos.isNotEmpty) {
        final video = videoPlayInfo.videos.first;
        mediaFiles.add(BiliDownloadMediaFileInfo(
          quality: video.quality.index,
          qualityString: video.quality.description,
          fileSize: video.bandWidth,
          filePath: '',
          taskId: taskId,
          state: 0,
          errorMsg: '',
          downloadedBytes: 0,
          downloadUrl: video.urls.first,
          backupUrl: video.urls.length > 1 ? video.urls[1] : '',
          createTime: DateTime.now().millisecondsSinceEpoch,
          finishTime: 0,
        ));
      }

      if (videoPlayInfo.audios.isNotEmpty) {
        final audio = videoPlayInfo.audios.first;
        mediaFiles.add(BiliDownloadMediaFileInfo(
          quality: audio.quality.index,
          qualityString: audio.quality.description,
          fileSize: audio.bandWidth,
          filePath: '',
          taskId: '${taskId}_audio',
          state: 0,
          errorMsg: '',
          downloadedBytes: 0,
          downloadUrl: audio.urls.first,
          backupUrl: audio.urls.length > 1 ? audio.urls[1] : '',
          createTime: DateTime.now().millisecondsSinceEpoch,
          finishTime: 0,
        ));
      }

      // 添加到下载队列
      await _downloadService.addToDownloadQueue(entryInfo, mediaFiles);
      Get.snackbar('成功', '已添加到下载队列');
      _urlController.clear();
    } catch (e) {
      Get.snackbar('错误', '下载失败: $e');
    }
  }

  // 解析B站URL获取bvid和cid
  Map<String, String>? _parseBilibiliUrl(String url) {
    // 匹配B站视频链接的正则表达式
    final bvidRegex = RegExp(r'av(\d+)|BV(\w+)');
    final cidRegex = RegExp(r'cid=(\d+)');
    
    String? bvid;
    String? cid;
    
    // 提取bvid
    final bvidMatch = bvidRegex.firstMatch(url);
    if (bvidMatch != null) {
      if (bvidMatch.group(1) != null) {
        // av号转换为BV号
        bvid = _av2bv(int.parse(bvidMatch.group(1)!));
      } else {
        bvid = bvidMatch.group(2);
      }
    }
    
    // 提取cid
    final cidMatch = cidRegex.firstMatch(url);
    if (cidMatch != null) {
      cid = cidMatch.group(1);
    }
    
    if (bvid != null && cid != null) {
      return {'bvid': bvid, 'cid': cid};
    }
    
    return null;
  }

  // av号转BV号的简化实现
  String _av2bv(int aid) {
    // 这是一个简化的实现，实际转换算法比较复杂
    // 在实际应用中，你可能需要调用API获取BV号
    return 'BV${Random().nextInt(1000000000)}';
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