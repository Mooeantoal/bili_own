import 'dart:async';
import 'package:bili_you/common/api/search_api.dart';
import 'package:bili_you/common/models/local/search/search_suggest_item.dart';
import 'package:bili_you/common/utils/bili_you_storage.dart';
import 'package:bili_you/pages/search_result/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bili_you/common/models/network/search/search_trending/list.dart';

class SSearchController extends GetxController {
  SSearchController(this.tag);
  final String tag;

  final searchFocusNode = FocusNode();
  final controller = TextEditingController();

  String? hintText;

  int initIndex = 0;

  // uid
  final RxBool showUidBtn = false.obs;

  // history
  final RxBool recordSearchHistory = true.obs;
  late final RxList<String> historyList;

  // suggestion
  final bool searchSuggestion = true;
  StreamController<String>? _ctr;
  StreamSubscription<String>? _sub;
  late final RxList<SearchSuggestItem> searchSuggestList;

  // trending
  final bool enableHotKey = true;
  late final RxList<SearchTrendingItemModel> loadingState;

  // rcmd
  final bool enableSearchRcmd = true;
  late final RxList<SearchTrendingItemModel> recommendData;

  @override
  void onInit() {
    super.onInit();
    // 初始化历史记录
    historyList = List<String>.from(
      BiliYouStorage.history.get("searchHistory", defaultValue: <String>[]) ?? [],
    ).obs;

    if (searchSuggestion) {
      _ctr = StreamController<String>();
      _sub = _ctr!.stream
          .debounceTime(const Duration(milliseconds: 200))
          .listen(querySearchSuggest);
      searchSuggestList = <SearchSuggestItem>[].obs;
    }

    if (enableHotKey) {
      loadingState = <SearchTrendingItemModel>[].obs;
      queryHotSearchList();
    }

    if (enableSearchRcmd) {
      recommendData = <SearchTrendingItemModel>[].obs;
      queryRecommendList();
    }
  }

  void validateUid() {
    // 简化实现，不检查UID
    showUidBtn.value = false;
  }

  void onChange(String value) {
    validateUid();
    if (searchSuggestion) {
      if (value.isEmpty) {
        searchSuggestList.clear();
      } else {
        _ctr!.add(value);
      }
    }
  }

  void onClear() {
    if (controller.value.text != '') {
      controller.clear();
      searchSuggestList.clear();
      searchFocusNode.requestFocus();
      showUidBtn.value = false;
    } else {
      Get.back();
    }
  }

  // 搜索
  Future<void> submit() async {
    if (controller.text.isEmpty) {
      if (hintText == null || hintText!.isEmpty) {
        return;
      }
      controller.text = hintText!;
      validateUid();
    }

    if (recordSearchHistory.value) {
      historyList
        ..remove(controller.text)
        ..insert(0, controller.text);
      BiliYouStorage.history.put('searchHistory', historyList);
    }

    searchFocusNode.unfocus();
    
    // 跳转到搜索结果页面
    Get.to(() => SearchResultPage(keyWord: controller.text));
    
    searchFocusNode.requestFocus();
  }

  // 获取热搜关键词
  Future<void> queryHotSearchList() async {
    try {
      var hotWords = await SearchApi.getHotWords();
      List<SearchTrendingItemModel> hotList = [];
      for (var word in hotWords) {
        hotList.add(SearchTrendingItemModel(
          keyword: word.showWord,
          showLiveIcon: false,
          icon: '',
          uri: '',
        ));
      }
      loadingState.value = hotList;
    } catch (e) {
      print("获取热搜词失败: $e");
    }
  }

  Future<void> queryRecommendList() async {
    // 简化实现，使用相同的热搜词
    queryHotSearchList();
  }

  void onClickKeyword(String keyword) {
    controller.text = keyword;
    validateUid();

    searchSuggestList.clear();
    submit();
  }

  Future<void> querySearchSuggest(String value) async {
    try {
      var suggests = await SearchApi.getSearchSuggests(keyWord: value);
      searchSuggestList.value = suggests;
    } catch (e) {
      print("获取搜索建议失败: $e");
    }
  }

  void onLongSelect(String word) {
    historyList.remove(word);
    BiliYouStorage.history.put('searchHistory', historyList);
  }

  void onClearHistory() {
    historyList.clear();
    BiliYouStorage.history.put('searchHistory', []);
  }

  @override
  void onClose() {
    searchFocusNode.dispose();
    controller.dispose();
    _sub?.cancel();
    _ctr?.close();
    super.onClose();
  }
}