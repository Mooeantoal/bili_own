import 'dart:async';
import 'dart:developer';

import 'package:bili_own/common/api/video_play_api.dart';
import 'package:bili_own/common/models/local/video/audio_play_item.dart';
import 'package:bili_own/common/models/local/video/video_play_info.dart';
import 'package:bili_own/common/models/local/video/video_play_item.dart';
import 'package:bili_own/common/utils/index.dart';
import 'package:bili_own/common/utils/fullscreen.dart';
import 'package:bili_own/common/widget/video_audio_player.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player_panel.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_danmaku.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class BiliVideoPlayerWidget extends StatefulWidget {
  const BiliVideoPlayerWidget(this.controller,
      {super.key,
      this.buildDanmaku,
      this.buildControllPanel,
      required this.heroTagId});
  final BiliVideoPlayerController controller;
  final BiliDanmaku Function()? buildDanmaku;
  final Widget Function()? buildControllPanel;
  final int heroTagId;

  @override
  State<BiliVideoPlayerWidget> createState() => _BiliVideoPlayerWidgetState();
}

class _BiliVideoPlayerWidgetState extends State<BiliVideoPlayerWidget> {
  GlobalKey aspectRatioKey = GlobalKey();
  BiliDanmaku? danmaku;
  Widget? controllPanel;
  //每15秒执行一次的timer，用来更新播放记录
  Timer? heartBeat;

