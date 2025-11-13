import 'dart:developer';

import 'package:bili_own/common/models/local/home/recommend_item_info.dart';
import 'package:bili_own/common/utils/index.dart';
import 'package:bili_own/common/values/cache_keys.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/api/home_api.dart';

class RecommendController extends GetxController {
  RecommendController();
  List<RecommendVideoItemInfo> recommendItems = [];

  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  int refreshIdx = 0;
  CacheManager cacheManager =
      CacheManager(Config(CacheKeys.recommendItemCoverKey));
  int recommendColumnCount = 1;

  @override
  void onInit() {
    recommendColumnCount = BiliOwnStorage.settings
        .get(SettingsStorageKeys.recommendColumnCount, defaultValue: 2);
    super.onInit();
  }
  
  @override
  void onReady() {
    super.onReady();
    // 初始化时加载推荐视频
    _addRecommendItems();
  }

  void animateToTop() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

//加载并追加视频推荐
  Future<bool> _addRecommendItems() async {
    try {
      log("开始加载推荐视频，refreshIdx: $refreshIdx");
      var items = await HomeApi.getRecommendVideoItems(
          num: 16, refreshIdx: refreshIdx);
      recommendItems.addAll(items);
      log("成功加载 ${items.length} 个推荐视频，总共有 ${recommendItems.length} 个视频");
    } catch (e, stackTrace) {
      log("加载推荐视频失败:${e.toString()}");
      log("错误堆栈: $stackTrace");
      return false;
    }
    refreshIdx += 1;
    return true;
  }

  Future<void> onRefresh() async {
    log("刷新推荐视频");
    recommendItems.clear();
    await cacheManager.emptyCache();
    if (await _addRecommendItems()) {
      refreshController.finishRefresh(IndicatorResult.success);
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoad() async {
    log("加载更多推荐视频");
    if (await _addRecommendItems()) {
      refreshController.finishLoad(IndicatorResult.success);
      refreshController.resetFooter();
    } else {
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }
}