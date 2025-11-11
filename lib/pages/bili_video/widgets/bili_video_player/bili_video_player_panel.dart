import 'dart:developer';
import 'dart:math' as math;

import 'package:bili_own/common/models/local/video/audio_play_item.dart';
import 'package:bili_own/common/models/local/video/video_play_item.dart';
import 'package:bili_own/common/utils/index.dart';
import 'package:bili_own/common/utils/string_format_utils.dart';
import 'package:bili_own/common/widget/video_audio_player.dart';
import 'package:bili_own/pages/bili_video/widgets/bili_video_player/bili_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class BiliVideoPlayerPanelController {
  BiliVideoPlayerPanelController(this._biliVideoPlayerController);
  final BiliVideoPlayerController _biliVideoPlayerController;
  bool _isInitializedState = false;
  bool _isPlayerPlaying = false;
  bool _isPlayerEnd = false;
  bool _isPlayerBuffering = false;
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

  BiliVideoPlayerController get biliVideoPlayerController =>
      _biliVideoPlayerController;
}

class BiliVideoPlayerPanel extends StatefulWidget {
  const BiliVideoPlayerPanel(this.controller, {super.key});
  final BiliVideoPlayerPanelController controller;
  @override
  State<BiliVideoPlayerPanel> createState() => _BiliVideoPlayerPanelState();
}

class _BiliVideoPlayerPanelState extends State<BiliVideoPlayerPanel> {
  GlobalKey danmakuCheckBoxKey = GlobalKey();
  GlobalKey playButtonKey = GlobalKey();
  GlobalKey sliderKey = GlobalKey();
  GlobalKey durationTextKey = GlobalKey();

  final panelDecoration = const BoxDecoration(boxShadow: [
    BoxShadow(color: Colors.black45, blurRadius: 15, spreadRadius: 5)
  ]);
  static const Color textColor = Colors.white;
  static const Color iconColor = Colors.white;

  void playStateChangedCallback(VideoAudioState value) {
    widget.controller._isPlayerPlaying = value.isPlaying;
    widget.controller._isPlayerEnd = value.isEnd;
    widget.controller._isPlayerBuffering = value.isBuffering;
    playButtonKey.currentState?.setState(() {});
  }

  void playerListenerCallback() async {
    if (!widget.controller._isSliderDraging) {
      widget.controller._position =
          widget.controller._biliVideoPlayerController.position;
    }
    widget.controller._fartherestBuffed =
        widget.controller._biliVideoPlayerController.fartherestBuffered;
    sliderKey.currentState?.setState(() {});
    durationTextKey.currentState?.setState(() {});
  }

  void toggleFullScreen() {
    // 直接调用控制器的全屏切换方法
    widget.controller._biliVideoPlayerController.toggleFullScreen();
  }

  void toggleDanmaku() {
    widget.controller._biliVideoPlayerController.biliDanmakuController!
        .toggleDanmaku();
    danmakuCheckBoxKey.currentState!.setState(() {});
  }

  @override
  void initState() {
    if (!widget.controller._isInitializedState) {
      widget.controller._isPlayerPlaying =
          widget.controller._biliVideoPlayerController.isPlaying;
      //进入视频时如果没有在播放就显示
      widget.controller._show = !widget.controller._isPlayerPlaying;
      widget.controller.asepectRatio =
          widget.controller._biliVideoPlayerController.videoAspectRatio;
    }
    widget.controller._isInitializedState = true;
    widget.controller._biliVideoPlayerController
        .addStateChangedListener(playStateChangedCallback);
    widget.controller._biliVideoPlayerController
        .addListener(playerListenerCallback);
    super.initState();
    initControl();
  }

  Future<void> initControl() async {
    widget.controller._volume = await VolumeController().getVolume();
    widget.controller._brightness = await ScreenBrightness().current;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller._biliVideoPlayerController
        .removeStateChangedListener(playStateChangedCallback);
    widget.controller._biliVideoPlayerController
        .removeListener(playerListenerCallback);
    super.dispose();
  }

  ///视频画质radio列表
  List<RadioListTile> buildVideoQualityTiles() {
    List<RadioListTile> list = [];
    for (var i
        in widget.controller._biliVideoPlayerController.videoPlayInfo!.videos) {
      list.add(RadioListTile(
        title: Text(i.quality.description),
        subtitle: Text(i.codecs),
        value: i,
        groupValue: widget.controller._biliVideoPlayerController.videoPlayItem,
        onChanged: (value) {
          widget.controller._biliVideoPlayerController.changeVideoItem(value);
          Navigator.of(context).pop();
        },
      ));
    }
    return list;
  }

