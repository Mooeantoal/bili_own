import 'dart:developer';
import 'dart:math' as math;
import 'dart:io' show Platform;

import 'package:bili_own/common/models/local/video/audio_play_item.dart';
import 'package:bili_own/common/models/local/video/video_play_item.dart';
import 'package:bili_own/common/utils/index.dart';
import 'package:bili_own/common/utils/string_format_utils.dart';
import 'package:bili_own/common/widget/video_audio_player.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

// 添加下载服务导入
import 'package:bili_own/pages/download/download_service.dart';
import 'package:bili_own/common/models/local/download/bili_download_entry_info.dart';
import 'package:bili_own/common/models/local/download/bili_download_media_file_info.dart';
import 'package:bili_own/common/api/video_play_api.dart';
import 'package:bili_own/common/api/video_info_api.dart';

// BiliVideoPlayerPanelController类定义
class BiliVideoPlayerPanelController {
  BiliVideoPlayerPanelController(this._biliVideoPlayerController);

  final BiliVideoPlayerController _biliVideoPlayerController;
  VoidCallback? _toggleFullScreenCallback;

  // 控制器相关属性
  bool _isInitializedState = false;
  bool _isPlayerPlaying = false;
  bool _isPlayerEnd = false;
  bool _show = false;
  bool _isSliderDraging = false;
  bool _isPreviousPlaying = false;
  bool _isPreviousShow = false;
  double _volume = 0.0;
  double _brightness = 0.0;
  double _selectingSpeed = 1.0;
  double asepectRatio = 16 / 9;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _fartherestBuffed = Duration.zero;

  // Getters
  BiliVideoPlayerController get biliVideoPlayerController => _biliVideoPlayerController;

  // 设置全屏切换回调
  void setToggleFullScreenCallback(VoidCallback callback) {
    _toggleFullScreenCallback = callback;
  }

  // 切换全屏
  void toggleFullScreen() {
    if (_toggleFullScreenCallback != null) {
      _toggleFullScreenCallback!();
    }
  }
}

class BiliVideoPlayerPanel extends StatefulWidget {
  const BiliVideoPlayerPanel({Key? key, required this.controller})
      : super(key: key);
  final BiliVideoPlayerPanelController controller;

  @override
  State<BiliVideoPlayerPanel> createState() => _BiliVideoPlayerPanelState();
}

class _BiliVideoPlayerPanelState extends State<BiliVideoPlayerPanel> {
  final panelDecoration = const BoxDecoration(
    color: Colors.black54,
    boxShadow: [
      BoxShadow(color: Colors.black45, blurRadius: 15, spreadRadius: 5)
    ],
  );

  final playButtonKey = GlobalKey();
  final sliderKey = GlobalKey();
  final durationTextKey = GlobalKey();
  final danmakuCheckBoxKey = GlobalKey();

  final iconColor = Colors.white;
  final textColor = Colors.white;