  updateWidget() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    danmaku = widget.buildDanmaku?.call();
    controllPanel = widget.buildControllPanel?.call();
    if (!widget.controller._isInitializedState) {
      //是否进入时即播放
      widget.controller._playWhenInitialize = BiliOwnStorage.settings
          .get(SettingsStorageKeys.autoPlayOnInit, defaultValue: true);
      //定时汇报历史记录
      widget.controller._reportHistory();
      heartBeat = Timer.periodic(const Duration(seconds: 15), (timer) async {
        await widget.controller._reportHistory();
      });
      widget.controller.biliDanmakuController = danmaku?.controller;
      widget.controller.buildDanmaku = widget.buildDanmaku;
      widget.controller.buildControllPanel = widget.buildControllPanel;
      // 初始化面板控制器
      if (widget.buildControllPanel != null) {
        widget.controller._panelController = widget.buildControllPanel!() as BiliVideoPlayerPanelController?;
      }
    }
    widget.controller._isInitializedState = true;

    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    heartBeat?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.updateWidget = updateWidget;
    return WillPopScope(
      onWillPop: () async {
        if (widget.controller.isFullScreen) {
          await widget.controller.toggleFullScreen();
        }
        return true;
      },
      child: Hero(
        tag: widget.heroTagId,
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: Colors.black,
          child: FutureBuilder<bool>(
            future: widget.controller
                .initPlayer(widget.controller.bvid, widget.controller.cid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data == true && 
                    widget.controller._videoAudioController != null &&
                    widget.controller.videoPlayInfo != null &&
                    widget.controller.videoPlayInfo!.videos.isNotEmpty) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(children: [
                      Center(
                        child: PhotoView.customChild(
                          child: VideoAudioPlayer(
                            widget.controller._videoAudioController!,
                            asepectRatio: widget.controller.videoPlayInfo!
                                    .videos.first.width /
                                widget.controller.videoPlayInfo!.videos
                                    .first.height,
                          ),
                        ),
                      ),
                      Center(
                        child: danmaku,
                      ),
                      Center(
                        child: controllPanel,
                      ),
                    ]),
                  );
                } else {
                  //加载失败,重试按钮
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '视频加载失败',
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                            onPressed: () async {
                              setState(() {});
                            },
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
                      ],
                    ),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class BiliVideoPlayerController {
  BiliVideoPlayerController(
      {required this.bvid,
      required this.cid,
      this.initVideoPosition = Duration.zero});
  String bvid;
  int cid;
  bool _isInitializedState = false;
  bool isFullScreen = false;
  bool _playWhenInitialize = true;
  //初始进度
  Duration initVideoPosition;

  late Function() updateWidget;
  late BiliDanmaku Function()? buildDanmaku;
  late Widget Function()? buildControllPanel;
  BiliVideoPlayerPanelController? _panelController;
  VideoAudioController? _videoAudioController;
  BiliDanmakuController? biliDanmakuController;
  VideoPlayInfo? videoPlayInfo;
  //当前播放的视频信息
  VideoPlayItem? _videoPlayItem;
  //当前播放的音频信息
  AudioPlayItem? _audioPlayItem;
  // //当前的视频画质
  // VideoQuality? _videoQuality;
  // //当前的音质
  // AudioQuality? _audioQuality;

  VideoPlayItem? get videoPlayItem => _videoPlayItem;
  AudioPlayItem? get audioPlayItem => _audioPlayItem;
  // VideoQuality? get videoQuality => _videoQuality;
  // AudioQuality? get audioQuality => _audioQuality;

  double _aspectRatio = 16 / 9;

  double get aspectRatio => _aspectRatio;
  set aspectRatio(double asepectRatio) {
    _aspectRatio = asepectRatio;
  }

  Future<void> reloadWidget() async {
    updateWidget();
    await _videoAudioController?.refresh();
    biliDanmakuController?.reloadDanmaku?.call();
  }

  Future<void> changeCid(String bvid, int cid) async {
    videoPlayInfo = null;
    _videoPlayItem = null;
    _audioPlayItem = null;
    initVideoPosition = Duration.zero;
    this.bvid = bvid;
    this.cid = cid;
    if (await loadVideoInfo(bvid, cid) == false) {
      log("bili_video_player.changeCid: loadVideoInfo failed");
      return;
    }
    if (_videoPlayItem != null) {
      _videoAudioController?.videoUrl = _videoPlayItem!.urls.first;
    }
    if (_audioPlayItem != null) {
      _videoAudioController?.audioUrl = _audioPlayItem!.urls.first;
    }
    _videoAudioController?.state.position = Duration.zero;
    await _videoAudioController?.refresh();
    biliDanmakuController?.reloadDanmaku?.call();
  }

  Future<bool> loadVideoInfo(String bvid, int cid) async {
    if (videoPlayInfo == null) {
      try {
        //加载视频播放信息
        videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
      } catch (e) {
        log("bili_video_player.loadVideo:$e");
        return false;
      }
    }
    if (videoPlayInfo == null || videoPlayInfo!.videos.isEmpty) {
      log("bili_video_player.loadVideo: videoPlayInfo is null or videos is empty");
      return false;
    }
    if (_videoPlayItem == null) {
      //根据偏好选择画质
      List<VideoPlayItem> tempMatchVideos = [];
      //先匹配编码
      for (var i in videoPlayInfo!.videos) {
        if (i.codecs.contains(BiliOwnStorage.settings
            .get(SettingsStorageKeys.preferVideoCodec, defaultValue: 'hev'))) {
          tempMatchVideos.add(i);
        }
      }
      //如果编码没有匹配上，就只能不匹配编码了
      if (tempMatchVideos.isEmpty) {
        tempMatchVideos = videoPlayInfo!.videos;
      }
      //根据VideoQuality下标判断最接近的画质
      var matchedVideo = tempMatchVideos.first;
      var preferVideoQualityIndex = SettingsUtil.getPreferVideoQuality().index;
      for (var i in tempMatchVideos) {
        if ((i.quality.index - preferVideoQualityIndex).abs() <
            (matchedVideo.quality.index - preferVideoQualityIndex).abs()) {
          matchedVideo = i;
        }
      }
      _videoPlayItem = matchedVideo;
    }
    if (_audioPlayItem == null && videoPlayInfo!.audios.isNotEmpty) {
      //根据偏好选择音质
      //根据AudioQuality下标判断最接近的音质
      var matchedAudio = videoPlayInfo!.audios.first;
      var preferAudioQualityIndex = SettingsUtil.getPreferAudioQuality().index;
      for (var i in videoPlayInfo!.audios) {
        if ((i.quality.index - preferAudioQualityIndex).abs() <
            (matchedAudio.quality.index - preferAudioQualityIndex).abs()) {
          matchedAudio = i;
        }
      }
      _audioPlayItem = matchedAudio;
    } else if (videoPlayInfo!.audios.isEmpty) {
      _audioPlayItem = null;
    }
    return true;
  }

  Future<bool> initPlayer(String bvid, int cid) async {
    //如果不是第一次的话就跳过
    if (_videoAudioController != null) {
      return true;
    }
    //加载视频播放信息
    if (await loadVideoInfo(bvid, cid) == false) return false;
    //获取视频，音频的url
    if (_videoPlayItem == null) {
      log("bili_video_player.initPlayer: videoPlayItem is null");
      return false;
    }
    String videoUrl = _videoPlayItem!.urls.first;
    String audioUrl = _audioPlayItem?.urls.first ?? "";
    
    //检查URL是否有效
    if (videoUrl.isEmpty) {
      log("bili_video_player.initPlayer: videoUrl is empty");
      return false;
    }

    //创建播放器
    _videoAudioController = VideoAudioController(
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        audioHeaders: VideoPlayApi.videoPlayerHttpHeaders,
        videoHeaders: VideoPlayApi.videoPlayerHttpHeaders,
        autoWakelock: true,
        initStart: _playWhenInitialize);

    await _videoAudioController!.init();

    //是否进入就全屏
    bool isFullScreenPlayOnEnter = BiliOwnStorage.settings
        .get(SettingsStorageKeys.fullScreenPlayOnEnter, defaultValue: false);
    if (isFullScreenPlayOnEnter) {
      isFullScreen = false;
      toggleFullScreen();
    }
    return true;
  }

  ///切换视频播放源/视频画质
  void changeVideoItem(VideoPlayItem videoPlayItem) {
    _videoPlayItem = videoPlayItem;
    if (_videoAudioController != null) {
      _videoAudioController!.videoUrl = videoPlayItem.urls.first;
      _videoAudioController!.refresh();
    }
    // reloadWidget();
  }

  ///切换音频播放源/音质
  void changeAudioItem(AudioPlayItem audioPlayItem) {
    _audioPlayItem = audioPlayItem;
    if (_videoAudioController != null) {
      _videoAudioController!.audioUrl = audioPlayItem.urls.first;
      _videoAudioController!.refresh();
    }
    // reloadWidget();
  }

  //汇报一次历史记录
  Future<void> _reportHistory() async {
    try {
      await VideoPlayApi.reportHistory(
          bvid: bvid, cid: cid, playedTime: position.inSeconds);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> refreshPlayer() async {
    await _videoAudioController?.refresh();
  }

  Future<void> toggleFullScreen() async {
    if (isFullScreen) {
      //退出全屏
      isFullScreen = false;
      if (Get.context != null && Navigator.canPop(Get.context!)) {
        Navigator.pop(Get.context!);
      }
      await exitFullScreen();
      await portraitUp();
      //重置面板显示状态
      _panelController?.setShow(true);
    } else {
      //进入全屏
      isFullScreen = true;
      await enterFullScreen();
      if (videoAspectRatio >= 1) {
        await landScape();
      } else {
        await portraitUp();
      }
      if (Get.context != null) {
        showDialog(
          context: Get.context!,
          useSafeArea: false,
          builder: (context) => Dialog.fullscreen(
              backgroundColor: Colors.black,
              child: BiliVideoPlayerWidget(
                this,
                heroTagId: -1,
                buildControllPanel: buildControllPanel,
                buildDanmaku: buildDanmaku,
              )),
        );
      }
    }
  }

  void addListener(VoidCallback listener) {
    _videoAudioController?.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _videoAudioController?.removeListener(listener);
  }

  void addStateChangedListener(Function(VideoAudioState state) listener) {
    _videoAudioController?.addStateChangedListener(listener);
  }

  void removeStateChangedListener(Function(VideoAudioState state) listener) {
    _videoAudioController?.removeStateChangedListener(listener);
  }

  void addSeekToListener(Function(Duration position) listener) {
    _videoAudioController?.addSeekToListener(listener);
  }

  void removeSeekToListener(Function(Duration position) listener) {
    _videoAudioController?.removeSeekToListener(listener);
  }

  Future<void> dispose() async {
    await _reportHistory();
    if (_videoAudioController != null) {
      await _videoAudioController!.dispose();
    }
  }

  Duration get position {
    if (_videoAudioController == null) {
      return Duration.zero;
    }
    return _videoAudioController!.state.position;
  }

  Duration get duration {
    if (_videoAudioController == null) {
      return Duration.zero;
    }
    return _videoAudioController!.state.duration;
  }

  double get speed {
    if (_videoAudioController == null) {
      return 1.0;
    }
    return _videoAudioController!.state.speed;
  }

  bool get isPlaying {
    if (_videoAudioController == null) {
      return false;
    }
    return _videoAudioController!.state.isPlaying;
  }

  bool get isBuffering {
    if (_videoAudioController == null) {
      return false;
    }
    return _videoAudioController!.state.isBuffering;
  }

  bool get hasError {
    if (_videoAudioController == null) {
      return false;
    }
    return _videoAudioController!.state.hasError;
  }

  Duration get fartherestBuffered {
    if (_videoAudioController == null) {
      return Duration.zero;
    }
    return _videoAudioController!.state.buffered;
  }

  double get videoAspectRatio {
    if (_videoAudioController == null || 
        _videoAudioController!.state.width == 0 || 
        _videoAudioController!.state.height == 0) {
      return 16 / 9;
    }
    return _videoAudioController!.state.width / _videoAudioController!.state.height;
  }

  Future<void> play() async {
    if (_videoAudioController != null) {
      await _videoAudioController!.play();
    }
  }

  Future<void> pause() async {
    if (_videoAudioController != null) {
      await _videoAudioController!.pause();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_videoAudioController != null) {
      await _videoAudioController!.seekTo(position);
      await _reportHistory();
    }
  }

  Future<void> setPlayBackSpeed(double speed) async {
    if (_videoAudioController != null) {
      await _videoAudioController!.setPlayBackSpeed(speed);
    }
  }
}