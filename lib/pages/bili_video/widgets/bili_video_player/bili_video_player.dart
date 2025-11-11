import 'dart:io' show Platform;

import 'package:bili_own/common/models/local/video/audio_play_item.dart';
import 'package:bili_own/common/models/local/video/video_play_item.dart';
import 'package:bili_own/common/models/local/video/video_play_info.dart';
import 'package:bili_own/common/widget/video_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback, SystemChrome, SystemUiMode, DeviceOrientation;

import 'package:bili_own/common/api/video_play_api.dart';

import 'bili_danmaku.dart';
import 'bili_video_player_panel.dart';

class BiliVideoPlayerController {
  BiliVideoPlayerController({
    required this.videoPlayInfo,
    required this.bvid,
    required this.cid,
  });

  final VideoPlayInfo videoPlayInfo;
  String bvid;
  int cid;

  VideoAudioController? _videoAudioController;
  BiliDanmakuController? biliDanmakuController;

  VideoPlayItem? videoPlayItem;
  AudioPlayItem? audioPlayItem;

  bool get isPlaying => _videoAudioController?.state.isPlaying ?? false;
  bool get hasError => _videoAudioController?.state.hasError ?? false;
  Duration get position => _videoAudioController?.state.position ?? Duration.zero;
  Duration get duration => _videoAudioController?.state.duration ?? Duration.zero;
  Duration get fartherestBuffered => _videoAudioController?.state.buffered ?? Duration.zero;
  double get speed => _videoAudioController?.state.speed ?? 1.0;
  double get videoAspectRatio =>
      (_videoAudioController?.state.width ?? 1) / (_videoAudioController?.state.height ?? 1);

  Future<void> init() async {
    // 初始化视频和音频播放项
    if (videoPlayInfo.videos.isNotEmpty) {
      videoPlayItem = videoPlayInfo.videos.first;
    }
    if (videoPlayInfo.audios.isNotEmpty) {
      audioPlayItem = videoPlayInfo.audios.first;
    }

    // 创建视频音频控制器
    _videoAudioController = VideoAudioController(
      videoUrl: videoPlayItem?.urls.first ?? '',
      audioUrl: audioPlayItem?.urls.first ?? '',
      videoHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      audioHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      autoWakelock: true,
      initStart: true,
    );

    // 初始化控制器
    await _videoAudioController!.init();
  }

  Future<void> play() async {
    await _videoAudioController?.play();
  }

  Future<void> pause() async {
    await _videoAudioController?.pause();
  }

  Future<void> seekTo(Duration position) async {
    await _videoAudioController?.seekTo(position);
  }

  Future<void> setPlayBackSpeed(double speed) async {
    await _videoAudioController?.setPlayBackSpeed(speed);
  }

  Future<void> reloadWidget() async {
    await _videoAudioController?.dispose();
    await init();
  }

  Future<void> refreshPlayer() async {
    await _videoAudioController?.refresh();
  }

  Future<void> changeVideoItem(VideoPlayItem item) async {
    videoPlayItem = item;
    await _videoAudioController?.dispose();
    _videoAudioController = VideoAudioController(
      videoUrl: item.urls.first,
      audioUrl: audioPlayItem?.urls.first ?? '',
      videoHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      audioHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      autoWakelock: true,
    );
    await _videoAudioController!.refresh();
  }

  Future<void> changeAudioItem(AudioPlayItem item) async {
    audioPlayItem = item;
    await _videoAudioController?.dispose();
    _videoAudioController = VideoAudioController(
      videoUrl: videoPlayItem?.urls.first ?? '',
      audioUrl: item.urls.first,
      videoHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      audioHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      autoWakelock: true,
    );
    await _videoAudioController!.refresh();
  }

  Future<void> changeCid(String bvid, int cid) async {
    this.bvid = bvid;
    this.cid = cid;
    await _videoAudioController?.dispose();
    // 重新获取视频播放信息
    final videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
    if (videoPlayInfo.videos.isNotEmpty) {
      videoPlayItem = videoPlayInfo.videos.first;
    }
    if (videoPlayInfo.audios.isNotEmpty) {
      audioPlayItem = videoPlayInfo.audios.first;
    }
    _videoAudioController = VideoAudioController(
      videoUrl: videoPlayItem?.urls.first ?? '',
      audioUrl: audioPlayItem?.urls.first ?? '',
      videoHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      audioHeaders: VideoPlayApi.videoPlayerHttpHeaders,
      autoWakelock: true,
    );
    await _videoAudioController!.refresh();
  }

