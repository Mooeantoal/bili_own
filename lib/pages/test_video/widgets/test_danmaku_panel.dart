// 测试弹幕面板，用于移植bilimiao项目的弹幕控制面板功能
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ns_danmaku/models/danmaku_item.dart';

import 'test_danmaku.dart';

class TestDanmakuPanel extends StatefulWidget {
  final TestDanmakuController controller;
  
  const TestDanmakuPanel({Key? key, required this.controller}) : super(key: key);

  @override
  State<TestDanmakuPanel> createState() => _TestDanmakuPanelState();
}

class _TestDanmakuPanelState extends State<TestDanmakuPanel> {
  // 弹幕输入控制器
  final TextEditingController _danmakuInputController = TextEditingController();
  
  // 弹幕颜色选项
  final List<Color> _danmakuColors = [
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
  ];
  
  // 当前选中的弹幕颜色
  Color _selectedColor = Colors.white;
  
  // 弹幕类型选项
  final List<String> _danmakuTypes = [
    "滚动",
    "顶部",
    "底部",
  ];
  
  // 当前选中的弹幕类型
  String _selectedType = "滚动";

  @override
  void dispose() {
    _danmakuInputController.dispose();
    super.dispose();
  }

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
          // 弹幕开关和设置
          _buildDanmakuControls(),
          const SizedBox(height: 8),
          // 弹幕发送区域
          _buildDanmakuSendArea(),
        ],
      ),
    );
  }

  // 构建弹幕控制区域
  Widget _buildDanmakuControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 弹幕开关
        Obx(() => IconButton(
          icon: Icon(
            widget.controller.isDanmakuOpened ? Icons.comment : Icons.comment_outlined,
            color: widget.controller.isDanmakuOpened ? Colors.white : Colors.grey,
          ),
          onPressed: widget.controller.toggleDanmaku,
        )),
        // 弹幕设置按钮
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: _showDanmakuSettings,
        ),
      ],
    );
  }

  // 构建弹幕发送区域
  Widget _buildDanmakuSendArea() {
    return Row(
      children: [
        // 弹幕输入框
        Expanded(
          child: TextField(
            controller: _danmakuInputController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "发送弹幕",
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            onSubmitted: _sendDanmaku,
          ),
        ),
        // 发送按钮
        IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: () {
            _sendDanmaku(_danmakuInputController.text);
          },
        ),
      ],
    );
  }

  // 发送弹幕
  void _sendDanmaku(String text) {
    if (text.trim().isNotEmpty) {
      // 创建弹幕项
      final danmakuItem = DanmakuItem(
        text,
        color: _selectedColor,
        type: _getDanmakuItemTypeFromString(_selectedType),
      );
      
      // 添加到弹幕控制器
      widget.controller.addDanmakuItem(danmakuItem);
      
      // 清空输入框
      _danmakuInputController.clear();
      
      // 显示发送成功的提示
      Get.snackbar("提示", "弹幕发送成功", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 根据字符串获取弹幕类型
  DanmakuItemType _getDanmakuItemTypeFromString(String type) {
    switch (type) {
      case "顶部":
        return DanmakuItemType.top; // 顶部弹幕
      case "底部":
        return DanmakuItemType.bottom; // 底部弹幕
      default:
        return DanmakuItemType.scroll; // 滚动弹幕
    }
  }

  // 显示弹幕设置对话框
  void _showDanmakuSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                "弹幕设置",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 弹幕颜色设置
                    const Text(
                      "弹幕颜色",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _danmakuColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // 弹幕类型设置
                    const Text(
                      "弹幕类型",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _danmakuTypes.map((type) {
                        return ChoiceChip(
                          label: Text(type, style: const TextStyle(color: Colors.white)),
                          selected: _selectedType == type,
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.grey[800],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // 弹幕透明度设置
                    const Text(
                      "弹幕透明度",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Slider(
                      value: widget.controller.danmakuOpacity,
                      onChanged: (value) {
                        widget.controller.setDanmakuOpacity(value);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    )),
                    const SizedBox(height: 16),
                    // 弹幕大小设置
                    const Text(
                      "弹幕大小",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Slider(
                      value: widget.controller.danmakuSize,
                      onChanged: (value) {
                        widget.controller.setDanmakuSize(value);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    )),
                    const SizedBox(height: 16),
                    // 弹幕区域设置
                    const Text(
                      "弹幕区域",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Slider(
                      value: widget.controller.danmakuArea,
                      onChanged: (value) {
                        widget.controller.setDanmakuArea(value);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    )),
                    const SizedBox(height: 16),
                    // 弹幕速度设置
                    const Text(
                      "弹幕速度",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Slider(
                      value: widget.controller.danmakuSpeed,
                      onChanged: (value) {
                        widget.controller.setDanmakuSpeed(value);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "关闭",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}