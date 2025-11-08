import 'package:bili_you/common/widget/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class CommonListController<T, ItemType> extends GetxController {
  final ScrollController scrollController = ScrollController();
  final loadingState = LoadingState<T>.loading().obs;

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // 获取数据列表
  List<ItemType>? getDataList(T response);

  // 自定义获取数据的方法
  Future<LoadingState<T>> customGetData();

  // 刷新数据
  Future<void> onRefresh() async {
    await queryData();
  }

  // 重新加载数据
  Future<void> onReload() async {
    await queryData();
  }

  // 查询数据
  Future<void> queryData() async {
    try {
      final result = await customGetData();
      loadingState.value = result;
    } catch (e) {
      loadingState.value = LoadingState<T>.error(e.toString());
    }
  }
}