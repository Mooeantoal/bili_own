import 'package:get/get.dart';

import 'view.dart';

class TestVideoRoute {
  static const String path = '/test_video';
  
  static GetPage getPage() {
    return GetPage(
      name: path,
      page: () => const TestVideoPage(),
    );
  }
}