// 测试视频播放器面板，用于移植bilimiao项目的播放器控制面板功能
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/utils/string_format_utils.dart';
import 'package:bili_own/common/widget/icon_text_button.dart';
import 'package:bili_own/common/models/local/video/video_play_item.dart';
import 'package:bili_own/common/models/local/video/audio_play_item.dart';

import 'test_video_player.dart';

class TestVideoPlayerPanel extends StatefulWidget {
  final TestVideoPlayerController controller;
  
  const TestVideoPlayerPanel({Key? key, required this.controller}) : super(key: key);

  @override
  State<TestVideoPlayerPanel> createState() => _TestVideoPlayerPanelState();
}

class _TestVideoPlayerPanelState extends State<TestVideoPlayerPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部控制栏
          _buildTopControlBar(),
          const SizedBox(height: 8),
          // 底部控制栏
          _buildBottomControlBar(),
          const SizedBox(height: 8),
          // 进度条
          _buildProgressBar(),
        ],
      ),
    );
  }

  // 构建顶部控制栏
  Widget _buildTopControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 返回按钮
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        // 标题
        const Expanded(
          child: Text(
            '测试视频',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 更多按钮
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  // 构建底部控制栏
  Widget _buildBottomControlBar() {
    final TextStyle operationButtonTextStyle = const TextStyle(
      fontSize: 10,
      color: Colors.white,
    );
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 播放/暂停按钮
        IconButton(
          icon: Icon(
            widget.controller.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () {
            if (widget.controller.isPlaying) {
              widget.controller.pause();
            } else {
              widget.controller.play();
            }
          },
        ),
        // 弹幕开关
        Obx(() => IconTextButton(
          selected: widget.controller.showDanmaku,
          icon: const Icon(Icons.comment, size: 20, color: Colors.white),
          text: Text(
            "弹幕",
            style: operationButtonTextStyle,
          ),
          onPressed: widget.controller.toggleDanmaku,
        )),
        // 字幕开关
        Obx(() => IconTextButton(
          selected: widget.controller.showSubtitle,
          icon: const Icon(Icons.subtitles, size: 20, color: Colors.white),
          text: Text(
            "字幕",
            style: operationButtonTextStyle,
          ),
          onPressed: widget.controller.toggleSubtitle,
        )),
        // 倍速按钮
        Obx(() => IconTextButton(
          icon: const Icon(Icons.speed, size: 20, color: Colors.white),
          text: Text(
            "x${widget.controller.playSpeed.toStringAsFixed(1)}",
            style: operationButtonTextStyle,
          ),
          onPressed: _showSpeedOptions,
        )),
        // 锁定按钮
        Obx(() => IconTextButton(
          selected: widget.controller.isLocked,
          icon: const Icon(Icons.lock, size: 20, color: Colors.white),
          text: Text(
            "锁定",
            style: operationButtonTextStyle,
          ),
          onPressed: widget.controller.toggleLock,
        )),
        // 全屏按钮
        IconButton(
          icon: const Icon(Icons.fullscreen, color: Colors.white),
          onPressed: widget.controller.toggleFullScreen,
        ),
      ],
    );
  }

  // 构建进度条
  Widget _buildProgressBar() {
    return Row(
      children: [
        // 当前时间
        Text(
          StringFormatUtils.timeLengthFormat(widget.controller.position.inMilliseconds ~/ 1000),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(width: 8),
        // 进度条
        Expanded(
          child: Slider(
            value: widget.controller.duration.inMilliseconds > 0
                ? widget.controller.position.inMilliseconds /
                    widget.controller.duration.inMilliseconds
                : 0.0,
            onChanged: (value) {
              final duration = widget.controller.duration;
              final newPosition = Duration(
                milliseconds: (duration.inMilliseconds * value).toInt(),
              );
              widget.controller.seekTo(newPosition);
            },
            activeColor: Colors.white,
            inactiveColor: Colors.white30,
          ),
        ),
        const SizedBox(width: 8),
        // 总时间
        Text(
          StringFormatUtils.timeLengthFormat(widget.controller.duration.inMilliseconds ~/ 1000),
          style: const TextStyle(color: Colors.white, fontSize: 12),
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
                leading: const Icon(Icons.high_quality),
                title: const Text('画质'),
                trailing: const Icon(Icons.arrow_right),
                onTap: _showQualityOptions,
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text('音质'),
                trailing: const Icon(Icons.arrow_right),
                onTap: _showAudioOptions,
              ),
              ListTile(
                leading: const Icon(Icons.subtitles),
                title: const Text('字幕'),
                trailing: const Icon(Icons.arrow_right),
                onTap: _showSubtitleOptions,
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('定时停止'),
                trailing: const Icon(Icons.arrow_right),
                onTap: _showTimerOptions,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('播放设置'),
                trailing: const Icon(Icons.arrow_right),
                onTap: _showPlayerSettings,
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示倍速选项
  void _showSpeedOptions() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '播放速度',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: speeds.map((speed) {
                  return ChoiceChip(
                    label: Text('${speed}x'),
                    selected: widget.controller.playSpeed == speed,
                    selectedColor: Colors.blue,
                    onSelected: (selected) {
                      if (selected) {
                        widget.controller.setPlaySpeed(speed);
                        Navigator.of(context).pop();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示画质选项
  void _showQualityOptions() {
    final qualities = widget.controller.getSupportVideoQualities();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '画质选择',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: qualities.length,
                itemBuilder: (context, index) {
                  final quality = qualities[index];
                  final isSelected = widget.controller.getCurrentVideoQuality() == quality;
                  return ListTile(
                    title: Text(quality.description),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      widget.controller.setVideoQuality(quality);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示音质选项
  void _showAudioOptions() {
    final qualities = widget.controller.getSupportAudioQualities();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '音质选择',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: qualities.length,
                itemBuilder: (context, index) {
                  final quality = qualities[index];
                  final isSelected = widget.controller.getCurrentAudioQuality() == quality;
                  return ListTile(
                    title: Text(quality.description),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      widget.controller.setAudioQuality(quality);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示字幕选项
  void _showSubtitleOptions() {
    // TODO: 实现字幕选项
    Get.snackbar('提示', '字幕选项功能待实现');
  }

  // 显示定时停止选项
  void _showTimerOptions() {
    // TODO: 实现定时停止选项
    Get.snackbar('提示', '定时停止功能待实现');
  }

  // 显示播放器设置
  void _showPlayerSettings() {
    // TODO: 实现播放器设置
    Get.snackbar('提示', '播放器设置功能待实现');
  }
}