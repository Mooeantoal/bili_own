import 'bili_download_entry_info.dart';
import 'bili_download_media_file_info.dart';

class CurrentDownloadInfo {
  final BiliDownloadEntryInfo entryInfo;
  final List<BiliDownloadMediaFileInfo> mediaFiles;
  
  // 添加额外字段以匹配download_service.dart中的使用
  final int taskId;
  final String parentDirPath;
  final String parentId;
  final int id;
  final String name;
  final String url;
  final int length;
  final int size;
  final int progress;
  final int status;
  final Map<String, String>? header;

  CurrentDownloadInfo({
    required this.entryInfo,
    required this.mediaFiles,
    this.taskId = 0,
    this.parentDirPath = "",
    this.parentId = "",
    this.id = 0,
    this.name = "",
    this.url = "",
    this.length = 0,
    this.size = 0,
    this.progress = 0,
    this.status = 0,
    this.header,
  });

  // 添加状态常量
  static const int STATUS_GET_DANMAKU = 1;
  static const int STATUS_FAIL_DANMAKU = 2;
  static const int STATUS_GET_PLAYURL = 3;
  static const int STATUS_FAIL_PLAYURL = 4;
  static const int STATUS_DOWNLOADING = 5;
  static const int STATUS_AUDIO_DOWNLOADING = 6;
  static const int STATUS_FAIL_DOWNLOAD = 7;
  static const int STATUS_COMPLETED = 8;

  Map<String, dynamic> toJson() {
    return {
      'entryInfo': entryInfo.toJson(),
      'mediaFiles': mediaFiles.map((e) => e.toJson()).toList(),
      'taskId': taskId,
      'parentDirPath': parentDirPath,
      'parentId': parentId,
      'id': id,
      'name': name,
      'url': url,
      'length': length,
      'size': size,
      'progress': progress,
      'status': status,
      'header': header,
    };
  }

  factory CurrentDownloadInfo.fromJson(Map<String, dynamic> json) {
    return CurrentDownloadInfo(
      entryInfo: BiliDownloadEntryInfo.fromJson(json['entryInfo']),
      mediaFiles: (json['mediaFiles'] as List)
          .map((e) => BiliDownloadMediaFileInfo.fromJson(e))
          .toList(),
      taskId: json['taskId'] as int? ?? 0,
      parentDirPath: json['parentDirPath'] as String? ?? "",
      parentId: json['parentId'] as String? ?? "",
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      url: json['url'] as String? ?? "",
      length: json['length'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      progress: json['progress'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      header: json['header'] as Map<String, String>?,
    );
  }

  // 添加copyWith方法
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
      entryInfo: entryInfo,
      mediaFiles: mediaFiles,
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