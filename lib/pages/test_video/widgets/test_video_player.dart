// 测试视频播放器组件，用于移植bilimiao项目的播放器功能
import 'dart:async';
import 'package:bili_own/common/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:bili_own/common/api/video_play_api.dart';
import 'package:bili_own/common/models/local/video/video_play_info.dart';
import 'package:bili_own/common/models/local/video/video_play_item.dart';
import 'package:bili_own/common/models/local/video/audio_play_item.dart';
import 'package:bili_own/common/widget/video_audio_player.dart';
import 'package:bili_own/common/models/network/video_play/video_play.dart';

class TestVideoPlayerWidget extends StatefulWidget {
  final String bvid;
  final int cid;
  final double aspectRatio;
  final bool autoPlay;

  const TestVideoPlayerWidget({
    Key? key,
    required this.bvid,
    required this.cid,
    this.aspectRatio = 16 / 9,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<TestVideoPlayerWidget> createState() => _TestVideoPlayerWidgetState();
}

class _TestVideoPlayerWidgetState extends State<TestVideoPlayerWidget> {
  late TestVideoPlayerController _controller;
  late Future<bool> _loadVideoFuture;

  @override
  void initState() {
    super.initState();
    appLog("初始化TestVideoPlayerWidget");
    _controller = TestVideoPlayerController(widget.autoPlay);
    // 添加测试日志
    appLog("TestVideoPlayerWidget初始化完成");
    _loadVideoFuture = _controller.loadVideoInfo(widget.bvid, widget.cid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loadVideoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('加载视频失败: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () {
                    // 重新加载
                    setState(() {
                      _loadVideoFuture = _controller.loadVideoInfo(widget.bvid, widget.cid);
                    });
                  },
                  child: const Text('重新加载'),
                ),
              ],
            ),
          );
        } else if (!(snapshot.data ?? false)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('加载视频失败'),
                ElevatedButton(
                  onPressed: () {
                    // 重新加载
                    setState(() {
                      _loadVideoFuture = _controller.loadVideoInfo(widget.bvid, widget.cid);
                    });
                  },
                  child: const Text('重新加载'),
                ),
              ],
            ),
          );
        } else {
          return AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: VideoAudioPlayer(_controller._videoAudioController),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class TestVideoPlayerController {
  VideoPlayInfo? videoPlayInfo;
  VideoPlayItem? _videoPlayItem;
  AudioPlayItem? _audioPlayItem;
  final VideoAudioController _videoAudioController;
  
  // 添加bvid和cid属性
  String? bvid;
  int? cid;
  
  // 播放器状态
  bool _isLocked = false;
  bool get isLocked => _isLocked;
  
  // 播放速度
  double _playSpeed = 1.0;
  double get playSpeed => _playSpeed;
  
  // 音频焦点
  bool _enabledAudioFocus = true;
  bool get enabledAudioFocus => _enabledAudioFocus;
  
  // 弹幕开关
  bool _showDanmaku = true;
  bool get showDanmaku => _showDanmaku;
  
  // 字幕开关
  bool _showSubtitle = false;
  bool get showSubtitle => _showSubtitle;
  
  TestVideoPlayerController(bool autoPlay)
      : _videoAudioController = VideoAudioController(
          autoWakelock: true,
          initStart: autoPlay,
        ) {
    appLog("初始化TestVideoPlayerController, autoPlay=$autoPlay");
  }

  String get videoUrl => _videoPlayItem?.urls.first ?? '';
  String get audioUrl => _audioPlayItem?.urls.first ?? '';
  
  Duration get position => _videoAudioController.state.position;
  Duration get duration => _videoAudioController.state.duration;
  double get speed => _videoAudioController.state.speed;
  bool get isPlaying => _videoAudioController.state.isPlaying;
  Duration get fartherestBuffered => _videoAudioController.state.buffered;
  
  double get videoAspectRatio {
    final width = _videoAudioController.state.width;
    final height = _videoAudioController.state.height;
    if (width > 0 && height > 0) {
      return width / height;
    }
    return 16 / 9; // 默认宽高比
  }
  
  // 添加videoPlayItem getter
  VideoPlayItem? get videoPlayItem => _videoPlayItem;
  
  // 添加audioPlayItem getter
  AudioPlayItem? get audioPlayItem => _audioPlayItem;
  
  // 添加videoPlayInfo getter
  VideoPlayInfo? get videoPlayInfoGetter => videoPlayInfo;
  
  // 添加hasError getter
  bool get hasError => _videoAudioController.state.hasError;

  Future<void> initPlayer(String bvid, int cid) async {
    // 初始化播放器逻辑
    this.bvid = bvid;
    this.cid = cid;
  }

  Future<bool> loadVideoInfo(String bvid, int cid) async {
    appLog("开始加载视频信息: bvid=$bvid, cid=$cid");
    try {
      // 添加测试日志
      appLog("调用VideoPlayApi.getVideoPlay获取视频播放信息");
      final VideoPlayInfo videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      appLog("成功获取视频播放信息: ${videoPlayInfo.lastPlayTime.inSeconds}秒");
      
      // 保存视频信息
      this.videoPlayInfo = videoPlayInfo;
      
      // 添加测试日志
      appLog("VideoPlayInfo创建完成: 视频时长=${videoPlayInfo.timeLength}秒");

      if (videoPlayInfo == null || (videoPlayInfo.videos.isEmpty && videoPlayInfo.audios.isEmpty)) {
        appLog("bili_video_player.loadVideo: videoPlayInfo is null or both videos and audios are empty");
        // 添加更详细的日志信息
        if (videoPlayInfo == null) {
          appLog("videoPlayInfo为null");
        } else {
          appLog("videos长度: ${videoPlayInfo.videos.length}, audios长度: ${videoPlayInfo.audios.length}");
        }
        return false;
      }
      
      if (_videoPlayItem == null && videoPlayInfo.videos.isNotEmpty) {
        // 根据偏好选择画质
        List<VideoPlayItem> tempMatchVideos = [];
        // 先匹配编码
        for (var i in videoPlayInfo.videos) {
          // 简化处理，选择第一个视频
          tempMatchVideos.add(i);
        }
        
        if (tempMatchVideos.isNotEmpty) {
          _videoPlayItem = tempMatchVideos.first;
          appLog("选择视频画质: quality=${_videoPlayItem?.quality}, codecs=${_videoPlayItem?.codecs}, url=${_videoPlayItem?.urls.first}");
        }
      } else if (videoPlayInfo.videos.isEmpty) {
        _videoPlayItem = null;
        appLog("没有视频信息");
      } else {
        appLog("使用已选择的视频画质: quality=${_videoPlayItem?.quality}");
      }
      
      if (_audioPlayItem == null && videoPlayInfo.audios.isNotEmpty) {
        // 选择第一个音频作为默认
        _audioPlayItem = videoPlayInfo.audios.first;
        appLog("选择音频音质: quality=${_audioPlayItem?.quality}, codecs=${_audioPlayItem?.codecs}, url=${_audioPlayItem?.urls.first}");
      } else if (videoPlayInfo.audios.isEmpty) {
        _audioPlayItem = null;
        appLog("没有音频信息");
      } else {
        appLog("使用已选择的音频音质: quality=${_audioPlayItem?.quality}");
      }
      
      // 设置播放器URL
      if (_videoPlayItem != null) {
        _videoAudioController.videoUrl = _videoPlayItem!.urls.first;
        appLog("设置视频URL: ${_videoPlayItem!.urls.first}");
      }
      
      if (_audioPlayItem != null) {
        _videoAudioController.audioUrl = _audioPlayItem!.urls.first;
        appLog("设置音频URL: ${_audioPlayItem!.urls.first}");
      }
      
      // 设置视频时长（在刷新播放器之前设置）
      Duration savedDuration = Duration.zero;
      if (videoPlayInfo != null && videoPlayInfo.timeLength > 0) {
        savedDuration = Duration(seconds: videoPlayInfo.timeLength);
        _videoAudioController.state.duration = savedDuration;
        appLog("设置视频时长: ${_videoAudioController.state.duration}");
      } else {
        appLog("视频时长信息不可用或为零");
      }
      
      // 刷新播放器
      appLog("开始刷新播放器");
      await _videoAudioController.refresh();
      appLog("播放器刷新完成");
      
      // 如果播放器没有正确设置duration，使用我们手动设置的值
      appLog("检查播放器时长设置: 当前时长=${_videoAudioController.state.duration.inMilliseconds}ms, 保存的时长=${savedDuration.inMilliseconds}ms");
      if (_videoAudioController.state.duration.inMilliseconds == 0 && 
          savedDuration.inMilliseconds > 0) {
        _videoAudioController.state.duration = savedDuration;
        appLog("重新设置视频时长: ${_videoAudioController.state.duration}");
      }
      
      appLog("视频信息加载完成");
      return true;
    } catch (e, stackTrace) {
      appLog("加载视频信息失败: $e");
      appLog("错误堆栈: $stackTrace");
      return false;
    }
  }

  // 添加pause方法
  Future<void> pause() async {
    await _videoAudioController.pause();
  }
  
  // 添加play方法
  Future<void> play() async {
    await _videoAudioController.play();
  }
  
  // 添加seekTo方法
  Future<void> seekTo(Duration position) async {
    await _videoAudioController.seekTo(position);
  }
  
  // 添加setPlaybackSpeed方法
  Future<void> setPlayBackSpeed(double speed) async {
    await _videoAudioController.setPlayBackSpeed(speed);
  }
  
  // 添加changeVideoItem方法
  void changeVideoItem(VideoPlayItem item) {
    _videoPlayItem = item;
    _videoAudioController.videoUrl = item.urls.first;
    // 刷新播放器以应用新的视频URL
    _videoAudioController.refresh();
  }
  
  // 添加changeAudioItem方法
  void changeAudioItem(AudioPlayItem item) {
    _audioPlayItem = item;
    _videoAudioController.audioUrl = item.urls.first;
    // 刷新播放器以应用新的音频URL
    _videoAudioController.refresh();
  }
  
  // 添加全屏切换方法
  void toggleFullScreen() {
    // 这里可以添加全屏切换的逻辑
    // 目前留空，因为具体实现可能依赖于外部组件
  }
  
  // 添加reloadWidget方法
  Future<void> reloadWidget() async {
    // 重新加载widget的逻辑
    // 这里可以添加重新加载视频的逻辑
    if (bvid != null && cid != null) {
      await loadVideoInfo(bvid!, cid!);
    }
  }

  void dispose() {
    _videoAudioController.dispose();
  }
  
  // 添加addListener方法
  void addListener(VoidCallback listener) {
    _videoAudioController.addListener(listener);
  }
  
  // 添加removeListener方法
  void removeListener(VoidCallback listener) {
    _videoAudioController.removeListener(listener);
  }
  
  // 添加addStateChangedListener方法
  void addStateChangedListener(Function(VideoAudioState) listener) {
    _videoAudioController.addStateChangedListener(listener);
  }
  
  // 添加removeStateChangedListener方法
  void removeStateChangedListener(Function(VideoAudioState) listener) {
    _videoAudioController.removeStateChangedListener(listener);
  }
  
  // 添加addSeekToListener方法
  void addSeekToListener(Function(Duration) listener) {
    _videoAudioController.addSeekToListener(listener);
  }
  
  // 添加removeSeekToListener方法
  void removeSeekToListener(Function(Duration) listener) {
    _videoAudioController.removeSeekToListener(listener);
  }
  
  // 锁定/解锁播放器
  void toggleLock() {
    _isLocked = !_isLocked;
  }
  
  // 设置播放速度
  Future<void> setPlaySpeed(double speed) async {
    _playSpeed = speed;
    await _videoAudioController.setPlayBackSpeed(speed);
  }
  
  // 切换弹幕显示
  void toggleDanmaku() {
    _showDanmaku = !_showDanmaku;
  }
  
  // 切换字幕显示
  void toggleSubtitle() {
    _showSubtitle = !_showSubtitle;
  }
  
  // 音频焦点控制
  void setEnabledAudioFocus(bool enabled) {
    _enabledAudioFocus = enabled;
  }
  
  // 长按倍速播放
  Future<void> startLongPressSpeedPlay() async {
    _playSpeed *= 2;
    await _videoAudioController.setPlayBackSpeed(_playSpeed);
  }
  
  Future<void> stopLongPressSpeedPlay() async {
    _playSpeed /= 2;
    await _videoAudioController.setPlayBackSpeed(_playSpeed);
  }
  
  // 添加更多播放器控制方法，模仿bilimiao项目的功能
  Future<void> setVideoQuality(VideoQuality quality) async {
    // 根据质量选择视频
    final video = videoPlayInfo?.videos.firstWhere(
      (element) => element.quality == quality,
      orElse: () => videoPlayInfo!.videos.first,
    );
    
    if (video != null) {
      changeVideoItem(video);
    }
  }
  
  Future<void> setAudioQuality(AudioQuality quality) async {
    // 根据质量选择音频
    final audio = videoPlayInfo?.audios.firstWhere(
      (element) => element.quality == quality,
      orElse: () => videoPlayInfo!.audios.first,
    );
    
    if (audio != null) {
      changeAudioItem(audio);
    }
  }
  
  // 获取支持的视频质量列表
  List<VideoQuality> getSupportVideoQualities() {
    return videoPlayInfo?.supportVideoQualities ?? [];
  }
  
  // 获取支持的音频质量列表
  List<AudioQuality> getSupportAudioQualities() {
    return videoPlayInfo?.supportAudioQualities ?? [];
  }
  
  // 获取当前视频质量
  VideoQuality? getCurrentVideoQuality() {
    return _videoPlayItem?.quality;
  }
  
  // 获取当前音频质量
  AudioQuality? getCurrentAudioQuality() {
    return _audioPlayItem?.quality;
  }
}