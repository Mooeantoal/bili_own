import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_danmaku.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player_panel.dart';
import 'package:bili_own/pages/bili_video/widgets/reply/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 添加导入
import 'package:bili_own/common/api/video_play_api.dart';
import 'package:bili_own/common/models/local/video/video_play_info.dart';

class BiliVideoController extends GetxController
    with GetTickerProviderStateMixin {
  BiliVideoController({
    required this.bvid,
    required this.cid,
    this.ssid,
    this.progress,
    required this.isBangumi,
  });
  String bvid;
  late String oldBvid;
  int cid;
  int? ssid;
  int? progress;
  bool isBangumi;

  late BiliVideoPlayerController biliVideoPlayerController;
  late BiliVideoPlayerPanelController biliVideoPlayerPanelController;
  late BiliDanmakuController biliDanmakuController;
  late final TabController tabController;
  
  // 添加 videoPlayInfo 变量
  late VideoPlayInfo videoPlayInfo;

  Future<void> changeVideoPart(String bvid, int cid) async {
    this.cid = cid;
    this.bvid = bvid;
    biliVideoPlayerController.bvid = bvid;
    biliVideoPlayerController.cid = cid;
    await biliVideoPlayerController.changeCid(bvid, cid);
  }

  refreshReply() {
    Get.find<ReplyController>(tag: 'ReplyPage:$oldBvid').bvid = bvid;
    Get.find<ReplyController>(tag: 'ReplyPage:$oldBvid')
        .refreshController
        .callRefresh();
  }

  @override
  void onInit() async {
    oldBvid = bvid;
    tabController = TabController(
        length: 2,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200));
    
    // 先获取视频播放信息
    videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
    
    biliVideoPlayerController = BiliVideoPlayerController(
        videoPlayInfo: videoPlayInfo, // 添加必需的 videoPlayInfo 参数
        bvid: bvid,
        cid: cid);
    biliVideoPlayerPanelController =
        BiliVideoPlayerPanelController(biliVideoPlayerController);
    biliDanmakuController = BiliDanmakuController(biliVideoPlayerController);
    
    // 初始化播放器
    await biliVideoPlayerController.init();
    
    // 如果有进度信息，设置初始播放位置
    if (progress != null && progress! > 0) {
      // 延迟一小段时间确保播放器完全初始化
      Future.delayed(const Duration(milliseconds: 500), () async {
        await biliVideoPlayerController.seekTo(Duration(seconds: progress!));
      });
    }
    
    super.onInit();
  }

  @override
  void onClose() async {
    await biliVideoPlayerController.dispose();
    super.onClose();
  }
}