import 'package:bili_own/common/widget/cached_network_image.dart';
import 'package:bili_own/pages/recommend/controller.dart';
import 'package:bili_own/pages/search_input/index.dart';
import 'package:bili_own/pages/test_video/view.dart';
import 'package:bili_own/pages/ui_test/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/pages/recommend/view.dart';
import 'package:bili_own/pages/popular_video/view.dart';
import 'index.dart';
import 'widgets/user_menu/view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  late HomeController controller;
  final RecommendPage recommendPage = const RecommendPage();
  final PopularVideoPage popularVideoPage = const PopularVideoPage();
  List<Map<String, dynamic>> tabsList = [];

  @override
  void initState() {
    controller = Get.put(HomeController());
    tabsList = controller.tabsList;
    controller.tabController = TabController(length: tabsList.length, vsync: this, initialIndex: controller.tabInitIndex);
    super.initState();
  }

  @override
  void dispose() {
    // controller.onClose();
    // controller.onDelete();
    controller.dispose();
    super.dispose();
  }

  // 主视图
  Widget _buildView(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiliYou'),
        centerTitle: false,
        bottom: TabBar(
          isScrollable: true,
          tabs: tabsList.map((e) => Tab(text: e['text'])).toList(),
          controller: controller.tabController,
          onTap: (index) {
            //点击"推荐"回到顶
            if (index == 1 && !controller.tabController!.indexIsChanging) {
              Get.find<RecommendController>().animateToTop();
            }
          },
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: tabsList.asMap().map((index, e) {
          if (index == 1) {
            return MapEntry(index, recommendPage);
          } else if (index == 2) {
            return MapEntry(index, popularVideoPage);
          } else {
            return MapEntry(index, const Center(child: Text("该功能暂无")));
          }
        }).values.toList(),
      ),
      // 添加浮动按钮访问测试页面
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const TestVideoPage());
        },
        child: const Icon(Icons.bug_report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildView(context);
  }
}