  @override
  void initState() {
    if (!widget.controller._isInitializedState) {
      widget.controller._isPlayerPlaying =
          widget.controller._biliVideoPlayerController.isPlaying;
      //进入视频时默认显示面板，确保用户可以看到控制按钮
      widget.controller._show = true;
      widget.controller.asepectRatio =
          widget.controller._biliVideoPlayerController.videoAspectRatio;
    }
    widget.controller._isInitializedState = true;
    widget.controller._biliVideoPlayerController
        .addStateChangedListener(playStateChangedCallback);
    widget.controller._biliVideoPlayerController
        .addListener(playerListenerCallback);
    
    // 设置全屏切换回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final biliVideoPlayerWidget = context.findAncestorWidgetOfExactType<BiliVideoPlayerWidget>();
      if (biliVideoPlayerWidget != null && biliVideoPlayerWidget.onToggleFullScreen != null) {
        widget.controller.setToggleFullScreenCallback(biliVideoPlayerWidget.onToggleFullScreen!);
      }
    });
    
    super.initState();
    initControl();
  }

  playStateChangedCallback(VideoAudioState state) {
    if (widget.controller._isSliderDraging) return;
    if (state.isEnd) {
      widget.controller._isPlayerEnd = true;
      widget.controller._isPlayerPlaying = false;
    } else {
      widget.controller._isPlayerEnd = false;
      widget.controller._isPlayerPlaying = state.isPlaying;
    }
    if (mounted) {
      setState(() {});
    }
  }

  playerListenerCallback() {
    if (widget.controller._isSliderDraging) return;
    widget.controller._position =
        widget.controller._biliVideoPlayerController.position;
    widget.controller._duration =
        widget.controller._biliVideoPlayerController.duration;
    widget.controller._fartherestBuffed =
        widget.controller._biliVideoPlayerController.fartherestBuffered;
    if (mounted) {
      setState(() {});
    }
  }

  initControl() {
    //音量控制
    VolumeController().getVolume().then((value) {
      widget.controller._volume = value;
    });
    //亮度控制
    ScreenBrightness().current.then((value) {
      widget.controller._brightness = value;
    });
  }

  toggleDanmaku() {
    widget.controller.biliVideoPlayerController.biliDanmakuController!
        .toggleDanmaku();
    setState(() {});
  }

  toggleFullScreen() {
    // 直接通过上下文查找并调用全屏切换方法
    final biliVideoPlayerWidgetState = context.findAncestorStateOfType<State<BiliVideoPlayerWidget>>();
    if (biliVideoPlayerWidgetState != null) {
      // 由于无法直接访问私有方法，我们通过widget获取
      final widget = biliVideoPlayerWidgetState.widget;
      if (widget.onToggleFullScreen != null) {
        widget.onToggleFullScreen!();
      }
    }
  }

  buildVideoQualityTiles() {
    List<Widget> list = [];
    for (var i in widget.controller._biliVideoPlayerController.videoPlayInfo!
        .supportVideoQualities) {
      list.add(ListTile(
        title: Text(i.description),
        onTap: () {
          //切换画质
          for (var j in widget.controller._biliVideoPlayerController.videoPlayInfo!
              .videos) {
            if (j.quality == i) {
              widget.controller._biliVideoPlayerController.changeVideoItem(j);
              break;
            }
          }
          Navigator.of(context).pop();
        },
        selected: widget.controller._biliVideoPlayerController.videoPlayItem!
                .quality ==
            i,
      ));
    }
    return list;
  }

  buildAudioQualityTiles() {
    List<Widget> list = [];
    for (var i in widget.controller._biliVideoPlayerController.videoPlayInfo!
        .supportAudioQualities) {
      list.add(ListTile(
        title: Text(i.description),
        onTap: () {
          //切换音质
          for (var j in widget.controller._biliVideoPlayerController.videoPlayInfo!
              .audios) {
            if (j.quality == i) {
              widget.controller._biliVideoPlayerController.changeAudioItem(j);
              break;
            }
          }
          Navigator.of(context).pop();
        },
        selected: widget.controller._biliVideoPlayerController.audioPlayItem!
                .quality ==
            i,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    widget.controller._duration =
        widget.controller._biliVideoPlayerController.duration;
    return Stack(
      alignment: Alignment.center,
      children: [
        //手势识别层
        GestureDetector(onTap: () {
          //点击显示面板
          widget.controller._show = !(widget.controller._show);
          setState(() {});
        }, onDoubleTap: () {
          //双击暂停/播放
          if (widget.controller._isPlayerPlaying) {
            widget.controller._biliVideoPlayerController.pause();
            widget.controller._isPlayerPlaying = false;
            widget.controller._show = true;
          } else {
            widget.controller._biliVideoPlayerController.play();
            widget.controller._isPlayerPlaying = true;
            widget.controller._show = false;
          }
          setState(() {});
        }, onLongPress: () {
          widget.controller._selectingSpeed =
              widget.controller._biliVideoPlayerController.speed;
          //长按3倍速度
          widget.controller._biliVideoPlayerController
              .setPlayBackSpeed(widget.controller._selectingSpeed * 2);
          //振动
          HapticFeedback.selectionClick();
        }, onLongPressEnd: (details) {
          //长按结束时恢复本来的速度
          widget.controller._biliVideoPlayerController
              .setPlayBackSpeed(widget.controller._selectingSpeed);
        }, onHorizontalDragStart: (details) {
          widget.controller._isPreviousShow = widget.controller._show;
          widget.controller._isPreviousPlaying =
              widget.controller._isPlayerPlaying;
          widget.controller._show = true;
          widget.controller._biliVideoPlayerController.pause();
          widget.controller._isSliderDraging = true;
          setState(() {});
        }, onHorizontalDragUpdate: (details) {
          double scale = 0.5 / 1000;
          Duration pos = widget.controller._position +
              widget.controller._duration * details.delta.dx * scale;
          widget.controller._position = Duration(
              milliseconds: pos.inMilliseconds
                  .clamp(0, widget.controller._duration.inMilliseconds));
          setState(() {});
        }, onHorizontalDragEnd: (details) {
          widget.controller.biliVideoPlayerController
              .seekTo(widget.controller._position);
          if (widget.controller._isPreviousPlaying) {
            widget.controller._biliVideoPlayerController.play();
          }
          if (!widget.controller._isPreviousShow) {
            widget.controller._show = false;
          }
          widget.controller._isSliderDraging = false;
          setState(() {});
        }, onVerticalDragUpdate: (details) {
          var add = details.delta.dy / 500;
          if (details.localPosition.dx > context.size!.width / 2) {
            widget.controller._volume -= add;
            widget.controller._volume = widget.controller._volume.clamp(0, 1);
            VolumeController().setVolume(widget.controller._volume);
          } else {
            widget.controller._brightness -= add;
            widget.controller._brightness =
                widget.controller._brightness.clamp(0, 1);
            ScreenBrightness()
                .setScreenBrightness(widget.controller._brightness);
          }
        }),
        //面板层
        Visibility(
            visible: widget.controller._show,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  //上面板(返回,菜单...)
                  Container(
                    decoration: panelDecoration,
                    child: Row(
                      children: [
                        //返回按钮
                        BackButton(
                          color: Colors.white,
                        ),
                        //主页面按钮
                        IconButton(
                            onPressed: () {
                              //回到主页面
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            icon: Icon(
                              Icons.home_outlined,
                              color: Colors.white,
                            )),
                        Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: iconColor,
                          ),
                          // 确保菜单始终可用，不依赖于面板的可见性
                          enabled: true,
                          // 设置菜单的背景色为透明，避免白色遮罩
                          color: Colors.transparent,
                          itemBuilder: (context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                padding: EdgeInsets.zero,
                                value: "弹幕",
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.format_list_bulleted,
                                        size: 24,
                                      ),
                                    ),
                                    Text("弹幕"),
                                    Spacer(),
                                    StatefulBuilder(
                                      key: danmakuCheckBoxKey,
                                      builder: (context, setState) {
                                        return Checkbox(
                                          value: widget
                                              .controller
                                              .biliVideoPlayerController
                                              .biliDanmakuController!
                                              .isDanmakuOpened,
                                          onChanged: (value) {
                                            if (value != null) {
                                              toggleDanmaku();
                                            }
                                          },
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                padding: EdgeInsets.zero,
                                value: "播放速度",
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.speed_rounded,
                                          size: 24,
                                        )),
                                    Text("播放速度")
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                  value: "画质",
                                  child: Text(
                                      "画质: ${widget.controller._biliVideoPlayerController.videoPlayItem!.quality.description ?? "未知"}")),
                              PopupMenuItem(
                                  value: "音质",
                                  child: Text(
                                      "音质: ${widget.controller._biliVideoPlayerController.audioPlayItem!.quality.description ?? "未知"}")),
                              // 添加下载选项
                              PopupMenuItem(
                                padding: EdgeInsets.zero,
                                value: "下载",
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.download_rounded,
                                          size: 24,
                                        )),
                                    Text("下载视频")
                                  ],
                                ),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            switch (value) {
                              case "弹幕":
                                toggleDanmaku();
                                break;
                              case "播放速度":
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text("选择播放速度"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "取消",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            )),
                                      ],
                                      content: Column(
                                        children: [
                                          StatefulBuilder(
                                            builder: (context, setState) {
                                              return Slider(
                                                min: 0.25,
                                                max: 3,
                                                divisions: 11,
                                                value: widget
                                                    .controller
                                                    ._selectingSpeed,
                                                label: widget
                                                    .controller
                                                    ._selectingSpeed
                                                    .toString(),
                                                onChanged: (value) {
                                                  widget.controller
                                                      ._selectingSpeed = value;
                                                  setState(() {});
                                                },
                                              );
                                            },
                                          ),
                                          Text(widget.controller._selectingSpeed
                                              .toString()),
                                          TextButton(
                                              onPressed: () {
                                                widget.controller
                                                    ._biliVideoPlayerController
                                                    .setPlayBackSpeed(widget
                                                        .controller
                                                        ._selectingSpeed);
                                                Navigator.pop(context);
                                              },
                                              child: const Text("确定")),
                                        ],
                                      ),
                                    );
                                  },
                                );
                                break;
                              case "画质":
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text("选择画质"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "取消",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            )),
                                      ],
                                      content: Column(
                                        children: buildVideoQualityTiles(),
                                      ),
                                    );
                                  },
                                );
                                break;
                              case "音质":
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      scrollable: true,
                                      title: const Text("选择音质"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "取消",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            )),
                                      ],
                                      content: Column(
                                        children: buildAudioQualityTiles(),
                                      ),
                                    );
                                  },
                                );
                                break;
                              // 添加下载处理逻辑
                              case "下载":
                                _downloadVideo();
                                break;
                              default:
                                log(value);
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  //中间留空
                  const Spacer(),
                  //下面板(播放按钮,进度条...)
                  Container(
                    decoration: panelDecoration,
                    child: Row(children: [
                      StatefulBuilder(
                        key: playButtonKey,
                        builder: (context, setState) {
                          late final IconData iconData;
                          if (widget.controller._isPlayerEnd) {
                            iconData = Icons.refresh_rounded;
                          } else if (widget.controller._isPlayerPlaying) {
                            iconData = Icons.pause_rounded;
                          } else {
                            iconData = Icons.play_arrow_rounded;
                          }
                          return //播放按钮
                              IconButton(
                                  color: iconColor,
                                  onPressed: () async {
                                    if (widget.controller
                                        ._biliVideoPlayerController.isPlaying) {
                                      await widget
                                          .controller._biliVideoPlayerController
                                          .pause();
                                      widget.controller._isPlayerPlaying = false;
                                    } else {
                                      if (widget
                                          .controller
                                          ._biliVideoPlayerController
                                          .hasError) {
                                        //如果是出错状态, 重新加载
                                        await widget.controller
                                            ._biliVideoPlayerController
                                            .reloadWidget();
                                      } else {
                                        //不是出错状态, 就继续播放
                                        await widget.controller
                                            ._biliVideoPlayerController
                                            .play();
                                        widget.controller._isPlayerPlaying = true;
                                      }
                                    }
                                    setState(() {});
                                  },
                                  icon: Icon(iconData));
                        },
                      ),
                      //进度条
                      Expanded(
                        child: StatefulBuilder(
                            key: sliderKey,
                            builder: (context, setState) {
                              return Slider(
                                min: 0,
                                max: widget
                                    .controller
                                    ._biliVideoPlayerController
                                    .duration
                                    .inMilliseconds
                                    .toDouble(),
                                value: widget
                                    .controller._position.inMilliseconds
                                    .toDouble(),
                                secondaryTrackValue: widget
                                    .controller._fartherestBuffed.inMilliseconds
                                    .toDouble(),
                                onChanged: (value) {
                                  if (widget.controller._isSliderDraging) {
                                    widget.controller._position =
                                        Duration(milliseconds: value.toInt());
                                  } else {
                                    widget.controller._biliVideoPlayerController
                                        .seekTo(Duration(
                                            milliseconds: value.toInt()));
                                  }
                                },
                                onChangeStart: (value) {
                                  widget.controller._isSliderDraging = true;
                                },
                                onChangeEnd: (value) {
                                  if (widget.controller._isSliderDraging) {
                                    widget.controller._biliVideoPlayerController
                                        .seekTo(Duration(
                                            milliseconds: value.toInt()));
                                    widget.controller._isSliderDraging = false;
                                  }
                                },
                              );
                            }),
                      ),
                      //时长
                      StatefulBuilder(
                        key: durationTextKey,
                        builder: (context, setState) {
                          return Text(
                            "${StringFormatUtils.timeLengthFormat(widget.controller._position.inSeconds)}/${StringFormatUtils.timeLengthFormat(widget.controller._biliVideoPlayerController.duration.inSeconds)}",
                            style: TextStyle(color: textColor),
                          );
                        },
                      ),
                      // 全屏按钮
                      IconButton(
                          onPressed: () {
                            // log("full:${widget.controller.isFullScreen}");
                            toggleFullScreen();
                          },
                          icon: Icon(
                            Icons.fullscreen_rounded,
                            color: iconColor,
                          ))
                    ]),
                  )
                ],
              ),
            ))
      ],
    );
  }

  /// 下载视频
  void _downloadVideo() async {
    try {
      // 获取下载服务
      final downloadService = Get.find<DownloadService>();
      
      // 获取当前视频播放信息
      final videoPlayInfo = widget.controller._biliVideoPlayerController.videoPlayInfo;
      if (videoPlayInfo == null) {
        Get.snackbar("下载失败", "无法获取视频信息");
        return;
      }
      
      // 获取视频和音频信息
      final videoItem = widget.controller._biliVideoPlayerController.videoPlayItem;
      final audioItem = widget.controller._biliVideoPlayerController.audioPlayItem;
      
      if (videoItem == null || audioItem == null) {
        Get.snackbar("下载失败", "无法获取视频或音频信息");
        return;
      }
      
      // 获取视频标题等信息
      String videoTitle = "视频标题";
      String coverUrl = "";
      String upName = "";
      String upMid = "";
      String aid = "";
      
      try {
        // 尝试获取视频详细信息
        final videoInfoResponse = await VideoInfoApi.getVideoInfo(bvid: widget.controller._biliVideoPlayerController.bvid);
        videoTitle = videoInfoResponse.title;
        coverUrl = videoInfoResponse.ownerFace;
        upName = videoInfoResponse.ownerName;
        upMid = videoInfoResponse.ownerMid.toString();
        aid = videoInfoResponse.bvid; // 注意：这里使用bvid，因为aid可能不是字符串类型
      } catch (e) {
        // 如果获取失败，使用默认值
        print("获取视频信息失败: $e");
      }
      
      // 创建下载条目信息
      final downloadEntryInfo = BiliDownloadEntryInfo(
        title: videoTitle,
        cover: coverUrl,
        preferedVideoQuality: videoItem.quality.index,
        durlBackupUrl: videoItem.urls.length > 1 ? videoItem.urls[1] : "",
        totalBytes: videoItem.bandWidth,
        downloadedBytes: 0,
        filePath: "",
        taskId: DateTime.now().millisecondsSinceEpoch.toString(),
        type: "video",
        state: 0,
        errorMsg: "",
        createTime: DateTime.now().millisecondsSinceEpoch,
        finishTime: 0,
        aid: aid,
        cid: widget.controller._biliVideoPlayerController.cid.toString(),
        bvid: widget.controller._biliVideoPlayerController.bvid,
        seasonId: "",
        episodeId: "",
        upName: upName,
        upMid: upMid,
      );
      
      // 创建媒体文件信息列表
      final mediaFiles = <BiliDownloadMediaFileInfo>[
        // 视频文件信息
        BiliDownloadMediaFileInfo(
          quality: videoItem.quality.index,
          qualityString: VideoQualityDescription(videoItem.quality).description,
          fileSize: videoItem.bandWidth,
          filePath: "",
          taskId: downloadEntryInfo.taskId,
          state: 0,
          errorMsg: "",
          downloadedBytes: 0,
          downloadUrl: videoItem.urls.first,
          backupUrl: videoItem.urls.length > 1 ? videoItem.urls[1] : "",
          createTime: DateTime.now().millisecondsSinceEpoch,
          finishTime: 0,
        ),
        // 音频文件信息
        BiliDownloadMediaFileInfo(
          quality: audioItem.quality.index,
          qualityString: AudioQualityDescription(audioItem.quality).description,
          fileSize: audioItem.bandWidth,
          filePath: "",
          taskId: downloadEntryInfo.taskId,
          state: 0,
          errorMsg: "",
          downloadedBytes: 0,
          downloadUrl: audioItem.urls.first,
          backupUrl: audioItem.urls.length > 1 ? audioItem.urls[1] : "",
          createTime: DateTime.now().millisecondsSinceEpoch,
          finishTime: 0,
        ),
      ];
      
      // 添加到下载队列
      await downloadService.addToDownloadQueue(downloadEntryInfo, mediaFiles);
      
      // 显示提示信息
      Get.snackbar(
        "开始下载",
        "已添加到下载队列",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "下载失败",
        "添加到下载队列失败: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}