import 'dart:developer';

import 'package:bili_own/common/api/index.dart';
import 'package:bili_own/common/api/video_operation_api.dart';
import 'package:bili_own/common/models/local/related_video/related_video_info.dart';
import 'package:bili_own/common/models/local/video/click_add_coin_result.dart';
import 'package:bili_own/common/models/local/video/click_add_share_result.dart';
import 'package:bili_own/common/models/local/video/click_like_result.dart';
import 'package:bili_own/common/models/local/video/video_info.dart';
import 'package:bili_own/common/values/cache_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
// 添加下载相关的导入
import 'package:bili_own/pages/download/download_service.dart';
import 'package:bili_own/common/models/local/download/bili_download_entry_info.dart';
import 'package:bili_own/common/models/local/download/bili_download_media_file_info.dart';
import 'package:bili_own/common/api/video_play_api.dart';
import 'package:bili_own/common/models/local/video/video_play_item.dart';
import 'package:bili_own/common/models/local/video/audio_play_item.dart';
import 'package:bili_own/common/utils/bili_own_storage.dart';

class IntroductionController extends GetxController {
  IntroductionController(
      {required this.bvid,
      required this.cid,
      required this.ssid,
      required this.isBangumi,
      required this.changePartCallback,
      required this.refreshReply});
  String bvid;
  int? cid;
  int? ssid;
  RxString title = "".obs;
  RxString describe = "".obs;

  late VideoInfo videoInfo;
  bool isInitialized = false;

  final bool isBangumi;
  final Function(String bvid, int cid) changePartCallback;
  final Function() refreshReply;
  Function()? refreshOperationButton; //刷新操作按钮(如点赞之类的按钮)
  final CacheManager cacheManager =
      CacheManager(Config(CacheKeys.relatedVideosItemCoverKey));
  final ScrollController scrollController = ScrollController();

  final List<Widget> partButtons = []; //分p按钮列表
  final List<RelatedVideoInfo> relatedVideoInfos = []; //相关视频列表

//加载视频信息
  Future<bool> loadVideoInfo() async {
    if (isInitialized) {
      return true;
    }
    try {
      videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
    } catch (e) {
      log("loadVideoInfo:$e");
      return false;
    }
    title.value = videoInfo.title;
    describe.value = videoInfo.describe;
    if (!isBangumi) {
      //当是普通视频时
      //初始化时构造分p按钮
      _loadVideoPartButtons();
      //构造相关视频
      await _loadRelatedVideos();
    } else {
      //如果是番剧
      await _loadBangumiPartButtons();
    }
    isInitialized = true;
    return true;
  }

  //添加一个分p/剧集按钮
  void _addAButtion(String bvid, int cid, String text, int index) {
    partButtons.add(
      Padding(
        padding: const EdgeInsets.all(2),
        child: MaterialButton(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Theme.of(Get.context!).colorScheme.primaryContainer,
            onPressed: () async {
              //点击切换分p
              changePartCallback(bvid, cid);
              if (isBangumi) {
                //如果是番剧的还，切换时还需要改变标题，简介
                videoInfo = await VideoInfoApi.getVideoInfo(bvid: bvid);
                //刷新操作按钮(如点赞之类的按钮)
                refreshOperationButton?.call();
                title.value = videoInfo.title;
                describe.value = videoInfo.describe;
                //评论区也要刷新
                refreshReply();
              }
            },
            child: Text(text)),
      ),
    );
  }

  //构造分p按钮列表
  void _loadVideoPartButtons() {
    if (videoInfo.parts.length > 1) {
      for (int i = 0; i < videoInfo.parts.length; i++) {
        _addAButtion(bvid, videoInfo.parts[i].cid, videoInfo.parts[i].title, i);
      }
    }
  }

//构造番剧剧集按钮
  Future<void> _loadBangumiPartButtons() async {
    var bangumiInfo = await BangumiApi.getBangumiInfo(ssid: ssid);
    for (int i = 0; i < bangumiInfo.episodes.length; i++) {
      _addAButtion(bangumiInfo.episodes[i].bvid, bangumiInfo.episodes[i].cid,
          bangumiInfo.episodes[i].title, i);
    }
  }

//构造相关视频
  Future<void> _loadRelatedVideos() async {
    late List<RelatedVideoInfo> list;
    try {
      list = await RelatedVideoApi.getRelatedVideo(bvid: bvid);
    } catch (e) {
      log("构造相关视频失败:${e.toString()}");
    }
    relatedVideoInfos.addAll(list);
  }

