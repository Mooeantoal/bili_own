import 'package:get/get.dart';

class SimpleDownloadService extends GetxController {
  static SimpleDownloadService get instance => Get.find<SimpleDownloadService>();

  // 简化版本，只提供基本功能
  final RxString currentDownloadTitle = "".obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isDownloading = false.obs;

  // 开始下载
  void startDownload(String title) {
    currentDownloadTitle.value = title;
    isDownloading.value = true;
    downloadProgress.value = 0.0;
  }

  // 更新进度
  void updateProgress(double progress) {
    downloadProgress.value = progress;
  }

  // 完成下载
  void completeDownload() {
    isDownloading.value = false;
    downloadProgress.value = 1.0;
  }

  // 取消下载
  void cancelDownload() {
    isDownloading.value = false;
    currentDownloadTitle.value = "";
    downloadProgress.value = 0.0;
  }
}