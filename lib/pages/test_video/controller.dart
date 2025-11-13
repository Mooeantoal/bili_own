import 'package:get/get.dart';

class TestVideoController extends GetxController {
  // 添加一些测试用的变量
  final RxString _testMessage = "测试消息".obs;
  String get testMessage => _testMessage.value;
  
  final RxBool _isTesting = false.obs;
  bool get isTesting => _isTesting.value;
  
  @override
  void onInit() {
    super.onInit();
    // 初始化测试功能
    _testMessage.value = "欢迎使用移植测试页面";
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 开始测试
  void startTest() {
    _isTesting.value = true;
    _testMessage.value = "测试进行中...";
  }
  
  // 结束测试
  void endTest() {
    _isTesting.value = false;
    _testMessage.value = "测试完成";
  }
  
  // 重置测试
  void resetTest() {
    _isTesting.value = false;
    _testMessage.value = "测试已重置";
  }
}