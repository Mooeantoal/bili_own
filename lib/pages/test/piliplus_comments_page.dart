import 'package:bili_own/pages/test/piliplus_reply_model.dart';
import 'package:bili_own/pages/test/piliplus_reply_item_widget.dart';
import 'package:flutter/material.dart';

class PiliPlusCommentsPage extends StatelessWidget {
  const PiliPlusCommentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PiliPlus评论界面'),
      ),
      body: const PiliPlusCommentsContent(),
    );
  }
}

class PiliPlusCommentsContent extends StatefulWidget {
  const PiliPlusCommentsContent({Key? key}) : super(key: key);

  @override
  State<PiliPlusCommentsContent> createState() => _PiliPlusCommentsContentState();
}

class _PiliPlusCommentsContentState extends State<PiliPlusCommentsContent> {
  late List<PiliPlusReplyItem> _comments;

  @override
  void initState() {
    super.initState();
    _comments = PiliPlusReplyItem.generateTestData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 评论输入框
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '说点什么吧...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        // 评论列表
        Expanded(
          child: ListView.builder(
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              return PiliPlusReplyItemWidget(
                comment: _comments[index],
                onReply: (comment, rpid) {
                  // 处理回复逻辑
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('回复评论: ${comment.name}')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}