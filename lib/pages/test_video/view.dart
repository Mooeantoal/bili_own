import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'widgets/test_video_player.dart';
import 'widgets/test_danmaku.dart';
import 'widgets/test_reply.dart';

class TestVideoPage extends StatefulWidget {
  const TestVideoPage({Key? key}) : super(key: key);

  @override
  State<TestVideoPage> createState() => _TestVideoPageState();
}

class _TestVideoPageState extends State<TestVideoPage> {
  late TestVideoController controller;
  late TestVideoPlayerController playerController;
  late TestDanmakuController danmakuController;

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
          ],
        ),
      ),
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
}