import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PiliPlusUserSpacePage extends StatefulWidget {
  const PiliPlusUserSpacePage({super.key});

  @override
  State<PiliPlusUserSpacePage> createState() => _PiliPlusUserSpacePageState();
}

class _PiliPlusUserSpacePageState extends State<PiliPlusUserSpacePage> {
  late final int _mid;
  late final String _heroTag;

  @override
  void initState() {
    super.initState();
    _mid = int.tryParse(Get.parameters['mid'] ?? '0') ?? 0;
    _heroTag = 'user_space_$_mid';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户空间'),
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: () {
              // 搜索功能
            },
            icon: const Icon(Icons.search_outlined),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                child: Text('分享用户'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 用户信息卡片
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '用户名',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'UID: $_mid',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 关注/取消关注逻辑
                  },
                  child: const Text('关注'),
                ),
              ],
            ),
          ),
          // 标签页
          const TabBar(
            tabs: [
              Tab(text: '主页'),
              Tab(text: '动态'),
              Tab(text: '投稿'),
              Tab(text: '收藏'),
              Tab(text: '追番'),
            ],
          ),
          // 内容区域
          Expanded(
            child: TabBarView(
              children: const [
                Center(child: Text('主页内容')),
                Center(child: Text('动态内容')),
                Center(child: Text('投稿内容')),
                Center(child: Text('收藏内容')),
                Center(child: Text('追番内容')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}