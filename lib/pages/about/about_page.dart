import 'package:bili_own/common/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final String projectUrl = "https://github.com/Mooeantoal/bili_own";
  final String authorUrl = "https://github.com/Mooeantoal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("关于")),
      body: ListView(children: [
        ListTile(
          title: const Text("版本"),
          subtitle: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Text(snapshot.data!.version);
              } else {
                return const Text("");
              }
            },
          ),
          trailing: TextButton(
              child: const Text("检查更新"),
              onPressed: () {
                SettingsUtil.checkUpdate(context);
              }),
        ),
        ListTile(
          title: const Text("作者"),
          subtitle: const Text("Mooeantoal"),
          onTap: () {
            launchUrlString(authorUrl);
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: authorUrl));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("已复制$authorUrl到剪切板")));
          },
        ),
        ListTile(
          title: const Text("项目链接"),
          subtitle: Text(projectUrl),
          onTap: () {
            launchUrlString(projectUrl);
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: projectUrl));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("已复制$projectUrl到剪切板")));
          },
        ),
        ListTile(
          title: const Text("许可"),
          onTap: () => Navigator.push(
              context,
              GetPageRoute(
                page: () => const LicensePage(
                  applicationIcon: ImageIcon(
                    AssetImage("assets/icon/bili.png"),
                    size: 200,
                  ),
                  applicationName: "Bili Own",
                ),
              )),
        ),
        // 致谢名单
        const ListTile(
          title: Text("致谢"),
          subtitle: Text(
            "此项目fork自lucinhu/bili_you，感谢以下项目的作者：\n"
            "• lucinhu - https://github.com/lucinhu/bili_you\n"
            "• bggRGjQaUbCoE (PiliPlus) - https://github.com/bggRGjQaUbCoE/PiliPlus\n"
            "• orz12 (PiliPalaX) - https://github.com/orz12/PiliPalaX\n"
            "• guozhigq (pilipala) - https://github.com/guozhigq/pilipala",
          ),
        ),
      ]),
    );
  }
}