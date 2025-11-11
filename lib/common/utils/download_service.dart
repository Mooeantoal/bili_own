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

  @override
  void onInit() {
    super.onInit();
    _readDownloadList();
  }

  // 读取下载列表
  void _readDownloadList() async {
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

  // 创建下载任务
  void createDownload(DownloadEntryInfo entry) async {
    final entryDir = await _getDownloadFileDir(entry);
    
    // 保存视频信息
    final entryJsonFile = File(path.join(entryDir.path, "entry.json"));
    // 简化处理，实际应将entry对象转换为JSON
    final entryMap = {
      'media_type': entry.mediaType,
      'has_dash_audio': entry.hasDashAudio,
      'is_completed': entry.isCompleted,
      'total_bytes': entry.totalBytes,
      'downloaded_bytes': entry.downloadedBytes,
      'title': entry.title,
      'type_tag': entry.typeTag,
      'cover': entry.cover,
      'prefered_video_quality': entry.preferedVideoQuality,
      'quality_pithy_description': entry.qualityPithyDescription,
      'guessed_total_bytes': entry.guessedTotalBytes,
      'total_time_milli': entry.totalTimeMilli,
      'danmaku_count': entry.danmakuCount,
      'time_update_stamp': entry.timeUpdateStamp,
      'time_create_stamp': entry.timeCreateStamp,
      'can_play_in_advance': entry.canPlayInAdvance,
      'interrupt_transform_temp_file': entry.interruptTransformTempFile,
      'avid': entry.avid,
      'spid': entry.spid,
      'bvid': entry.bvid,
      'owner_id': entry.ownerId,
    };
    
    entryJsonFile.writeAsStringSync(json.encode(entryMap));
    
    final biliDownInfo = DownloadEntryAndPathInfo(
      entryDirPath: entryDir.path,
      pageDirPath: entryDir.parent.path,
      entry: entry,
    );
    
    downloadList.insert(0, biliDownInfo);
    
    if (curDownload.value == null) {
      startDownload(biliDownInfo);
    } else {
      waitDownloadQueue.add(biliDownInfo);
    }
  }

  // 开始下载
  void startDownload(DownloadEntryAndPathInfo biliDownInfo) async {
    // 取消当前任务
    if (_downloadManager != null) {
      _downloadManager!.cancelDownload(_currentTaskId.toString());
    }
    if (_audioDownloadManager != null) {
      _audioDownloadManager!.cancelDownload(_currentTaskId.toString());
    }
    _downloadManager = null;
    _audioDownloadManager = null;

    // 开始任务/继续任务
    final entryDir = Directory(biliDownInfo.entryDirPath);
    final danmakuXMLFile = File(path.join(entryDir.path, "danmaku.xml"));
    final entry = biliDownInfo.entry;
    final parentId = entry.seasonId ?? entry.avid?.toString() ?? "";
    final id = entry.source?.cid ?? entry.pageData?.cid ?? 0;
    _currentTaskId = _idCounter++;

    // 创建BiliDownloadEntryInfo对象
    final biliEntryInfo = BiliDownloadEntryInfo(
      title: entry.title,
      cover: entry.cover ?? "",
      preferedVideoQuality: entry.preferedVideoQuality ?? 0,
      durlBackupUrl: "",
      totalBytes: entry.totalBytes,
      downloadedBytes: entry.downloadedBytes,
      filePath: entryDir.path,
      taskId: _currentTaskId.toString(),
      type: "video",
      state: 0,
      errorMsg: "",
      createTime: DateTime.now().millisecondsSinceEpoch,
      finishTime: 0,
      aid: entry.avid?.toString() ?? "",
      cid: entry.pageData?.cid?.toString() ?? "",
      bvid: entry.bvid ?? "",
      seasonId: entry.seasonId ?? "",
      episodeId: entry.ep?.episodeId?.toString() ?? "",
      upName: "",
      upMid: "",
    );

    // 创建CurrentDownloadInfo对象
    final currentDownloadInfo = CurrentDownloadInfo(
      entryInfo: biliEntryInfo,
      mediaFiles: [],
    );

    // 检查弹幕文件是否存在
    if (!danmakuXMLFile.existsSync()) {
      try {
        // 获取弹幕并下载
        curDownload.value = currentDownloadInfo.copyWith(
          status: CurrentDownloadInfo.STATUS_GET_DANMAKU,
        );
        
        // TODO: 实现弹幕下载逻辑
        // 这里需要调用B站API获取弹幕XML并保存
      } catch (e) {
        curDownload.value = currentDownloadInfo.copyWith(
          status: CurrentDownloadInfo.STATUS_FAIL_DANMAKU,
        );
        print("获取弹幕失败: $e");
        return;
      }
    }

    _downloadVideo(currentDownloadInfo, biliDownInfo);
  }

  // 下载视频
  void _downloadVideo(CurrentDownloadInfo currentDownloadInfo, DownloadEntryAndPathInfo biliDownInfo) async {
    if (currentDownloadInfo.taskId != _currentTaskId) {
      return;
    }

    final entry = biliDownInfo.entry;
    final entryDir = Directory(biliDownInfo.entryDirPath);
    final videoDir = Directory(path.join(entryDir.path, entry.videoDirName));
    final parentId = entry.seasonId ?? entry.avid?.toString() ?? "";
    final id = entry.source?.cid ?? entry.pageData?.cid ?? 0;
    
    if (!videoDir.existsSync()) {
      videoDir.createSync(recursive: true);
    }

    try {
      curDownload.value = currentDownloadInfo.copyWith(
        status: CurrentDownloadInfo.STATUS_GET_PLAYURL,
      );

      // 获取播放地址并下载
      final mediaFileInfo = await _getPlayUrl(entry);
      final httpHeader = mediaFileInfo.httpHeader();
      final mediaJsonFile = File(path.join(videoDir.path, "index.json"));
      mediaJsonFile.writeAsStringSync(json.encode({})); // 简化处理

      if (currentDownloadInfo.taskId != _currentTaskId) {
        return;
      }

      if (mediaFileInfo is Type2MediaFileInfo) {
        _downloadManager = DownloadManager.withParams(
          downloadInfo: CurrentDownloadInfo(
            entryInfo: BiliDownloadEntryInfo(
              title: entry.title,
              cover: entry.cover ?? "",
              preferedVideoQuality: entry.preferedVideoQuality ?? 0,
              durlBackupUrl: "",
              totalBytes: entry.totalBytes,
              downloadedBytes: entry.downloadedBytes,
              filePath: entryDir.path,
              taskId: _currentTaskId.toString(),
              type: "video",
              state: 0,
              errorMsg: "",
              createTime: DateTime.now().millisecondsSinceEpoch,
              finishTime: 0,
              aid: entry.avid?.toString() ?? "",
              cid: entry.pageData?.cid?.toString() ?? "",
              bvid: entry.bvid ?? "",
              seasonId: entry.seasonId ?? "",
              episodeId: entry.ep?.episodeId?.toString() ?? "",
              upName: "",
              upMid: "",
            ),
            mediaFiles: [],
            taskId: _currentTaskId,
            parentDirPath: entryDir.parent.path,
            parentId: parentId,
            id: id,
            name: entry.name,
            url: mediaFileInfo.video.first.baseUrl,
            size: entry.totalBytes,
            length: mediaFileInfo.duration,
            progress: entry.downloadedBytes,
            status: 0,
            header: httpHeader,
          ),
          callback: this,
        );
        
        curDownload.value = currentDownloadInfo;
        final videoFile = File(path.join(videoDir.path, "video.m4s"));
        _downloadManager?.start(videoFile);

        final audio = mediaFileInfo.audio;
        if (audio != null && audio.isNotEmpty) {
          _audioDownloadManager = DownloadManager.withParams(
            downloadInfo: CurrentDownloadInfo(
              entryInfo: BiliDownloadEntryInfo(
                title: entry.title,
                cover: entry.cover ?? "",
                preferedVideoQuality: entry.preferedVideoQuality ?? 0,
                durlBackupUrl: "",
                totalBytes: audio.first.size,
                downloadedBytes: 0,
                filePath: entryDir.path,
                taskId: _currentTaskId.toString(),
                type: "audio",
                state: 0,
                errorMsg: "",
                createTime: DateTime.now().millisecondsSinceEpoch,
                finishTime: 0,
                aid: entry.avid?.toString() ?? "",
                cid: entry.pageData?.cid?.toString() ?? "",
                bvid: entry.bvid ?? "",
                seasonId: entry.seasonId ?? "",
                episodeId: entry.ep?.episodeId?.toString() ?? "",
                upName: "",
                upMid: "",
              ),
              mediaFiles: [],
              taskId: _currentTaskId,
              parentDirPath: entryDir.parent.path,
              parentId: parentId,
              id: id,
              name: entry.name,
              url: audio.first.baseUrl,
              size: audio.first.size,
              length: mediaFileInfo.duration,
              progress: 0,
              status: 0,
              header: httpHeader,
            ),
            callback: _AudioDownloadCallback(this),
          );
          
          final audioFile = File(path.join(videoDir.path, "audio.m4s"));
          _audioDownloadManager?.start(audioFile);
        }
      }
    } catch (e) {
      curDownload.value = currentDownloadInfo.copyWith(
        status: CurrentDownloadInfo.STATUS_FAIL_PLAYURL,
      );
      print("获取播放地址失败: $e");
    }
  }

  // 获取播放地址
  Future<DownloadMediaFileInfo> _getPlayUrl(DownloadEntryInfo entry) async {
    // 简化实现，实际应调用B站API获取播放地址
    // 这里返回一个示例Type2MediaFileInfo
    return Type2MediaFileInfo(
      duration: 0,
      video: [
        Type2File(
          id: 0,
          baseUrl: "https://example.com/video.m4s",
          bandwidth: 0,
          codecid: 0,
          size: 0,
          md5: "",
          noRexcode: false,
        )
      ],
      audio: [
        Type2File(
          id: 0,
          baseUrl: "https://example.com/audio.m4s",
          bandwidth: 0,
          codecid: 0,
          size: 0,
          md5: "",
          noRexcode: false,
        )
      ],
    );
  }

  // 完成下载
  void _completeDownload() {
    final current = curDownload.value;
    if (current == null) return;

    final entryAndPathInfo = downloadList.firstWhereOrNull(
      (element) => current.id == element.entry.key
    );

    if (entryAndPathInfo != null) {
      entryAndPathInfo.entry.downloadedBytes = current.progress;
      entryAndPathInfo.entry.totalBytes = current.size;
      entryAndPathInfo.entry.isCompleted = true;
      entryAndPathInfo.entry.totalTimeMilli = current.length * 1000;
      
      // 更新entry.json文件
      final entryJsonFile = File(path.join(entryAndPathInfo.entryDirPath, "entry.json"));
      // 简化处理，实际应将entry对象转换为JSON并保存
    }

    curDownload.value = null;
    _downloadManager = null;
    _audioDownloadManager = null;
    _nextDownload();
  }

  // 下一个下载任务
  void _nextDownload() {
    if (waitDownloadQueue.isNotEmpty) {
      final next = waitDownloadQueue.removeAt(0);
      if (downloadList.any((element) => element.entry.key == next.entry.key)) {
        startDownload(next);
      } else {
        _nextDownload();
      }
    }
  }

  // 获取下载路径
  Future<String> _getDownloadPath() async {
    final appDocDir = await getApplicationSupportDirectory();
    final downloadDir = Directory(path.join(appDocDir.path, "download"));
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }
    return downloadDir.path;
  }

  // 获取下载文件目录
  Future<Directory> _getDownloadFileDir(DownloadEntryInfo entry) async {
    String dirName = "";
    String pageDirName = "";

    if (entry.ep != null) {
      dirName = "s_${entry.seasonId}";
      pageDirName = entry.ep!.episodeId.toString();
    }

    if (entry.pageData != null) {
      dirName = entry.avid?.toString() ?? "";
      pageDirName = "c_${entry.pageData!.cid}";
    }

    final downloadPath = await _getDownloadPath();
    final downloadDir = Directory(path.join(downloadPath, dirName));
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }

    final pageDir = Directory(path.join(downloadDir.path, pageDirName));
    if (!pageDir.existsSync()) {
      pageDir.createSync(recursive: true);
    }

    return pageDir;
  }

  // DownloadCallback实现
  @override
  void onTaskRunning(CurrentDownloadInfo info) {
    curDownload.value = info;
  }

  @override
  void onTaskComplete(CurrentDownloadInfo info) {
    if (info.size == 0 || info.size != info.progress) {
      return;
    }

    if (_audioDownloadManager?.downloadInfo.status == CurrentDownloadInfo.STATUS_DOWNLOADING) {
      curDownload.value = info.copyWith(
        status: CurrentDownloadInfo.STATUS_AUDIO_DOWNLOADING
      );
    } else if (_audioDownloadManager?.downloadInfo.status == CurrentDownloadInfo.STATUS_FAIL_DOWNLOAD) {
      // 重新下载音频
      // TODO: 实现重新下载逻辑
    } else {
      _completeDownload();
    }
  }

  @override
  void onTaskError(CurrentDownloadInfo info, Object error) {
    print("下载出错: $error");
    curDownload.value = info.copyWith(
      status: CurrentDownloadInfo.STATUS_FAIL_DOWNLOAD
    );
  }
}

