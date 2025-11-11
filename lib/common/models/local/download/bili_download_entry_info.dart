class BiliDownloadEntryInfo {
  final String title;
  final String cover;
  final int preferedVideoQuality;
  final String durlBackupUrl;
  final int totalBytes;
  final int downloadedBytes;
  final String filePath;
  final String taskId;
  final String type;
  final int state;
  final String errorMsg;
  final int createTime;
  final int finishTime;
  final String aid;
  final String cid;
  final String bvid;
  final String seasonId;
  final String episodeId;
  final String upName;
  final String upMid;

  BiliDownloadEntryInfo({
    required this.title,
    required this.cover,
    required this.preferedVideoQuality,
    required this.durlBackupUrl,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.filePath,
    required this.taskId,
    required this.type,
    required this.state,
    required this.errorMsg,
    required this.createTime,
    required this.finishTime,
    required this.aid,
    required this.cid,
    required this.bvid,
    required this.seasonId,
    required this.episodeId,
    required this.upName,
    required this.upMid,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'cover': cover,
      'preferedVideoQuality': preferedVideoQuality,
      'durlBackupUrl': durlBackupUrl,
      'totalBytes': totalBytes,
      'downloadedBytes': downloadedBytes,
      'filePath': filePath,
      'taskId': taskId,
      'type': type,
      'state': state,
      'errorMsg': errorMsg,
      'createTime': createTime,
      'finishTime': finishTime,
      'aid': aid,
      'cid': cid,
      'bvid': bvid,
      'seasonId': seasonId,
      'episodeId': episodeId,
      'upName': upName,
      'upMid': upMid,
    };
  }

  factory BiliDownloadEntryInfo.fromJson(Map<String, dynamic> json) {
    return BiliDownloadEntryInfo(
      title: json['title'] as String,
      cover: json['cover'] as String,
      preferedVideoQuality: json['preferedVideoQuality'] as int,
      durlBackupUrl: json['durlBackupUrl'] as String,
      totalBytes: json['totalBytes'] as int,
      downloadedBytes: json['downloadedBytes'] as int,
      filePath: json['filePath'] as String,
      taskId: json['taskId'] as String,
      type: json['type'] as String,
      state: json['state'] as int,
      errorMsg: json['errorMsg'] as String,
      createTime: json['createTime'] as int,
      finishTime: json['finishTime'] as int,
      aid: json['aid'] as String,
      cid: json['cid'] as String,
      bvid: json['bvid'] as String,
      seasonId: json['seasonId'] as String,
      episodeId: json['episodeId'] as String,
      upName: json['upName'] as String,
      upMid: json['upMid'] as String,
    );
  }
}