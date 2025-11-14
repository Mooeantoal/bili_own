import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/utils/string_format_utils.dart';
import 'package:bili_own/common/widget/icon_text_button.dart';

import 'controller.dart';
import 'widgets/test_video_player.dart';
import 'widgets/test_danmaku.dart';
import 'widgets/test_reply.dart';
import 'widgets/test_video_player_panel.dart';
import 'widgets/test_danmaku_panel.dart';
import 'widgets/video_detail_page.dart';
import 'widgets/log_viewer.dart'; // 导入日志查看器

class TestVideoPage extends StatefulWidget {
  const TestVideoPage({Key? key}) : super(key: key);

  @override
  State<TestVideoPage> createState() => _TestVideoPageState();
}

class _TestVideoPageState extends State<TestVideoPage> {
  late TestVideoController controller;
  late TestVideoPlayerController playerController;
  late TestDanmakuController danmakuController;
  
  // 控制播放器面板和弹幕面板的显示状态
  final RxBool _showPlayerPanel = true.obs;
  final RxBool _showDanmakuPanel = true.obs;

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
        title: const Text('测试视频页面'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '移植测试页面',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '此页面用于测试从bilimiao项目移植的功能',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // 视频信息展示区域
            _buildVideoInfoSection(),
            const SizedBox(height: 20),
            // 操作按钮区域
            _buildOperationButtons(),
            const SizedBox(height: 20),
            // 日志查看器按钮
            ElevatedButton(
              onPressed: () {
                // 打开日志查看器
                Get.to(() => const LogViewer());
              },
              child: const Text('查看应用日志'),
            ),
            const SizedBox(height: 20),
            // 测试功能按钮
            ElevatedButton(
              onPressed: () {
                // 测试播放器功能
                _showVideoPlayerTest();
              },
              child: const Text('测试播放器功能'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 测试弹幕功能
                _showDanmakuTest();
              },
              child: const Text('测试弹幕功能'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 测试评论功能
                _showReplyTest();
              },
              child: const Text('测试评论功能'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 显示完整的视频详情页面测试
                _showFullVideoDetailTest();
              },
              child: const Text('完整视频详情页面测试'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 显示bilimiao风格的视频详情页面
                Get.to(() => const VideoDetailPage());
              },
              child: const Text('Bilimiao风格视频详情页面'),
            ),
          ],
        ),
      ),
    );
  }

  // 构建视频信息展示区域
  Widget _buildVideoInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
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
          const Text(
            'BV14L411k7zn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
          const Text(
            '这是一个测试视频的简介内容，用于展示从bilimiao项目移植的视频详情功能。',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 构建操作按钮区域
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

  // 显示视频播放器测试
  void _showVideoPlayerTest() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '视频播放器测试',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // 使用真实的视频进行测试
              Expanded(
                child: TestVideoPlayerWidget(
                  bvid: 'BV14L411k7zn', // 示例BVID
                  cid: 1053323351, // 示例CID
                  aspectRatio: 16 / 9,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示弹幕测试
  void _showDanmakuTest() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '弹幕功能测试',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    // 视频播放器占位符
                    Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          '视频播放区域',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // 弹幕层
                    TestDanmaku(controller: danmakuController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示评论测试
  void _showReplyTest() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '评论功能测试',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: TestReplyPage(),
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示完整的视频详情页面测试（整合播放器、弹幕、评论）
  void _showFullVideoDetailTest() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '完整视频详情页面测试',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // 视频播放器区域
              Expanded(
                flex: 3,
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
              ),
              const SizedBox(height: 16),
              // 评论区域
              Expanded(
                flex: 2,
                child: TestReplyPage(),
              ),
            ],
          ),
        );
      },
    );
  }
}