import 'dart:developer';

import 'package:bili_own/common/api/home_api.dart';
import 'package:bili_own/common/models/local/video_tile/video_tile_info.dart';
import 'package:bili_own/common/utils/cache_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularVideoController extends GetxController {
  PopularVideoController();
  var refreshController = EasyRefreshController(
      controlFinishLoad: true, controlFinishRefresh: true);
  var scrollController = ScrollController();
  int currentPageNum = 1;
  RxList<VideoTileInfo> infoList = <VideoTileInfo>[].obs;
  final cacheManager = CacheUtils.relatedVideosItemCoverCacheManager;

  void animateToTop() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  Future<bool> _loadInfos() async {
    try {
      infoList.addAll(await HomeApi.getPopularVideos(pageNum: currentPageNum));
      currentPageNum++;
      return true;
    } catch (e) {
      log("PopularVideoController:$e");
    }
    return false;
  }

  Future<void> onRefresh() async {
    infoList.clear();
    currentPageNum = 1;
    if (await _loadInfos()) {
      refreshController.finishRefresh(IndicatorResult.success);
    } else {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoad() async {
    if (await _loadInfos()) {
      refreshController.finishLoad(IndicatorResult.success);
    } else {
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadInfos();
  }
}