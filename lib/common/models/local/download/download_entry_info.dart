// 下载条目信息
class DownloadEntryInfo {
  DownloadEntryInfo({
    required this.mediaType,
    required this.hasDashAudio,
    required this.isCompleted,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.title,
    this.typeTag,
    required this.cover,
    required this.preferedVideoQuality,
    required this.qualityPithyDescription,
    required this.guessedTotalBytes,
    required this.totalTimeMilli,
    required this.danmakuCount,
    this.timeUpdateStamp = 0,
    this.timeCreateStamp = 0,
    this.canPlayInAdvance = false,
    this.interruptTransformTempFile = false,
    this.avid,
    this.spid,
    this.bvid,
    this.ownerId,
    this.pageData,
    this.seasonId,
    this.source,
    this.ep,
  });

  final int mediaType;
  final bool hasDashAudio;
  bool isCompleted;
  int totalBytes;
  int downloadedBytes;
  final String title;
  final String? typeTag;
  final String cover;
  final int preferedVideoQuality;
  final String qualityPithyDescription;
  final int guessedTotalBytes;
  int totalTimeMilli;
  final int danmakuCount;
  final int timeUpdateStamp;
  final int timeCreateStamp;
  final bool canPlayInAdvance;
  bool interruptTransformTempFile;
  final int? avid;
  final int? spid;
  final String? bvid;
  final int? ownerId;
  PageInfo? pageData;
  final String? seasonId;
  final SourceInfo? source;
  EpInfo? ep;

  int get key {
    return source?.cid ?? pageData?.cid ?? avid ?? 0;
  }

  String get name {
    if (ep != null) {
      return title + (ep!.indexTitle ?? "");
    }
    if (pageData != null) {
      return title + (pageData!.part ?? "");
    }
    return title;
  }

  String get videoDirName {
    return typeTag ?? preferedVideoQuality.toString();
  }
}

// 页面信息
class PageInfo {
  PageInfo({
    required this.cid,
    required this.page,
    this.from,
    this.part,
    this.vid,
    required this.hasAlias,
    required this.tid,
    this.width = 0,
    this.height = 0,
    this.rotate = 0,
    this.downloadTitle,
    this.downloadSubtitle,
  });

  final int cid;
  final int page;
  final String? from;
  final String? part;
  final String? vid;
  final bool hasAlias;
  final int tid;
  final int width;
  final int height;
  final int rotate;
  final String? downloadTitle;
  final String? downloadSubtitle;
}

// 源信息
class SourceInfo {
  SourceInfo({
    required this.avId,
    required this.cid,
  });

  final int avId;
  final int cid;
}

// 剧集信息
class EpInfo {
  EpInfo({
    required this.avId,
    required this.page,
    required this.danmaku,
    required this.cover,
    required this.episodeId,
    required this.index,
    this.indexTitle,
    required this.from,
    required this.seasonType,
    required this.width,
    required this.height,
    required this.rotate,
    this.link = "",
    this.bvid = "",
    this.sortIndex = 0,
  });

  final int avId;
  final int page;
  final int danmaku;
  final String cover;
  final int episodeId;
  final String index;
  final String? indexTitle;
  final String from;
  final int seasonType;
  final int width;
  final int height;
  final int rotate;
  final String link;
  final String bvid;
  final int sortIndex;
}