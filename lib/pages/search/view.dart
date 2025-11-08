import 'package:bili_own/pages/search/controller.dart';
import 'package:bili_own/pages/search/widgets/hot_keyword.dart';
import 'package:bili_own/pages/search/widgets/search_text.dart';
import 'package:bili_own/common/utils/bili_own_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/models/network/search/search_trending/list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _tag = 'search';
  late final SSearchController _searchController = Get.put(
    SSearchController(_tag),
    tag: _tag,
  );

  @override
  void initState() {
    super.initState();
    // 在界面构建完成后请求焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.searchFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
        centerTitle: false, // 标题靠左
        automaticallyImplyLeading: false, // 取消返回按钮
      ),
      body: Column(
        children: [
          // 搜索框区域
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              focusNode: _searchController.searchFocusNode,
              controller: _searchController.controller,
              textInputAction: TextInputAction.search,
              onChanged: _searchController.onChange,
              decoration: InputDecoration(
                hintText: '请输入搜索关键词',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _searchController.onClear,
                ),
              ),
              onSubmitted: (value) => _searchController.submit(),
            ),
          ),
          // 内容区域
          Expanded(
            child: ListView(
              padding: MediaQuery.paddingOf(context).copyWith(top: 0),
              children: [
                if (_searchController.searchSuggestion) _searchSuggest(),
                if (context.orientation == Orientation.portrait) ...[
                  if (_searchController.enableHotKey) hotSearch(theme),
                  _history(theme),
                  if (_searchController.enableSearchRcmd) hotSearch(theme, false),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_searchController.enableHotKey ||
                          _searchController.enableSearchRcmd)
                        Expanded(
                          child: Column(
                            children: [
                              if (_searchController.enableHotKey) hotSearch(theme),
                              if (_searchController.enableSearchRcmd)
                                hotSearch(theme, false),
                            ],
                          ),
                        ),
                      Expanded(child: _history(theme)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchSuggest() {
    return Obx(
      () =>
          _searchController.searchSuggestList.isNotEmpty &&
              _searchController.controller.text != ''
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _searchController.searchSuggestList
                  .map(
                    (item) => InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      onTap: () => _searchController.onClickKeyword(item.realWord),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 9,
                          bottom: 9,
                        ),
                        child: Text(
                          item.showWord,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget hotSearch(ThemeData theme, [bool isHot = true]) {
    final text = Text(
      isHot ? '大家都在搜' : '搜索发现',
      strutStyle: const StrutStyle(leading: 0, height: 1),
      style: theme.textTheme.titleMedium!.copyWith(
        height: 1,
        fontWeight: FontWeight.bold,
      ),
    );
    final outline = theme.colorScheme.outline;
    final secondary = theme.colorScheme.secondary;
    final style = TextStyle(
      height: 1,
      fontSize: 13,
      color: outline,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(10, isHot ? 25 : 4, 4, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isHot
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          text,
                          const SizedBox(width: 14),
                          SizedBox(
                            height: 34,
                            child: TextButton(
                              onPressed: () {
                                // 跳转到热搜榜单页面
                                Get.toNamed(
                                  '/searchTrending',
                                  parameters: {'tag': _tag},
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '完整榜单',
                                    strutStyle: const StrutStyle(
                                      leading: 0,
                                      height: 1,
                                    ),
                                    style: style,
                                  ),
                                  Icon(
                                    size: 18,
                                    Icons.keyboard_arrow_right,
                                    color: outline,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : text,
                SizedBox(
                  height: 34,
                  child: TextButton.icon(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                    ),
                    onPressed: isHot
                        ? _searchController.queryHotSearchList
                        : _searchController.queryRecommendList,
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 18,
                      color: secondary,
                    ),
                    label: Text(
                      '刷新',
                      strutStyle: const StrutStyle(leading: 0, height: 1),
                      style: TextStyle(
                        height: 1,
                        color: secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => _buildHotKey(
              isHot
                  ? _searchController.loadingState.value
                  : _searchController.recommendData.value,
              isHot,
            ),
          ),
        ],
      ),
    );
  }

  Widget _history(ThemeData theme) {
    return Obx(
      () {
        if (_searchController.historyList.isEmpty) {
          return const SizedBox.shrink();
        }
        final secondary = theme.colorScheme.secondary;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            10,
            context.orientation == Orientation.landscape
                ? 25
                : _searchController.enableHotKey
                ? 0
                : 6,
            6,
            25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: Row(
                  children: [
                    Text(
                      '搜索历史',
                      strutStyle: const StrutStyle(leading: 0, height: 1),
                      style: theme.textTheme.titleMedium!.copyWith(
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(
                      () {
                        bool enable =
                            _searchController.recordSearchHistory.value;
                        return SizedBox(
                          width: 34,
                          height: 34,
                          child: IconButton(
                            iconSize: 22,
                            tooltip: enable ? '记录搜索' : '无痕搜索',
                            icon: Icon(
                              Icons.history,
                              color: enable 
                                ? theme.colorScheme.onSurfaceVariant.withAlpha(200)
                                : theme.disabledColor,
                            ),
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              enable = !enable;
                              _searchController.recordSearchHistory.value =
                                  enable;
                              BiliOwnStorage.settings.put(
                                'recordSearchHistory',
                                enable,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: TextButton.icon(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                        ),
                        onPressed: _searchController.onClearHistory,
                        icon: Icon(
                          Icons.clear_all_outlined,
                          size: 18,
                          color: secondary,
                        ),
                        label: Text(
                          '清空',
                          style: TextStyle(color: secondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                direction: Axis.horizontal,
                textDirection: TextDirection.ltr,
                children: _searchController.historyList
                    .map(
                      (item) => SearchText(
                        text: item,
                        onTap: _searchController.onClickKeyword,
                        onLongPress: _searchController.onLongSelect,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHotKey(List<SearchTrendingItemModel> hotList, bool isHot) {
    return hotList.isNotEmpty
        ? LayoutBuilder(
            builder: (context, constraints) => HotKeyword(
              width: constraints.maxWidth,
              hotSearchList: hotList,
              onClick: _searchController.onClickKeyword,
            ),
          )
        : const SizedBox.shrink();
  }
}