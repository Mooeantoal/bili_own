import 'package:bili_own/common/utils/bvid_avid_util.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoPlayerTestPage extends StatelessWidget {
  const VideoPlayerTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放器测试'),
      ),
      body: const VideoPlayerTestContent(),
    );
  }
}

class VideoPlayerTestContent extends StatefulWidget {
  const VideoPlayerTestContent({Key? key}) : super(key: key);

  @override
  State<VideoPlayerTestContent> createState() => _VideoPlayerTestContentState();
}

class _VideoPlayerTestContentState extends State<VideoPlayerTestContent> {
  late BiliVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // 初始化播放器控制器，使用测试视频
    _controller = BiliVideoPlayerController(
      bvid: BvidAvidUtil.av2Bvid(170001), // 测试视频BV号
      cid: 279786, // 测试视频CID
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: BiliVideoPlayerWidget(
          _controller,
          heroTagId: 999,
          buildControllPanel: () {
            return BiliVideoPlayerPanel(
              BiliVideoPlayerPanelController(_controller),
            );
          },
        ),
      ),
    );
  }
}