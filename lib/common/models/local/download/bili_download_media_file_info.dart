class BiliDownloadMediaFileInfo {
  final int quality;
  final String qualityString;
  final int fileSize;
  final String filePath;
  final String taskId;
  final int state;
  final String errorMsg;
  final int downloadedBytes;
  final String downloadUrl;
  final String backupUrl;
  final int createTime;
  final int finishTime;

  BiliDownloadMediaFileInfo({
    required this.quality,
    required this.qualityString,
    required this.fileSize,
    required this.filePath,
    required this.taskId,
    required this.state,
    required this.errorMsg,
    required this.downloadedBytes,
    required this.downloadUrl,
    required this.backupUrl,
    required this.createTime,
    required this.finishTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'qualityString': qualityString,
      'fileSize': fileSize,
      'filePath': filePath,
      'taskId': taskId,
      'state': state,
      'errorMsg': errorMsg,
      'downloadedBytes': downloadedBytes,
      'downloadUrl': downloadUrl,
      'backupUrl': backupUrl,
      'createTime': createTime,
      'finishTime': finishTime,
    };
  }

  factory BiliDownloadMediaFileInfo.fromJson(Map<String, dynamic> json) {
    return BiliDownloadMediaFileInfo(
      quality: json['quality'] as int,
      qualityString: json['qualityString'] as String,
      fileSize: json['fileSize'] as int,
      filePath: json['filePath'] as String,
      taskId: json['taskId'] as String,
      state: json['state'] as int,
      errorMsg: json['errorMsg'] as String,
      downloadedBytes: json['downloadedBytes'] as int,
      downloadUrl: json['downloadUrl'] as String,
      backupUrl: json['backupUrl'] as String,
      createTime: json['createTime'] as int,
      finishTime: json['finishTime'] as int,
    );
  }
}