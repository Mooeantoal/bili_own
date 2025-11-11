import 'dart:developer';

import 'package:bili_own/common/api/video_operation_api.dart';
import 'package:bili_own/common/models/local/reply/reply_item.dart';
import 'package:bili_own/common/models/local/video/video_play_info.dart';
import 'package:bili_own/common/utils/bvid_avid_util.dart';
import 'package:bili_own/common/utils/http_utils.dart';
import 'package:bili_own/pages/about/about_page.dart';
import 'package:bili_own/pages/bili_video/widgets/reply/index.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player.dart' as bp;
import 'package:bili_own/pages/login/password_login/index.dart';
import 'package:bili_own/pages/login/sms_login/index.dart';
import 'package:bili_own/pages/ui_test/test_widget/media_kit_test_page.dart';
import 'package:bili_own/pages/user_space/view.dart';
import 'package:bili_own/pages/test/piliplus_comments_page.dart';
import 'package:bili_own/pages/test/video_player_test_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/api/api_constants.dart';

class UiTestController extends GetxController {
  UiTestController();

  List<ListTile> listTiles = [];
  bp.BiliVideoPlayerController biliVideoPlayerController =
      bp.BiliVideoPlayerController(
          videoPlayInfo: VideoPlayInfo.zero,
          bvid: BvidAvidUtil.av2Bvid(170001), 
          cid: 279786);

  //测试名称,页面对应表
  late Map<String, Widget> _testPages;

  _buildListTiles() {
    _testPages.forEach((text, page) {
      listTiles.add(ListTile(
        title: Text(text),
        onTap: () =>
            // Get.to(() => Scaffold(
            //       appBar: AppBar(title: Text(text)),
            //       body: page,
            //     ))
            Navigator.of(Get.context!).push(GetPageRoute(
                page: () => Scaffold(
                      appBar: AppBar(title: Text(text)),
                      body: page,
                    ))),
      ));
    });
  }

  _initData() {
    // update(["ui_test"]);
  }

  void onTap() {}

  @override
  void onInit() {
    _testPages = {
      "播放器测试": const VideoPlayerTestPage(),
      "PiliPlus评论界面": const PiliPlusCommentsPage(),
      "评论测试": const ReplyPage(
        replyId: "170001",
        replyType: ReplyType.video,
      ),
      "许可": const LicensePage(
        applicationIcon: ImageIcon(
          AssetImage("assets/icon/bili.png"),
          size: 200,
        ),
        applicationName: "Bili You",
      ),
      "关于": const AboutPage(),
      // "视频": AspectRatio(
      //   aspectRatio: 16 / 9,
      //   child: BiliVideoPlayerWidget(
      //     biliVideoPlayerController,
      //     heroTagId: HeroTagId.lastId,
      //     buildDanmaku: (context, biliVideoPlayerController) {
      //       return BiliDanmaku(
      //           controller: BiliDanmakuController(biliVideoPlayerController));
      //     },
      //     buildControllPanel: (context, biliVideoPlayerController) {
      //       return BiliVideoPlayerPanel(
      //           BiliVideoPlayerPanelController(biliVideoPlayerController));
      //     },
      //   ),
      // ),
      "用户投稿": const UserSpacePage(
        mid: 16752607,
      ),
      "test cookie": Center(
        child: MaterialButton(
            child: const Text("print cookie"),
            onPressed: () async {
              log('cookies:');
              for (var i in (await HttpUtils.cookieManager.cookieJar
                  .loadForRequest(Uri.parse(ApiConstants.bilibiliBase)))) {
                log('name:${i.name},\tvalue:${i.value},\tmaxAge:${i.maxAge.toString()}');
                Get.rawSnackbar(
                    message:
                        'name:${i.name},\tvalue:${i.value},\tmaxAge:${i.maxAge.toString()}');
              }
            }),
      ),
      'test like': Center(
        child: Column(
          children: [
            MaterialButton(
              child: const Text('like'),
              onPressed: () async {
                var result = (await VideoOperationApi.clickLike(
                    bvid: 'BV1Ex4y1F7LX', likeOrCancelLike: true));
                Get.rawSnackbar(
                  message:
                      'isSuccess:${result.isSuccess}, error:${result.error}, haslike:${result.haslike}',
                );
              },
            ),
            MaterialButton(
              child: const Text('cancel like'),
              onPressed: () async {
                var result = (await VideoOperationApi.clickLike(
                    bvid: 'BV1Ex4y1F7LX', likeOrCancelLike: false));
                Get.rawSnackbar(
                  message:
                      'isSuccess:${result.isSuccess}, error:${result.error}, haslike:${result.haslike}',
                );
              },
            ),
          ],
        ),
      ),
      '密码登陆': const PasswordLoginPage(),
      '短信登陆': const PhoneLoginPage(),
      '视频播放测试': Builder(
        builder: (context) => bp.BiliVideoPlayer(
          videoPlayInfo: VideoPlayInfo.zero,
          bvid: '',
          cid: 0,
        ),
      ),
    };
    //初始化构建测试页面项列表
    _buildListTiles();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  @override
  void onClose() {
    biliVideoPlayerController.dispose();
    super.onClose();
  }
}