  void addStateChangedListener(Function(VideoAudioState state) listener) {
    _videoAudioController?.addStateChangedListener(listener);
  }

  void removeStateChangedListener(Function(VideoAudioState state) listener) {
    _videoAudioController?.removeStateChangedListener(listener);
  }

  void addListener(VoidCallback listener) {
    _videoAudioController?.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _videoAudioController?.removeListener(listener);
  }

  void addSeekToListener(Function(Duration position) listener) {
    _videoAudioController?.addSeekToListener(listener);
  }

  void removeSeekToListener(Function(Duration position) listener) {
    _videoAudioController?.removeSeekToListener(listener);
  }

  Future<void> dispose() async {
    await _videoAudioController?.dispose();
  }
}

class BiliVideoPlayer extends StatefulWidget {
  const BiliVideoPlayer({
    Key? key,
    required this.videoPlayInfo,
    required this.bvid,
    required this.cid,
  }) : super(key: key);

  final VideoPlayInfo videoPlayInfo;
  final String bvid;
  final int cid;

  @override
  State<BiliVideoPlayer> createState() => _BiliVideoPlayerState();
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  late final BiliVideoPlayerController _biliVideoPlayerController;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    _biliVideoPlayerController = BiliVideoPlayerController(
      videoPlayInfo: widget.videoPlayInfo,
      bvid: widget.bvid,
      cid: widget.cid,
    );
    
    // 初始化播放器
    Future.microtask(() async {
      await _biliVideoPlayerController.init();
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> toggleFullScreen() async {
    if (_isFullScreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BiliVideoPlayerWidget(
        _biliVideoPlayerController,
        buildControllPanel: () {
          final panelController = BiliVideoPlayerPanelController(_biliVideoPlayerController);
          return BiliVideoPlayerPanel(
            controller: panelController,
          );
        },
        buildDanmaku: () {
          return BiliDanmaku(
            controller: BiliDanmakuController(_biliVideoPlayerController),
          );
        },
        onToggleFullScreen: toggleFullScreen,
      ),
    );
  }

  @override
  void dispose() {
    _biliVideoPlayerController.dispose();
    super.dispose();
  }
}

// BiliVideoPlayerWidget类定义
class BiliVideoPlayerWidget extends StatefulWidget {
  const BiliVideoPlayerWidget(
    this.controller, {
    Key? key,
    this.heroTagId,
    this.buildControllPanel,
    this.buildDanmaku,
    this.onToggleFullScreen,
  }) : super(key: key);

  final BiliVideoPlayerController controller;
  final int? heroTagId;
  final Widget Function()? buildControllPanel;
  final Widget Function()? buildDanmaku;
  final VoidCallback? onToggleFullScreen;

  @override
  State<BiliVideoPlayerWidget> createState() => _BiliVideoPlayerWidgetState();
}

class _BiliVideoPlayerWidgetState extends State<BiliVideoPlayerWidget>
    with TickerProviderStateMixin {
  late final VideoAudioPlayer _videoAudioPlayer;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  bool _isFullScreen = false;
  bool _isShowControllPanel = true;

  @override
  void initState() {
    _videoAudioPlayer = VideoAudioPlayer(widget.controller._videoAudioController!);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1, end: 16 / 9).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> toggleFullScreen() async {
    if (_isFullScreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget videoPlayer = Stack(
      children: [
        AspectRatio(
          aspectRatio: widget.controller.videoAspectRatio,
          child: Hero(
            tag: widget.heroTagId ?? 0,
            child: _videoAudioPlayer,
          ),
        ),
        if (widget.buildDanmaku != null) widget.buildDanmaku!(),
        if (widget.buildControllPanel != null) widget.buildControllPanel!(),
      ],
    );

    if (_isFullScreen) {
      return Scaffold(
        body: Container(
          color: Colors.black,
          child: Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return AspectRatio(
                  aspectRatio: _animation.value,
                  child: videoPlayer,
                );
              },
            ),
          ),
        ),
      );
    } else {
      return videoPlayer;
    }
  }
}