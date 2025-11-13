// 视频详情页面，模仿bilimiao项目的视频详情页面结构
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/utils/string_format_utils.dart';
import 'package:bili_own/common/widget/icon_text_button.dart';

import '../controller.dart';
import 'test_video_player.dart';
import 'test_danmaku.dart';
import 'test_reply.dart';
import 'test_video_player_panel.dart';
import 'test_danmaku_panel.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({Key? key}) : super(key: key);

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late TestVideoController controller;
  late TestVideoPlayerController playerController;
  late TestDanmakuController danmakuController;
  
  // 控制播放器面板和弹幕面板的显示状态
  final RxBool _showPlayerPanel = true.obs;
  final RxBool _showDanmakuPanel = true.obs;
  
  // 控制是否显示视频信息区域
  final RxBool _showVideoInfo = true.obs;

  @override
  void initState() {
    controller = Get.put(TestVideoController());
    // 初始化测试播放器控制器
    playerController = TestVideoPlayerController(true);
    // 初始化测试弹幕控制器
    danmakuController = TestDanmakuController(playerController);
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<TestVideoController>();
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // 视频播放器区域
          _buildVideoPlayerSection(),
          // 视频信息区域
          Obx(() => Visibility(
            visible: _showVideoInfo.value,
            child: _buildVideoInfoSection(),
          )),
          // 评论区域
          Expanded(
            child: TestReplyPage(),
          ),
        ],
      ),
    );
  }

  // 构建视频播放器区域
  Widget _buildVideoPlayerSection() {
    return Container(
      height: 200,
      color: Colors.black,
      child: Stack(
        children: [
          // 视频播放器
          TestVideoPlayerWidget(
            bvid: 'BV14L411k7zn', // 示例BVID
            cid: 1053323351, // 示例CID
            aspectRatio: 16 / 9,
          ),
          // 播放器控制面板
          Obx(() => Visibility(
            visible: _showPlayerPanel.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TestVideoPlayerPanel(controller: playerController),
            ),
          )),
          // 弹幕面板
          Obx(() => Visibility(
            visible: _showDanmakuPanel.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TestDanmakuPanel(controller: danmakuController),
            ),
          )),
        ],
      ),
    );
  }

  // 构建视频信息区域
  Widget _buildVideoInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频标题
          const Text(
            '测试视频标题',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // 视频统计信息
          Row(
            children: [
              Icon(
                Icons.slideshow_rounded,
                size: 14,
                color: Theme.of(context).hintColor,
              ),
              Obx(() => Text(
                " ${StringFormatUtils.numFormat(controller.playCount)}  ",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              )),
              Icon(
                Icons.format_list_bulleted_rounded,
                size: 14,
                color: Theme.of(context).hintColor,
              ),
              Obx(() => Text(
                " ${controller.danmakuCount}   ",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              )),
              Text(
                "${StringFormatUtils.timeStampToDate(1609459200)} ${StringFormatUtils.timeStampToTime(1609459200)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          // 视频描述
          const Text(
            '这是一个测试视频的简介内容，用于展示从bilimiao项目移植的视频详情功能。',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          // UP主信息
          _buildUpperInfo(),
          const SizedBox(height: 8),
          // 操作按钮
          _buildOperationButtons(),
        ],
      ),
    );
  }

  // 构建UP主信息
  Widget _buildUpperInfo() {
    return Row(
      children: [
        // UP主头像
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: const Icon(Icons.person),
        ),
        const SizedBox(width: 8),
        // UP主名称
        const Text(
          '测试UP主',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        // 关注按钮
        ElevatedButton(
          onPressed: controller.followAuthor,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: const Size(0, 0),
          ),
          child: const Text('+ 关注'),
        ),
      ],
    );
  }

  // 构建操作按钮
  Widget _buildOperationButtons() {
    final TextStyle operationButtonTextStyle = const TextStyle(fontSize: 10);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() => IconTextButton(
          selected: controller.isLiked,
          icon: const Icon(Icons.thumb_up_rounded, size: 20),
          text: Text(
            StringFormatUtils.numFormat(controller.likeCount),
            style: operationButtonTextStyle,
          ),
          onPressed: controller.toggleLike,
        )),
        Obx(() => IconTextButton(
          selected: controller.isCoined,
          icon: const Icon(Icons.circle_rounded, size: 20),
          text: Text(
            StringFormatUtils.numFormat(controller.coinCount),
            style: operationButtonTextStyle,
          ),
          onPressed: controller.addCoin,
        )),
        Obx(() => IconTextButton(
          selected: controller.isFavorited,
          icon: const Icon(Icons.star_rounded, size: 20),
          text: Text(
            StringFormatUtils.numFormat(controller.favoriteCount),
            style: operationButtonTextStyle,
          ),
          onPressed: controller.toggleFavorite,
        )),
        Obx(() => IconTextButton(
          icon: const Icon(Icons.share_rounded, size: 20),
          text: Text(
            StringFormatUtils.numFormat(controller.shareCount),
            style: operationButtonTextStyle,
          ),
          onPressed: controller.share,
        )),
        IconTextButton(
          icon: const Icon(Icons.download_rounded, size: 20),
          text: Text(
            "下载",
            style: operationButtonTextStyle,
          ),
          onPressed: controller.download,
        ),
      ],
    );
  }

  // 显示更多选项菜单
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '更多选项',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.thumb_down),
                title: const Text('不喜欢'),
                onTap: () {
                  controller.dislikeVideo();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.watch_later),
                title: const Text('稍后再看'),
                onTap: () {
                  controller.addToWatchLater();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('添加到播放列表'),
                onTap: () {
                  controller.addToPlaylist();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('举报'),
                onTap: () {
                  controller.reportVideo();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('复制链接'),
                onTap: () {
                  controller.copyVideoLink();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('浏览器打开'),
                onTap: () {
                  controller.openInBrowser();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('保存封面'),
                onTap: () {
                  controller.saveCover();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}