import 'package:get/get.dart';

import 'view.dart';
import 'widgets/video_detail_route.dart';

class TestVideoRoute {
  static const String path = '/test_video';
  
  static GetPage getPage() {
    return GetPage(
      name: path,
      page: () => const TestVideoPage(),
      children: [
        VideoDetailRoute.getPage(),
      ],
    );
  }
}