// 音频下载回调
class _AudioDownloadCallback implements DownloadCallback {
  _AudioDownloadCallback(this._parent);

  final DownloadService _parent;

  @override
  void onTaskRunning(CurrentDownloadInfo info) {
    // 音频下载进度更新
  }

  @override
  void onTaskComplete(CurrentDownloadInfo info) {
    if (_parent._downloadManager?.downloadInfo.status == CurrentDownloadInfo.STATUS_COMPLETED) {
      _parent._completeDownload();
    }
  }

  @override
  void onTaskError(CurrentDownloadInfo info, Object error) {
    // 音频下载出错处理
  }
}

// 扩展CurrentDownloadInfo以支持copyWith方法
extension CurrentDownloadInfoCopyWith on CurrentDownloadInfo {
  CurrentDownloadInfo copyWith({
    int? taskId,
    String? parentDirPath,
    String? parentId,
    int? id,
    String? name,
    String? url,
    int? length,
    int? size,
    int? progress,
    int? status,
    Map<String, String>? header,
  }) {
    return CurrentDownloadInfo(
      entryInfo: this.entryInfo,
      mediaFiles: this.mediaFiles,
      taskId: taskId ?? this.taskId,
      parentDirPath: parentDirPath ?? this.parentDirPath,
      parentId: parentId ?? this.parentId,
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      length: length ?? this.length,
      size: size ?? this.size,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      header: header ?? this.header,
    );
  }
}