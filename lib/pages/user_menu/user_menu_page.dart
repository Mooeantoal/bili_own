import 'package:bili_own/common/utils/bili_own_storage.dart';
import 'package:bili_own/common/widget/cached_network_image.dart';
import 'package:bili_own/pages/about/about_page.dart';
import 'package:bili_own/pages/history/history_page.dart';
import 'package:bili_own/pages/login/web_login/view.dart';
import 'package:bili_own/pages/settings_page/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/widgets/user_menu/controller.dart'; // 修复导入路径
import '../home/widgets/user_menu/view.dart';

class UserMenuStandalonePage extends StatelessWidget {
  const UserMenuStandalonePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        centerTitle: false, // 改为靠左对齐
      ),
      body: const UserMenuPage(), // 使用现有的UserMenuPage作为body
    );
  }
}

// 保持原有的UserMenuPage类，但修改为页面样式而不是对话框
class UserMenuPage extends StatelessWidget {
  const UserMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const UserMenuPageContent();
  }
}

// 从原UserMenuPage中提取内容部分
class UserMenuPageContent extends GetView<UserMenuController> {
  const UserMenuPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserMenuController>(
      init: UserMenuController(),
      id: "user_face",
      builder: (_) {
        return _buildView(context);
      },
    );
  }

  // 主视图 - 修改为页面样式而不是对话框
  Widget _buildView(context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: [
              // 头像和用户信息部分
              Container(
                padding: const EdgeInsets.only(top: 30, left: 15, bottom: 10),
                child: Row(
                  children: [
                    MaterialButton(
                      clipBehavior: Clip.antiAlias,
                      onPressed: () {},
                      shape: const CircleBorder(eccentricity: 0),
                      child: FutureBuilder(
                        future: controller.loadOldFace(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Obx(() {
                              return CachedNetworkImage(
                                cacheWidth: (80 *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .toInt(),
                                cacheHeight: (80 *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .toInt(),
                                //头像
                                cacheManager: controller.cacheManager,
                                width: 80,
                                height: 80,
                                imageUrl: BiliOwnStorage.user.get(UserStorageKeys.userFace,
                                    defaultValue: controller.faceUrl.value),
                                placeholder: () => const SizedBox(
                                  width: 80,
                                  height: 80,
                                ),
                              );
                            });
                          } else {
                            return Container(
                              color: Theme.of(context).colorScheme.primary,
                              width: 80,
                              height: 80,
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25, left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                                controller.name.value,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Obx(() => Text("LV${controller.level.value}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface))),
                              const SizedBox(
                                width: 20,
                              ),
                              Obx(() => Text(
                                    "${controller.currentExp}/${controller.level.value != 6 ? controller.nextExp : '--'}",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).hintColor),
                                  ))
                            ],
                          ),
                          SizedBox.fromSize(
                              size: const Size(100, 2),
                              child: Obx(
                                () => LinearProgressIndicator(
                                  backgroundColor:
                                      Theme.of(context).highlightColor,
                                  value: controller.nextExp.value > 0
                                      ? controller.currentExp.value /
                                          controller.nextExp.value
                                      : 0,
                                ),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 统计信息部分
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: Center(
                      child: MaterialButton(
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Obx(() => Text(
                                    controller.dynamicCount.value.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .color),
                                  )),
                              Text(
                                "动态",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .color),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Center(
                      child: MaterialButton(
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Obx(() => Text(
                                    controller.followingCount.value.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .color),
                                  )),
                              Text(
                                "关注",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .color),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Center(
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Obx(() => Text(
                                    controller.followerCount.value.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .color),
                                  )),
                              Text(
                                "粉丝",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .color),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              // 分割线
              Divider(
                height: 10,
                color: Theme.of(context).dividerColor,
                indent: 25,
                endIndent: 25,
                thickness: 2,
              ),
              // 菜单项
              UserMenuListTile(
                icon: const Icon(Icons.history),
                title: '历史记录',
                onTap: () => Navigator.of(context)
                    .push(GetPageRoute(page: () => const HistoryPage())),
              ),
              UserMenuListTile(
                icon: const Icon(
                  Icons.settings,
                ),
                title: "设置",
                onTap: () {
                  Navigator.of(context).push(GetPageRoute(
                    page: () => const SettingsPage(),
                  ));
                },
              ),
              UserMenuListTile(
                icon: const Icon(Icons.info),
                title: "关于",
                onTap: () {
                  Navigator.of(context).push(GetPageRoute(
                    page: () => const AboutPage(),
                  ));
                },
              ),
              UserMenuListTile(
                icon: const Icon(Icons.logout_rounded),
                title: "退出登陆",
                onTap: () {
                  controller.onLogout();
                },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
    );
  }
}