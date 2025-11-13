// 测试评论组件，用于移植bilimiao项目的评论功能
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestReplyPage extends StatefulWidget {
  const TestReplyPage({Key? key}) : super(key: key);

  @override
  State<TestReplyPage> createState() => _TestReplyPageState();
}

class _TestReplyPageState extends State<TestReplyPage> {
  // 评论列表数据
  final List<TestReplyItem> _replyItems = [
    TestReplyItem(
      id: '1',
      userName: '用户1',
      userAvatar: 'https://i0.hdslb.com/bfs/face/member/noface.jpg',
      content: '这是一个测试评论内容1',
      likeCount: 10,
      createTime: DateTime.now().subtract(const Duration(hours: 1)),
      isLiked: false,
    ),
    TestReplyItem(
      id: '2',
      userName: '用户2',
      userAvatar: 'https://i0.hdslb.com/bfs/face/member/noface.jpg',
      content: '这是一个测试评论内容2',
      likeCount: 5,
      createTime: DateTime.now().subtract(const Duration(hours: 2)),
      isLiked: true,
    ),
    TestReplyItem(
      id: '3',
      userName: '用户3',
      userAvatar: 'https://i0.hdslb.com/bfs/face/member/noface.jpg',
      content: '这是一个测试评论内容3',
      likeCount: 20,
      createTime: DateTime.now().subtract(const Duration(days: 1)),
      isLiked: false,
    ),
  ];
  
  // 评论输入控制器
  final TextEditingController _commentController = TextEditingController();
  
  // 排序方式
  String _sortOrder = '按热度';
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 评论标题和排序
          _buildReplyHeader(),
          const SizedBox(height: 16),
          // 评论输入区域
          _buildCommentInputArea(),
          const SizedBox(height: 16),
          // 评论列表
          Expanded(
            child: _buildReplyList(),
          ),
        ],
      ),
    );
  }
  
  // 构建评论标题和排序
  Widget _buildReplyHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '评论',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          onSelected: (String value) {
            setState(() {
              _sortOrder = value;
            });
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: '按热度',
                child: Text('按热度'),
              ),
              const PopupMenuItem<String>(
                value: '按时间',
                child: Text('按时间'),
              ),
            ];
          },
        ),
      ],
    );
  }
  
  // 构建评论输入区域
  Widget _buildCommentInputArea() {
    return Row(
      children: [
        // 用户头像占位符
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 8),
        // 输入框
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: '写评论...',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        // 发送按钮
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _sendComment,
        ),
      ],
    );
  }
  
  // 发送评论
  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      // 创建新评论
      final newReply = TestReplyItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: '当前用户',
        userAvatar: 'https://i0.hdslb.com/bfs/face/member/noface.jpg',
        content: text,
        likeCount: 0,
        createTime: DateTime.now(),
        isLiked: false,
      );
      
      // 添加到评论列表开头
      setState(() {
        _replyItems.insert(0, newReply);
        _commentController.clear();
      });
      
      // 显示提示
      Get.snackbar('提示', '评论发送成功');
    }
  }
  
  // 构建评论列表
  Widget _buildReplyList() {
    // 根据排序方式进行排序
    List<TestReplyItem> sortedItems = List.from(_replyItems);
    if (_sortOrder == '按时间') {
      sortedItems.sort((a, b) => b.createTime.compareTo(a.createTime));
    } else {
      // 按热度排序
      sortedItems.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
    
    return ListView.builder(
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        return _buildReplyItem(sortedItems[index]);
      },
    );
  }
  
  // 构建单个评论项
  Widget _buildReplyItem(TestReplyItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户头像
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 8),
            // 评论内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户名和时间
                  Row(
                    children: [
                      Text(
                        item.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item.createTime),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 评论内容
                  Text(
                    item.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  // 点赞和回复按钮
                  Row(
                    children: [
                      // 点赞按钮
                      GestureDetector(
                        onTap: () => _toggleLike(item),
                        child: Row(
                          children: [
                            Icon(
                              item.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 16,
                              color: item.isLiked ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.likeCount.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 回复按钮
                      GestureDetector(
                        onTap: () => _replyToComment(item),
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '回复',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 点赞/取消点赞
  void _toggleLike(TestReplyItem item) {
    setState(() {
      item.isLiked = !item.isLiked;
      item.likeCount += item.isLiked ? 1 : -1;
    });
  }
  
  // 回复评论
  void _replyToComment(TestReplyItem item) {
    _commentController.text = '回复 @${item.userName}: ';
    // 获取输入框焦点
    FocusScope.of(context).requestFocus();
  }
  
  // 格式化时间显示
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else {
      return '${time.year}-${time.month}-${time.day}';
    }
  }
}

// 评论项数据模型
class TestReplyItem {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  int likeCount;
  final DateTime createTime;
  bool isLiked;
  
  TestReplyItem({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.likeCount,
    required this.createTime,
    this.isLiked = false,
  });
}