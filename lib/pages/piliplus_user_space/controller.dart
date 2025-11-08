class PiliPlusUserSpaceController {
  PiliPlusUserSpaceController({required this.mid});
  int mid = 0;
  String? username;
  bool showUname = false;

  int? isFollowed;
  int relation = 0;
  bool get isFollow => relation != 0 && relation != 128;

  List tabs = [];
  var tabController;
  int contributeInitialIndex = 0;

  var key;
  int offset = 120;
  var scrollController;

  void onInit() {
    // 初始化默认标签页
    tabs = const [
      '主页',
      '动态',
      '投稿',
      '收藏',
      '追番',
    ];
  }

  void onFollow(var context) {
    // 关注/取消关注逻辑
  }

  void onClose() {
    // 清理资源
  }

  void onReload() {
    // 重新加载数据
  }

  void blockUser(var context) {
    // 拉黑用户
  }

  void shareUser() {
    // 分享用户
  }

  void onRemoveFan() {
    // 移除粉丝
  }

  void onTapTab(int value) {
    // 标签页点击
  }

  void vipExpAdd() {
    // 大会员经验
  }
}