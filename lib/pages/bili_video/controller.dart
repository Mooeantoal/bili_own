import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_danmaku.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player_panel.dart';
import 'package:bili_own/pages/bili_video/widgets/reply/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  Future<void> changeVideoPart(String bvid, int cid) async {
    this.cid = cid;
    this.bvid = bvid;
    // 重新加载视频信息而不是直接设置属性
    await biliVideoPlayerController.loadVideoInfo(bvid, cid);
  }

  refreshReply() {
    Get.find<ReplyController>(tag: 'ReplyPage:$oldBvid').bvid = bvid;
    Get.find<ReplyController>(tag: 'ReplyPage:$oldBvid')
        .refreshController
        .callRefresh();
  }

  @override
  void onInit() {
    oldBvid = bvid;
    tabController = TabController(
        length: 2,
        vsync: this,
        animationDuration: const Duration(milliseconds: 200));
    // 使用正确的构造函数
    biliVideoPlayerController = BiliVideoPlayerController(true);
    // 设置bvid和cid
    biliVideoPlayerController.bvid = bvid;
    biliVideoPlayerController.cid = cid;
    biliVideoPlayerPanelController =
        BiliVideoPlayerPanelController(biliVideoPlayerController);
    biliDanmakuController = BiliDanmakuController(biliVideoPlayerController);
    super.onInit();
  }

  @override
  void onClose() async {
    biliVideoPlayerController.dispose();
    super.onClose();
  }
}