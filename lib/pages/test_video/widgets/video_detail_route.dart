import 'package:get/get.dart';

import 'video_detail_page.dart';

class VideoDetailRoute {
  static const String path = '/video_detail';
  
  static GetPage getPage() {
    return GetPage(
      name: path,
      page: () => const VideoDetailPage(),
    );
  }
}