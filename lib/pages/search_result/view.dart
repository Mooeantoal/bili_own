import 'package:bili_you/common/api/search_api.dart';
import 'package:bili_you/pages/search/view.dart';
import 'package:bili_you/pages/search_tab_view/controller.dart';

import 'package:bili_you/pages/search_tab_view/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'index.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({Key? key, required this.keyWord}) : super(key: key);
  final String keyWord;
  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with AutomaticKeepAliveClientMixin {
  late SearchResultController controller;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    controller = Get.put(SearchResultController(keyWord: widget.keyWord));
    super.initState();
  }

  @override
  void dispose() {
    // controller.onClose();
    // controller.onDelete();
    controller.dispose();
    super.dispose();
  }

  AppBar _appBar(BuildContext context, SearchResultController controller) {
    return AppBar(
        shape: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: widget.keyWord),
                  onSubmitted: (value) {
                    // 点击搜索按钮或按回车键时跳转到新的搜索页面
                    Get.to(() => SearchPage());
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '搜索',
                  ),
                ),
              ),
            ],
          ),
        ),
        bottom: TabBar(
            controller: controller.tabController,
            onTap: (value) {
              if (controller.currentSelectedTabIndex == value) {
                //移动到顶部
                Get.find<SearchTabViewController>(
                        tag: controller.getTabTagNameByIndex(value))
                    .animateToTop();
              }
              controller.currentSelectedTabIndex = value;
              controller.tabController.animateTo(value);
            },
            tabs: [
              for (var i in SearchType.values)
                Tab(
                  text: i.name,
                ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _appBar(context, controller),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          for (var i in SearchType.values)
            SearchTabViewPage(
              keyWord: widget.keyWord,
              searchType: i,
              tagName: controller.getTabTagNameByIndex(i.index),
            ),
        ],
      ),
    );
  }
}