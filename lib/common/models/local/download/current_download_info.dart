import 'bili_download_entry_info.dart';
import 'bili_download_media_file_info.dart';

class CurrentDownloadInfo {
  final BiliDownloadEntryInfo entryInfo;
  final List<BiliDownloadMediaFileInfo> mediaFiles;

  CurrentDownloadInfo({
    required this.entryInfo,
    required this.mediaFiles,
  });

  Map<String, dynamic> toJson() {
    return {
      'entryInfo': entryInfo.toJson(),
      'mediaFiles': mediaFiles.map((e) => e.toJson()).toList(),
    };
  }

  factory CurrentDownloadInfo.fromJson(Map<String, dynamic> json) {
    return CurrentDownloadInfo(
      entryInfo: BiliDownloadEntryInfo.fromJson(json['entryInfo']),
      mediaFiles: (json['mediaFiles'] as List)
          .map((e) => BiliDownloadMediaFileInfo.fromJson(e))
          .toList(),
    );
  }
}