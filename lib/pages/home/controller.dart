import 'dart:developer';

import 'package:bili_own/common/api/index.dart';
import 'package:bili_own/common/models/local/login/login_user_info.dart';
import 'package:bili_own/common/utils/bili_own_storage.dart';
import 'package:bili_own/common/values/cache_keys.dart';
import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController();
  CacheManager cacheManager = CacheManager(Config(CacheKeys.userFaceKey));
  RxString faceUrl = ApiConstants.noface.obs;
  late LoginUserInfo userInfo;

  final List<Map<String, String>> tabsList = [
    {'text': '直播', 'id': '', 'controller': ''},
    {'text': '推荐', 'id': '', 'controller': 'RecommendController'},
    {'text': '热门', 'id': '', 'controller': 'PopularVideoController'},
    {'text': '番剧', 'id': '', 'controller': ''}
  ];
  late TabController? tabController;
  final int tabInitIndex = 1;
  RxInt tabIndex = 1.obs;

  _initData() async {
    // 初始化数据
  }

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() async {
    super.onReady();
    _initData();
  }

  Future<void> refreshFace() async {
    try {
      userInfo = await LoginApi.getLoginUserInfo();
      faceUrl.value = userInfo.avatarUrl;
    } catch (e) {
      faceUrl.value = ApiConstants.noface;
      log(e.toString());
    }
  }

  Future<void> loadOldFace() async {
    var box = BiliOwnStorage.user;
    faceUrl.value = box.get(UserStorageKeys.userFace) ?? ApiConstants.noface;
  }
}
