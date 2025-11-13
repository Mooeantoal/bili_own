import 'package:get/get.dart';

class TestVideoController extends GetxController {
  // 添加一些测试用的变量
  final RxString _testMessage = "测试消息".obs;
  String get testMessage => _testMessage.value;
  
  final RxBool _isTesting = false.obs;
  bool get isTesting => _isTesting.value;
  
  // 视频信息相关变量
  final RxString _videoTitle = "测试视频标题".obs;
  String get videoTitle => _videoTitle.value;
  
  final RxInt _playCount = 123456.obs;
  int get playCount => _playCount.value;
  
  final RxInt _danmakuCount = 1234.obs;
  int get danmakuCount => _danmakuCount.value;
  
  final RxInt _likeCount = 1234.obs;
  int get likeCount => _likeCount.value;
  
  final RxInt _coinCount = 432.obs;
  int get coinCount => _coinCount.value;
  
  final RxInt _favoriteCount = 567.obs;
  int get favoriteCount => _favoriteCount.value;
  
  final RxInt _shareCount = 89.obs;
  int get shareCount => _shareCount.value;
  
  // 操作状态
  final RxBool _isLiked = false.obs;
  bool get isLiked => _isLiked.value;
  
  final RxBool _isCoined = false.obs;
  bool get isCoined => _isCoined.value;
  
  final RxBool _isFavorited = false.obs;
  bool get isFavorited => _isFavorited.value;
  
  // 添加更多视频信息变量，模仿bilimiao项目的功能
  final RxString _videoDescription = "这是一个测试视频的简介内容，用于展示从bilimiao项目移植的视频详情功能。".obs;
  String get videoDescription => _videoDescription.value;
  
  final RxString _videoAuthor = "测试UP主".obs;
  String get videoAuthor => _videoAuthor.value;
  
  final RxString _videoAuthorAvatar = "https://i0.hdslb.com/bfs/face/member/noface.jpg".obs;
  String get videoAuthorAvatar => _videoAuthorAvatar.value;
  
  final RxInt _videoPublishTime = 1609459200.obs; // 时间戳
  int get videoPublishTime => _videoPublishTime.value;
  
  final RxList<String> _videoTags = <String>[].obs;
  List<String> get videoTags => _videoTags;
  
  @override
  void onInit() {
    super.onInit();
    // 初始化测试功能
    _testMessage.value = "欢迎使用移植测试页面";
    
    // 初始化视频标签
    _videoTags.addAll(['测试', '视频', '功能']);
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
  
  // 点赞操作
  void toggleLike() {
    _isLiked.value = !_isLiked.value;
    _likeCount.value = _isLiked.value ? _likeCount.value + 1 : _likeCount.value - 1;
  }
  
  // 投币操作
  void addCoin() {
    _isCoined.value = true;
    _coinCount.value = _coinCount.value + 1;
  }
  
  // 收藏操作
  void toggleFavorite() {
    _isFavorited.value = !_isFavorited.value;
    _favoriteCount.value = _isFavorited.value ? _favoriteCount.value + 1 : _favoriteCount.value - 1;
  }
  
  // 分享操作
  void share() {
    _shareCount.value = _shareCount.value + 1;
    Get.snackbar('提示', '分享成功');
  }
  
  // 下载操作
  void download() {
    Get.snackbar('提示', '开始下载视频');
  }
  
  // 添加更多操作方法，模仿bilimiao项目的功能
  // 关注UP主
  void followAuthor() {
    Get.snackbar('提示', '已关注UP主');
  }
  
  // 不喜欢视频
  void dislikeVideo() {
    Get.snackbar('提示', '已标记为不喜欢');
  }
  
  // 添加到稍后再看
  void addToWatchLater() {
    Get.snackbar('提示', '已添加到稍后再看');
  }
  
  // 添加到播放列表
  void addToPlaylist() {
    Get.snackbar('提示', '已添加到播放列表');
  }
  
  // 举报视频
  void reportVideo() {
    Get.snackbar('提示', '已举报视频');
  }
  
  // 复制视频链接
  void copyVideoLink() {
    Get.snackbar('提示', '已复制视频链接');
  }
  
  // 在浏览器中打开
  void openInBrowser() {
    Get.snackbar('提示', '已在浏览器中打开');
  }
  
  // 保存封面
  void saveCover() {
    Get.snackbar('提示', '已保存封面');
  }
}