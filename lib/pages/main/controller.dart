import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/view.dart';
import '../dynamic/view.dart';
import '../user_menu/user_menu_page.dart';
import '../search/view.dart';

class MainController extends GetxController {
  MainController();
  var selectedIndex = 0.obs;

  List<Widget> pages = [
    const HomePage(),
    const DynamicPage(),
    const SearchPage(),
    const UserMenuStandalonePage(),
  ];

  _initData() {
    // update(["main"]);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