  //音质radio列表
  List<RadioListTile> buildAudioQualityTiles() {
    List<RadioListTile> list = [];
    for (var i
        in widget.controller._biliVideoPlayerController.videoPlayInfo!.audios) {
      list.add(RadioListTile(
        title: Text(i.quality.description),
        subtitle: Text(i.codecs),
        value: i,
        groupValue: widget.controller._biliVideoPlayerController.audioPlayItem,
        onChanged: (value) {
          widget.controller._biliVideoPlayerController.changeAudioItem(value);
          Navigator.of(context).pop();
        },
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
            widget.controller._show = true;
          } else {
            widget.controller._biliVideoPlayerController.play();
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
                        const BackButton(
                          color: Colors.white,
                        ),
                        //主页面按钮
                        IconButton(
                            onPressed: () {
                              //回到主页面
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            icon: const Icon(
                              Icons.home_outlined,
                              color: Colors.white,
                            )),
                        const Spacer(),
                        PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: iconColor,
                          ),
                          itemBuilder: (context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                padding: EdgeInsets.zero,
                                value: "弹幕",
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.format_list_bulleted,
                                        size: 24,
                                      ),
                                    ),
                                    const Text("弹幕"),
                                    const Spacer(),
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
                              const PopupMenuItem(
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
                                      "音质: ${widget.controller._biliVideoPlayerController.audioPlayItem!.quality.description ?? "未知"}"))
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
                                  builder: (context) => StatefulBuilder(
                                      builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text("播放速度"),
                                      content: IntrinsicHeight(
                                        child: Slider(
                                          min: 0.25,
                                          max: 4.00,
                                          divisions: 15,
                                          label:
                                              "${widget.controller._selectingSpeed}X",
                                          value:
                                              widget.controller._selectingSpeed,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                widget.controller
                                                    ._selectingSpeed = value;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              widget.controller
                                                      ._selectingSpeed =
                                                  widget
                                                      .controller
                                                      ._biliVideoPlayerController
                                                      .speed;
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "取消",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            )),
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
                                    );
                                  }),
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
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  //下面板(播放/暂停,进度条,全屏...)
                  Container(
                    decoration: panelDecoration,
                    child: Column(
                      children: [
                        //进度条
                        StatefulBuilder(
                          key: sliderKey,
                          builder: (context, setState) {
                            return SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.red,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.red,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16),
                                trackHeight: 2,
                                overlayColor: Colors.transparent,
                              ),
                              child: Slider(
                                onChangeStart: (value) {
                                  widget.controller._isSliderDraging = true;
                                },
                                onChangeEnd: (value) async {
                                  await widget.controller.biliVideoPlayerController
                                      .seekTo(widget.controller._position);
                                  widget.controller._isSliderDraging = false;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    widget.controller._position =
                                        widget.controller._duration * value;
                                  });
                                },
                                value: widget.controller._duration.inMilliseconds ==
                                        0
                                    ? 0
                                    : (widget.controller._position.inMilliseconds /
                                            widget
                                                .controller._duration.inMilliseconds)
                                        .clamp(0.0, 1.0),
                              ),
                            );
                          },
                        ),
                        //底部控制栏
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              //播放/暂停按钮
                              StatefulBuilder(
                                key: playButtonKey,
                                builder: (context, setState) {
                                  return IconButton(
                                      onPressed: () async {
                                        if (widget.controller._isPlayerPlaying) {
                                          await widget.controller
                                              .biliVideoPlayerController
                                              .pause();
                                        } else {
                                          await widget.controller
                                              .biliVideoPlayerController
                                              .play();
                                        }
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        widget.controller._isPlayerPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: iconColor,
                                      ));
                                },
                              ),
                              //时间
                              StatefulBuilder(
                                key: durationTextKey,
                                builder: (context, setState) {
                                  return Text(
                                    "${StringFormatUtils.timeLengthFormat(widget.controller._position.inSeconds)}/${StringFormatUtils.timeLengthFormat(widget.controller._duration.inSeconds)}",
                                    style: const TextStyle(color: textColor),
                                  );
                                },
                              ),
                              const Spacer(),
                              //弹幕开关
                              StatefulBuilder(
                                key: danmakuCheckBoxKey,
                                builder: (context, setState) {
                                  return Row(
                                    children: [
                                      const Text(
                                        "弹幕",
                                        style: TextStyle(color: textColor),
                                      ),
                                      Checkbox(
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
                                      )
                                    ],
                                  );
                                },
                              ),
                              const Spacer(),
                              //全屏按钮
                              IconButton(
                                  onPressed: toggleFullScreen,
                                  icon: const Icon(
                                    Icons.fullscreen_rounded,
                                    color: iconColor,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ))
      ],
    );
  }
}