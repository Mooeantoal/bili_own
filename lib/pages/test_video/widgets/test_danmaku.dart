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
  
  // 弹幕透明度
  double _danmakuOpacity = 1.0;
  double get danmakuOpacity => _danmakuOpacity;
  
  // 弹幕大小
  double _danmakuSize = 1.0;
  double get danmakuSize => _danmakuSize;
  
  // 弹幕区域
  double _danmakuArea = 1.0;
  double get danmakuArea => _danmakuArea;
  
  // 弹幕速度
  double _danmakuSpeed = 1.0;
  double get danmakuSpeed => _danmakuSpeed;

  void toggleDanmaku() {
    _isDanmakuOpened = !_isDanmakuOpened;
    clearAllDanmaku?.call();
  }
  
  // 设置弹幕透明度
  void setDanmakuOpacity(double opacity) {
    _danmakuOpacity = opacity;
    // TODO: 更新弹幕透明度
  }
  
  // 设置弹幕大小
  void setDanmakuSize(double size) {
    _danmakuSize = size;
    // TODO: 更新弹幕大小
  }
  
  // 设置弹幕区域
  void setDanmakuArea(double area) {
    _danmakuArea = area;
    // TODO: 更新弹幕区域
  }
  
  // 设置弹幕速度
  void setDanmakuSpeed(double speed) {
    _danmakuSpeed = speed;
    // TODO: 更新弹幕速度
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
  
  // 暂停弹幕
  void pauseDanmaku() {
    // TODO: 实现暂停弹幕逻辑
  }
  
  // 恢复弹幕
  void resumeDanmaku() {
    // TODO: 实现恢复弹幕逻辑
  }
  
  // 清除所有弹幕
  void clearAllDanmakuItems() {
    clearAllDanmaku?.call();
  }
  
  // 添加更多弹幕控制方法，模仿bilimiao项目的功能
  // 设置弹幕颜色
  void setDanmakuColor(Color color) {
    // TODO: 实现弹幕颜色设置
  }
  
  // 设置弹幕类型
  void setDanmakuType(int type) {
    // TODO: 实现弹幕类型设置
  }
  
  // 获取弹幕颜色列表
  List<Color> getDanmakuColors() {
    return [
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];
  }
  
  // 获取弹幕类型列表
  List<String> getDanmakuTypes() {
    return [
      "滚动",
      "顶部",
      "底部",
    ];
  }
  
  // 根据字符串获取弹幕类型
  int getDanmakuTypeFromString(String type) {
    switch (type) {
      case "顶部":
        return 5; // 顶部弹幕
      case "底部":
        return 4; // 底部弹幕
      default:
        return 1; // 滚动弹幕
    }
  }
  
  // 发送弹幕
  Future<void> sendDanmaku(String text, Color color, int type) async {
    // TODO: 实现弹幕发送逻辑
    // 这里可以调用API发送弹幕到服务器
  }
  
  // 获取弹幕开关状态
  bool getDanmakuSwitchStatus() {
    return _isDanmakuOpened;
  }
  
  // 设置弹幕开关状态
  void setDanmakuSwitchStatus(bool status) {
    _isDanmakuOpened = status;
    clearAllDanmaku?.call();
  }
}