  ///点赞按钮点击时
  Future<void> onLikePressed() async {
    late ClickLikeResult result;
    try {
      result = await VideoOperationApi.clickLike(
          bvid: videoInfo.bvid, likeOrCancelLike: !videoInfo.hasLike);
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: "失败:${result.error}",
        duration: const Duration(milliseconds: 1000),
      ));
      return;
    }

    if (result.isSuccess) {
      videoInfo.hasLike = result.haslike;
      if (result.haslike) {
        log('${result.haslike}');
        videoInfo.likeNum++;
      } else {
        log('${result.haslike}');
        videoInfo.likeNum--;
      }
    } else {
      Get.showSnackbar(GetSnackBar(
        message: "失败:${result.error}",
        duration: const Duration(milliseconds: 1000),
      ));
    }
    refreshOperationButton!.call();
  }

  Future<void> onAddCoinPressed() async {
    late ClickAddCoinResult result;
    try {
      result = await VideoOperationApi.addCoin(bvid: bvid);
      if (result.isSuccess) {
        videoInfo.hasAddCoin = result.isSuccess;
        videoInfo.coinNum++;
        refreshOperationButton!.call();
      } else {
        Get.showSnackbar(GetSnackBar(
          message: "失败:${result.error}",
          duration: const Duration(milliseconds: 1000),
        ));
      }
    } catch (e) {
      log('onAddCoinPressed$e');
      Get.showSnackbar(GetSnackBar(
        message: "失败:${result.error}",
        duration: const Duration(milliseconds: 1000),
      ));
    }
  }

  Future<void> onAddSharePressed() async {
    try {
      ClickAddShareResult result = await VideoOperationApi.share(bvid: bvid);
      if (result.isSuccess) {
        videoInfo.shareNum = result.currentShareNum;
      } else {
        log('分享失败:${result.error}');
      }
      Share.share('${ApiConstants.bilibiliBase}/video/$bvid');
    } catch (e) {
      Get.rawSnackbar(message: '分享失败:$e');
    }
    refreshOperationButton!.call();
  }

  // 添加下载功能
  Future<void> onDownloadPressed() async {
    try {
      // 获取下载服务
      final downloadService = Get.find<DownloadService>();
      
      // 加载视频播放信息
      final videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: int.parse(cid?.toString() ?? "0"));
      
      // 获取视频和音频信息
      final videoItem = videoPlayInfo.videos.first; // 选择第一个视频（最高质量）
      final audioItem = videoPlayInfo.audios.first; // 选择第一个音频
      
      // 创建下载条目信息
      final downloadEntryInfo = BiliDownloadEntryInfo(
        title: videoInfo.title,
        cover: videoInfo.ownerFace, // 使用UP主头像作为封面
        preferedVideoQuality: videoItem.quality.index,
        durlBackupUrl: videoItem.urls.length > 1 ? videoItem.urls[1] : "", // 备用URL
        totalBytes: videoItem.bandWidth, // 视频总字节数
        downloadedBytes: 0, // 已下载字节数
        filePath: "", // 下载文件路径
        taskId: DateTime.now().millisecondsSinceEpoch.toString(), // 任务ID
        type: "video", // 下载类型
        state: 0, // 下载状态
        errorMsg: "", // 错误信息
        createTime: DateTime.now().millisecondsSinceEpoch, // 创建时间
        finishTime: 0, // 完成时间
        aid: videoInfo.bvid, // BV号作为aid
        cid: cid?.toString() ?? "", // CID
        bvid: bvid, // BV号
        seasonId: "", // 番剧ID
        episodeId: "", // 剧集ID
        upName: videoInfo.ownerName, // UP主名称
        upMid: videoInfo.ownerMid.toString(), // UP主ID
      );
      
      // 创建媒体文件信息列表
      final mediaFiles = <BiliDownloadMediaFileInfo>[
        // 视频文件信息
        BiliDownloadMediaFileInfo(
          quality: videoItem.quality.index,
          qualityString: VideoQualityDescription(videoItem.quality).description, // 使用扩展获取描述
          fileSize: videoItem.bandWidth,
          filePath: "", // 下载文件路径
          taskId: downloadEntryInfo.taskId,
          state: 0, // 下载状态
          errorMsg: "", // 错误信息
          downloadedBytes: 0, // 已下载字节数
          downloadUrl: videoItem.urls.first, // 下载URL
          backupUrl: videoItem.urls.length > 1 ? videoItem.urls[1] : "", // 备用URL
          createTime: DateTime.now().millisecondsSinceEpoch, // 创建时间
          finishTime: 0, // 完成时间
        ),
        // 音频文件信息
        BiliDownloadMediaFileInfo(
          quality: audioItem.quality.index,
          qualityString: AudioQualityDescription(audioItem.quality).description, // 使用扩展获取描述
          fileSize: audioItem.bandWidth,
          filePath: "", // 下载文件路径
          taskId: downloadEntryInfo.taskId,
          state: 0, // 下载状态
          errorMsg: "", // 错误信息
          downloadedBytes: 0, // 已下载字节数
          downloadUrl: audioItem.urls.first, // 下载URL
          backupUrl: audioItem.urls.length > 1 ? audioItem.urls[1] : "", // 备用URL
          createTime: DateTime.now().millisecondsSinceEpoch, // 创建时间
          finishTime: 0, // 完成时间
        ),
      ];
      
      // 添加到下载队列
      await downloadService.addToDownloadQueue(downloadEntryInfo, mediaFiles);
      
      // 显示提示信息
      Get.snackbar(
        "开始下载",
        "已添加到下载队列",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "下载失败",
        "添加到下载队列失败: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    cacheManager.emptyCache();
    super.onClose();
  }
}