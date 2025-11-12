// 视频播放器组件
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../common/widget/video_audio_player.dart';
import '../../../../common/api/video_play_api.dart';
import '../../../../common/utils/bili_own_storage.dart';
import '../../../../common/utils/settings.dart';
import '../../../../common/models/local/video/video_play_info.dart';
import '../../../../common/models/local/video/video_play_item.dart';
import '../../../../common/models/local/video/audio_play_item.dart';

class BiliVideoPlayerWidget extends StatefulWidget {
  final String bvid;
  final int cid;
  final double aspectRatio;
  final bool autoPlay;

  const BiliVideoPlayerWidget({
    Key? key,
    required this.bvid,
    required this.cid,
    this.aspectRatio = 16 / 9,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<BiliVideoPlayerWidget> createState() => _BiliVideoPlayerWidgetState();
}

class _BiliVideoPlayerWidgetState extends State<BiliVideoPlayerWidget> {
  late BiliVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BiliVideoPlayerController(widget.autoPlay);
    _controller.initPlayer(context, widget.bvid, widget.cid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _controller.loadVideoInfo(widget.bvid, widget.cid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !(snapshot.data ?? false)) {
          return const Center(child: Text('加载视频失败'));
        } else {
          return VideoAudioPlayer(_controller._videoAudioController);
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

class BiliVideoPlayerController {
  VideoPlayInfo? videoPlayInfo;
  VideoPlayItem? _videoPlayItem;
  AudioPlayItem? _audioPlayItem;
  final VideoAudioController _videoAudioController;
  
  // 添加bvid和cid属性
  String? bvid;
  int? cid;

  BiliVideoPlayerController(bool autoPlay)
      : _videoAudioController = VideoAudioController(
          autoWakelock: true,
          initStart: autoPlay,
        );

  String get videoUrl => _videoPlayItem?.urls.first ?? '';
  String get audioUrl => _audioPlayItem?.urls.first ?? '';
  
  // 添加获取position的getter
  Duration get position => _videoAudioController.state.position;
  
  // 添加获取speed的getter
  double get speed => _videoAudioController.state.speed;

  Future<void> initPlayer(BuildContext context, String bvid, int cid) async {
    // 初始化播放器逻辑
    this.bvid = bvid;
    this.cid = cid;
  }

  Future<bool> loadVideoInfo(String bvid, int cid) async {
    log("加载视频信息: bvid=$bvid, cid=$cid");
    this.bvid = bvid;
    this.cid = cid;
    
    if (videoPlayInfo == null) {
      try {
        //加载视频播放信息
        videoPlayInfo = await VideoPlayApi.getVideoPlay(bvid: bvid, cid: cid);
        log("获取到视频播放信息: videos=${videoPlayInfo?.videos.length}, audios=${videoPlayInfo?.audios.length}");
      } catch (e, stackTrace) {
        log("bili_video_player.loadVideo:$e");
        log("错误堆栈: $stackTrace");
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
      log("选择视频画质: quality=${matchedVideo.quality}, codecs=${matchedVideo.codecs}, url=${matchedVideo.urls.first}");
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
      log("选择音频音质: quality=${matchedAudio.quality}, codecs=${matchedAudio.codecs}, url=${matchedAudio.urls.first}");
    } else if (videoPlayInfo!.audios.isEmpty) {
      _audioPlayItem = null;
      log("没有音频信息");
    } else {
      log("音频信息已存在或不需要重新选择");
    }
    
    // 更新视频音频控制器的URL
    _videoAudioController.videoUrl = videoUrl;
    _videoAudioController.audioUrl = audioUrl;
    
    return true;
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
  Future<void> setPlaybackSpeed(double speed) async {
    await _videoAudioController.setPlayBackSpeed(speed);
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
}