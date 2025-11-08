import 'dart:developer';

import 'package:bili_own/common/models/local/video_tile/video_tile_info.dart';
import 'package:bili_own/common/utils/index.dart';
import 'package:bili_own/common/values/cache_keys.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:bili_own/common/api/home_api.dart';

class PopularVideoController {
  PopularVideoController();
  List<VideoTileInfo> videoItems = [];

  ScrollController scrollController = ScrollController();
  EasyRefreshController refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  int currentPage = 1;
  CacheManager cacheManager =
      CacheManager(Config(CacheKeys.relatedVideosItemCoverKey));

  void animateToTop() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  // 加载并追加热门视频
  Future<bool> _addPopularVideos() async {
    try {
      videoItems.addAll(await HomeApi.getPopularVideos(pageNum: currentPage));
    } catch (e) {
      log("加载热门视频失败:${e.toString()}");
      return false;
    }
    currentPage += 1;
    return true;
  }

  Future<void> onRefresh() async {
    videoItems.clear();
    currentPage = 1;
    await cacheManager.emptyCache();
    if (await _addPopularVideos()) {
      refreshController.finishRefresh(IndicatorResult.success);
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoad() async {
    if (await _addPopularVideos()) {
      refreshController.finishLoad(IndicatorResult.success);
      refreshController.resetFooter();
    } else {
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _addPopularVideos();
  }
}