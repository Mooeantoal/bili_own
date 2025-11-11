// 下载媒体文件信息
class DownloadMediaFileInfo {
  DownloadMediaFileInfo();

  Map<String, String> httpHeader() {
    return {};
  }
}

// Type1媒体文件信息
class Type1MediaFileInfo extends DownloadMediaFileInfo {
  Type1MediaFileInfo({
    required this.availablePeriodMilli,
    required this.description,
    required this.format,
    this.from,
    required this.intact,
    required this.isDownloaded,
    required this.isResolved,
    required this.marlinToken,
    required this.needLogin,
    required this.needVip,
    required this.parseTimestampMilli,
    required this.playerCodecConfigList,
    required this.playerError,
    required this.quality,
    required this.segmentList,
    required this.timeLength,
    this.typeTag,
    this.userAgent,
    this.referer,
    required this.videoCodecId,
    required this.videoProject,
  });

  final int availablePeriodMilli;
  final String description;
  final String format;
  final String? from;
  final bool intact;
  final bool isDownloaded;
  final bool isResolved;
  final String marlinToken;
  final bool needLogin;
  final bool needVip;
  final int parseTimestampMilli;
  final List<Type1PlayerCodecConfig> playerCodecConfigList;
  final int playerError;
  final int quality;
  final List<Type1Segment> segmentList;
  final int timeLength;
  final String? typeTag;
  final String? userAgent;
  final String? referer;
  final int videoCodecId;
  final bool videoProject;

  @override
  Map<String, String> httpHeader() {
    return {
      if (referer != null && referer!.isNotEmpty) 'Referer': referer!,
      if (userAgent != null && userAgent!.isNotEmpty) 'User-Agent': userAgent!,
    };
  }
}

// Type1播放器编解码配置
class Type1PlayerCodecConfig {
  Type1PlayerCodecConfig({
    required this.player,
    required this.useIjkMediaCodec,
  });

  final String player;
  final bool useIjkMediaCodec;
}

// Type1片段信息
class Type1Segment {
  Type1Segment({
    required this.backupUrls,
    required this.bytes,
    required this.duration,
    required this.md5,
    required this.metaUrl,
    required this.order,
    required this.url,
  });

  final List<String> backupUrls;
  final int bytes;
  final int duration;
  final String md5;
  final String metaUrl;
  final int order;
  final String url;
}

// Type2媒体文件信息
class Type2MediaFileInfo extends DownloadMediaFileInfo {
  Type2MediaFileInfo({
    required this.duration,
    required this.video,
    this.audio,
    this.userAgent,
    this.referer,
  });

  final int duration;
  final List<Type2File> video;
  final List<Type2File>? audio;
  final String? userAgent;
  final String? referer;

  @override
  Map<String, String> httpHeader() {
    return {
      if (referer != null && referer!.isNotEmpty) 'Referer': referer!,
      if (userAgent != null && userAgent!.isNotEmpty) 'User-Agent': userAgent!,
    };
  }
}

// Type2文件信息
class Type2File {
  Type2File({
    required this.id,
    required this.baseUrl,
    this.backupUrl,
    required this.bandwidth,
    required this.codecid,
    required this.size,
    required this.md5,
    required this.noRexcode,
    this.frameRate = "",
    this.width = 1,
    this.height = 1,
    this.dashDrmType = 0,
  });

  final int id;
  final String baseUrl;
  final List<String>? backupUrl;
  final int bandwidth;
  final int codecid;
  int size;
  final String md5;
  final bool noRexcode;
  final String frameRate;
  final int width;
  final int height;
  final int dashDrmType;
}

// 空媒体文件信息
class NoneMediaFileInfo extends DownloadMediaFileInfo {
  NoneMediaFileInfo(this.message);

  final String message;
}