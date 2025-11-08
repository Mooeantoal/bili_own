/// 简化的PiliPlus风格评论模型
class PiliPlusReplyItem {
  final int rpid;
  final int mid;
  final String name;
  final String avatarUrl;
  final String message;
  final int replyCount;
  final int replyTime;
  final List<PiliPlusReplyItem> preReplies;
  final bool isVip;
  
  // 可变属性
  bool hasLike;
  int likeCount;

  PiliPlusReplyItem({
    required this.rpid,
    required this.mid,
    required this.name,
    required this.avatarUrl,
    required this.message,
    required this.likeCount,
    required this.replyCount,
    required this.replyTime,
    required this.hasLike,
    required this.isVip,
    required this.preReplies,
  });

  /// 创建测试数据
  static List<PiliPlusReplyItem> generateTestData() {
    return [
      PiliPlusReplyItem(
        rpid: 1001,
        mid: 123456,
        name: "用户A",
        avatarUrl: "",
        message: "这是一条测试评论，展示了PiliPlus风格的评论界面设计。",
        likeCount: 23,
        replyCount: 5,
        replyTime: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600 * 2,
        hasLike: false,
        isVip: true,
        preReplies: [
          PiliPlusReplyItem(
            rpid: 1002,
            mid: 654321,
            name: "用户B",
            avatarUrl: "",
            message: "这是回复内容",
            likeCount: 2,
            replyCount: 0,
            replyTime: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600 * 1,
            hasLike: true,
            isVip: false,
            preReplies: [],
          ),
        ],
      ),
      PiliPlusReplyItem(
        rpid: 1003,
        mid: 111111,
        name: "用户C",
        avatarUrl: "",
        message: "另一条评论内容，用于展示评论列表的效果。",
        likeCount: 45,
        replyCount: 12,
        replyTime: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600 * 24,
        hasLike: true,
        isVip: false,
        preReplies: [],
      ),
      PiliPlusReplyItem(
        rpid: 1004,
        mid: 222222,
        name: "大会员用户D",
        avatarUrl: "",
        message: "大会员用户的评论内容，展示了大会员标识。",
        likeCount: 128,
        replyCount: 23,
        replyTime: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600 * 48,
        hasLike: false,
        isVip: true,
        preReplies: [],
      ),
    ];
  }
}