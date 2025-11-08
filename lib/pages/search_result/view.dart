import 'package:bili_own/common/api/search_api.dart';
import 'package:bili_own/pages/search/view.dart';
import 'package:bili_own/pages/search_tab_view/controller.dart';

import 'package:bili_own/pages/search_tab_view/view.dart';
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
  late TextEditingController _textController;
  late FocusNode _focusNode;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    controller = Get.put(SearchResultController(keyWord: widget.keyWord));
    _textController = TextEditingController(text: widget.keyWord);
    _focusNode = FocusNode();
    super.initState();
    
    // 稍微延迟一下再请求焦点，确保界面已经构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // controller.onClose();
    // controller.onDelete();
    _textController.dispose();
    _focusNode.dispose();
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _textController,
                  onSubmitted: (value) {
                    // 直接在当前页面进行新的搜索
                    if (value.trim().isNotEmpty) {
                      // 更新搜索关键字
                      controller.updateSearchKeyword(value);
                      // 更新各个tab页面的搜索关键字
                      for (int i = 0; i < SearchType.values.length; i++) {
                        try {
                          final tabController = Get.find<SearchTabViewController>(
                              tag: controller.getTabTagNameByIndex(i));
                          tabController.updateSearchKeyword(value);
                        } catch (e) {
                          // 如果找不到控制器则忽略
                        }
                      }
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '搜索',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _textController.clear();
                        // 请求焦点以确保键盘保持打开状态
                        _focusNode.requestFocus();
                      },
                    ),
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