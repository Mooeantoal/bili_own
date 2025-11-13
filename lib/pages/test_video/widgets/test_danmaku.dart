// 测试弹幕组件，用于移植bilimiao项目的弹幕功能
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ns_danmaku/danmaku_controller.dart';
import 'package:ns_danmaku/danmaku_view.dart';
import 'package:ns_danmaku/models/danmaku_item.dart';
import 'package:ns_danmaku/models/danmaku_option.dart';
import 'package:bili_own/common/api/player_api.dart';
import 'package:bili_own/common/models/network/proto/danmaku/danmaku.pb.dart';

import 'test_video_player.dart';
import 'package:bili_own/common/widget/video_audio_player.dart';

class TestDanmaku extends StatefulWidget {
  const TestDanmaku({super.key, required this.controller});

  final TestDanmakuController controller;

  @override
  State<TestDanmaku> createState() => _TestDanmakuState();
}

class _TestDanmakuState extends State<TestDanmaku> {
  DanmakuController? danmakuController;
  bool isListenerLocked = false;
  bool isPlaying = true;
  
  void videoPlayerStateChangedCallback(VideoAudioState value) {
    if (value.isBuffering || !value.isPlaying) {
      danmakuController?.pause();
    } else if (value.isPlaying) {
      danmakuController?.resume();
    }
  }

  void videoPlayerSeekToCallback(Duration position) {
    danmakuController?.clear();
    // TODO: 实现弹幕位置查找逻辑
  }

  void videoPlayerListenerCallback() {
    if (!widget.controller.isDanmakuOpened) {
      danmakuController?.clear();
    }
    // TODO: 实现弹幕添加逻辑
  }

  void addAllListeners() {
    var controller = widget.controller;
    controller.testVideoPlayerController
        .addListener(videoPlayerListenerCallback);
    controller.testVideoPlayerController
        .addStateChangedListener(videoPlayerStateChangedCallback);
    controller.testVideoPlayerController
        .addSeekToListener(videoPlayerSeekToCallback);
  }

  void removeAllListeners() {
    var controller = widget.controller;
    controller.testVideoPlayerController
        .removeListener(videoPlayerListenerCallback);
    controller.testVideoPlayerController
        .removeSeekToListener(videoPlayerSeekToCallback);
    controller.testVideoPlayerController
        .removeStateChangedListener(videoPlayerStateChangedCallback);
  }

  @override
  void initState() {
    var controller = widget.controller;
    if (!controller._isInitializedState) {
      controller._isDanmakuOpened = true;
      controller.reloadDanmaku = () {
        // TODO: 实现弹幕重新加载逻辑
        if (mounted) {
          setState(() {});
        }
      };
    }
    controller._isInitializedState = true;

    addAllListeners();
    super.initState();
  }

  @override
  void dispose() {
    // 在dispose时清除弹幕控制器
    danmakuController?.clear();
    danmakuController = null;
    removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      widget.controller.initDuration = box.maxWidth / 80;
      return DanmakuView(
        createdController: (danmakuController) async {
          // TODO: 实现弹幕初始化逻辑
          this.danmakuController = danmakuController;
        },
        option: DanmakuOption(
            area: 0.5,
            duration: widget.controller.initDuration /
                widget.controller.testVideoPlayerController.speed),
        statusChanged: (isPlaying) {
          this.isPlaying = isPlaying;
        },
      );
    });
  }
}

class TestDanmakuController {
  TestDanmakuController(this.testVideoPlayerController);
  final TestVideoPlayerController testVideoPlayerController;
  int segmentCount = 1;
  int currentIndex = 0;
  int currentSegmentIndex = 0;
  double initDuration = 0;
  // 弹幕数据列表
  List<DmSegMobileReply> dmSegList = [];
  bool _isInitializedState = false;
  bool _isInitialized = false;

  void Function()? clearAllDanmaku;
  void Function()? reloadDanmaku;

  bool _isDanmakuOpened = true;
  bool get isDanmakuOpened => _isDanmakuOpened;

  void toggleDanmaku() {
    _isDanmakuOpened = !_isDanmakuOpened;
    clearAllDanmaku?.call();
  }
  
  // 添加弹幕项
  void addDanmakuItem(DanmakuItem item) {
    // TODO: 实现添加弹幕项逻辑
  }
  
  // 加载弹幕数据
  Future<void> loadDanmaku(int cid) async {
    try {
      // 计算分段数
      // 假设视频时长为testVideoPlayerController.duration
      segmentCount = (testVideoPlayerController.duration.inSeconds / 360).ceil();
      
      // 加载每个分段的弹幕
      for (int segmentIndex = 1; segmentIndex <= segmentCount; segmentIndex++) {
        var response = await PlayerApi.getDanmakuList(
          cid: cid,
          segmentIndex: segmentIndex,
        );
        
        // 对弹幕按时间排序
        response.elems.sort((a, b) {
          return a.progress.compareTo(b.progress);
        });
        
        dmSegList.add(response);
      }
      
      _isInitialized = true;
    } catch (e) {
      log("加载弹幕失败: $e");
    }
  }
}